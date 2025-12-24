import 'package:flutter/material.dart';
import 'package:medrepo/register.dart';
import 'colors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'root_page.dart';
import 'components/loader.dart';
import 'components/send_post_request.dart';
import 'components/snackbar/error.dart';
import 'components/snackbar/success.dart';
import 'components/animated_logo.dart';
import 'components/notifications.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }
  // Add this helper method to _LoginScreenState
  Future<void> _rescheduleNotificationsForMedication(Map<String, dynamic> med) async {
    try {
      final int totalDays = _parseDurationToDays(med['duration_of_therapy']);
      final int timesPerDay = _parseFrequencyToInt(med['frequency']);
      final String medicationId = med['id'].toString();
      final int baseAlarmId = medicationId.hashCode;
      
      final DateTime startDate = DateTime.parse(med['created_at']);
      final DateTime endDate = startDate.add(Duration(days: totalDays));
      
      // Only reschedule if medication is still active
      if (DateTime.now().isBefore(endDate)) {
        int notificationCount = 0;
        
        for (int d = 0; d < totalDays; d++) {
          for (int t = 0; t < timesPerDay; t++) {
            if (notificationCount >= 100) break;
            
            final int hourOffset = (t * (24 ~/ timesPerDay));
            DateTime scheduledTime = startDate.add(
              Duration(days: d, hours: hourOffset)
            );
            
            // Only schedule future notifications
            if (scheduledTime.isAfter(DateTime.now())) {
              await NotificationService.scheduleMedicationReminder(
                id: baseAlarmId + notificationCount,
                medicationId: medicationId,
                medicationName: med['name'],
                scheduledTime: scheduledTime,
                dosage: med['dosage_strength'],
              );
            }
            notificationCount++;
          }
        }
      }
    } catch (e) { }
  }

  int _parseDurationToDays(String duration) {
    final lower = duration.toLowerCase();
    final match = RegExp(r'\d+').firstMatch(duration);
    if (match == null) return 7;
    
    final number = int.tryParse(match.group(0)!) ?? 7;
    
    if (lower.contains('week')) return number * 7;
    if (lower.contains('month')) return number * 30;
    if (lower.contains('year')) return number * 365;
    
    return number;
  }

  int _parseFrequencyToInt(String frequency) {
    final lower = frequency.toLowerCase();
    if (lower.contains('once')) return 1;
    if (lower.contains('twice')) return 2;
    if (lower.contains('thrice')) return 3;
    
    final match = RegExp(r'\d+').firstMatch(frequency);
    if (match != null) {
      return int.tryParse(match.group(0)!) ?? 1;
    }
    
    return 1;
  }
  
  /// Load saved email from Hive if available
  Future<void> _loadSavedEmail() async {
    try {
      final authBox = Hive.box('register');
      final savedEmail = authBox.get('saved_email');
      
      if (savedEmail != null && savedEmail.toString().isNotEmpty) {
        setState(() {
          emailController.text = savedEmail.toString();
        });
      }
    } catch (e) { }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) {
      showErrorSnack(context, "Please fix all errors before submitting");
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = {
      'email': emailController.text.trim(),
      'password': passwordController.text,
    };

    // Show progress indicator dialog
    showLoadingDialog(context, message: 'Signing you in...');

    try {
      final response = await sendDataToApi('https://medrepo.fineworksstudio.com/api/patient/login', payload, method: "POST");
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      if (response['status_code'] == 200 || response['statusCode'] == 201) {
        
        if (response['status'] == true) {
          final userData = response['patient'];          
          /// 1. Store basic profile data
          final profileBox = Hive.box('profile');
          await profileBox.putAll({
            'id': userData['id'],
            'name': userData['name'],
            'email': userData['email'],
            'date_of_birth': userData['date_of_birth'],
            'gender': userData['gender'],
            'phone': userData['phone'],
            'identifier': userData['identifier'],
            'age': userData['age']
          });

          // 2. Handle Medications
          final medicationsBox = Hive.box('medications');
          await medicationsBox.clear(); // Clear old data before saving new sync

          if (userData['medications'] != null) {
            for (var med in userData['medications']) {
              // We use the 'id' from the database as the key for easy lookup/update
              await medicationsBox.put(med['id'], med);
            }
          }

          try {
              for (var i = 0; i < medicationsBox.length; i++) {
                final med = medicationsBox.getAt(i);
                if (med != null) {
                  await _rescheduleNotificationsForMedication(med);
                }
              }
            } catch (e) {}
          // 3. Handle Routine Tests
          final testsBox = Hive.box('tests');
          await testsBox.clear(); // Clear old data

          if (userData['routine_tests'] != null) {
            for (var test in userData['routine_tests']) {
              await testsBox.put(test['id'], test);
            }
          }

          // 4. Store token securely
          final tokenBox = Hive.box('token');
          await tokenBox.put('api_token', response['token']);

          // Mark as logged in
          final authBox = Hive.box('register');
          await authBox.put('isRegistered', true);
          
          // 5. Save email for next login (keep it even after successful login)
          await authBox.put('saved_email', userData['email']);

          // Success message
          if (mounted) {
            showSuccessSnack(context, "Login successful");
          }
          
          // Small delay to show success message
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (!mounted) return;
          
          // Navigate to RootPage
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => RootPage(),
            ),
            (route) => false, // Remove all previous routes
          );
          
        } else {
          // Backend returned error but with 200/201
          if (mounted) {
            showErrorSnack(context, response['data'] ?? 'Login failed.');
          }
        }
      } else {
        // Show server message if present
        String message = 'Login failed. Please check your credentials.';
        try {
          final err = response;
          if (err['data'] != null) message = err['data'];
          if (err['message'] != null) message = err['message'];
        } catch (_) {}
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {      
      if (!mounted) return;
      // Make sure to close loading dialog on error
      hideLoadingDialog(context);
      showErrorSnack(context, "Network error, please try again");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mintGreen,
      extendBodyBehindAppBar: true, 
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.deepGreen),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Top Right Blob
          Positioned(
            top: -100,
            right: -100,
            child: Opacity(
              opacity: 0.3,
              child: CustomPaint(
                size: const Size(300, 300),
                painter: BlobPainter(color: AppColors.deepGreen),
              ),
            ),
          ),
          
          // Bottom Left Blob
          Positioned(
            bottom: -120,
            left: -120,
            child: Opacity(
              opacity: 0.3,
              child: CustomPaint(
                size: const Size(300, 300),
                painter: BlobPainter(color: AppColors.primaryGreen),
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24.0, 
                8.0, 
                24.0, 
                8.0 + MediaQuery.of(context).viewInsets.bottom
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    
                    // ANIMATED LOGO
                    const Center(
                      child: AnimatedLogo(size: 60,),
                    ),
                    const SizedBox(height: 24),
                    
                    // Welcome text
                    Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // EMAIL - Now with prefilled value
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: AppColors.deepGreen,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: AppColors.darkGreen),
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.deepGreen),
                        filled: true,
                        fillColor: AppColors.primaryGreen.withValues(alpha: 0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        // Add a suffix icon to allow clearing the email if needed
                        suffixIcon: emailController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: AppColors.darkGreen),
                                onPressed: () {
                                  setState(() {
                                    emailController.clear();
                                  });
                                },
                              )
                            : null,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter your email';
                        if (!v.contains('@') || !v.contains('.')) return 'Please enter a valid email';
                        return null;
                      },
                      onChanged: (value) {
                        // Update UI to show/hide clear button
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 18),

                    // PASSWORD
                    _PasswordField(controller: passwordController),
                    const SizedBox(height: 12),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password recovery coming soon!'),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.deepGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // LOGIN BUTTON
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.softGreen,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(color: AppColors.darkGreen),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => RegistrationScreen()),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.deepGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------- Blob Painter -----------------------------
class BlobPainter extends CustomPainter {
  final Color color;

  BlobPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    path.moveTo(size.width * 0.5, size.height * 0.1);
    
    path.cubicTo(
      size.width * 0.8, size.height * 0.1,
      size.width * 0.9, size.height * 0.3,
      size.width * 0.85, size.height * 0.5,
    );
    
    path.cubicTo(
      size.width * 0.8, size.height * 0.7,
      size.width * 0.7, size.height * 0.85,
      size.width * 0.5, size.height * 0.9,
    );
    
    path.cubicTo(
      size.width * 0.3, size.height * 0.95,
      size.width * 0.15, size.height * 0.8,
      size.width * 0.1, size.height * 0.6,
    );
    
    path.cubicTo(
      size.width * 0.05, size.height * 0.4,
      size.width * 0.2, size.height * 0.15,
      size.width * 0.5, size.height * 0.1,
    );
    
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----------------------------- Helper widget -----------------------------

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  const _PasswordField({Key? key, required this.controller}) : super(key: key);

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      cursorColor: AppColors.deepGreen,
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: AppColors.darkGreen),
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.deepGreen),
        filled: true,
        fillColor: AppColors.primaryGreen.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.deepGreen,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please enter your password';
        return null;
      },
    );
  }
}