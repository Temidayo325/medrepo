import 'package:flutter/material.dart';
import 'package:medrepo/components/send_post_request.dart';
import 'package:medrepo/login.dart';
import 'colors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'root_page.dart';
import 'components/loader.dart';
import 'components/animated_logo.dart';
import 'components/snackbar/error.dart';
import 'components/snackbar/success.dart';
import 'components/screen_blobs.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // ---- Shared controllers (kept in parent to persist values) ----
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();
  String? selectedGender;
  DateTime? selectedDate;

  // ---- Form keys ----
  final GlobalKey<FormState> _formKeyStep1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyStep2 = GlobalKey<FormState>();

  // Current step index: 0 = step 1, 1 = step 2
  int _currentStep = 0;

  // Animation duration for switcher
  final Duration switchDuration = const Duration(milliseconds: 420);

  // Keep track of loading / submission state
  bool _isSubmitting = false;

  @override
  void dispose() {
    // Dispose all controllers
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // ---- Navigation helpers ----
  void _goToStep(int step) {
    setState(() => _currentStep = step);
  }

  Future<void> _nextFromStep1() async {
    // Validate step1 form (live validation also active)
    if (_formKeyStep1.currentState?.validate() ?? false) {
      _goToStep(1);
    } else {
      // if you want to show a little feedback when validation fails:
      showErrorSnack(context, 'Please fix errors before continuing');
    }
  }

  void _backToStep1() {
    _goToStep(0);
  }

  // ---- Date picker for step 2 ----
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.deepGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  // ---- Submit with logging ----
  Future<void> _submitRegistration() async {
    // Validate step2 before submit
    if (!(_formKeyStep2.currentState?.validate() ?? false)) {
      showErrorSnack(context, 'Please fix errors before submitting');
      return;
    }

    if (selectedGender == null) {
      showErrorSnack(context, 'Please select a gender');
      return;
    }
    if (selectedDate == null) {
      showErrorSnack(context, 'Please pick a date of birth');
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text,
      'phone': phoneController.text.trim(),
      'gender': selectedGender?.toLowerCase(),
      'date_of_birth': selectedDate?.toIso8601String(),
    };
    // Show progress indicator dialog (non-dismissible)
    showLoadingDialog(context, message: 'Creating your account...');

    try {
      final response = await sendDataToApi('https://medrepo.fineworksstudio.com/api/patient/create', payload);

      if (!mounted) return;
      
      // Close loading dialog first
      Navigator.of(context, rootNavigator: true).pop();

      if (response['status'] == true) {
        final res = response;
        
        if (res['status'] == true) {
          final userData = res['data'];
          final token = res['token'];
          
          // Store user data in Hive
          final profileBox = Hive.box('profile');
          await profileBox.putAll({
            'id': userData['id'],
            'name': userData['name'],
            'email': userData['email'],
            'date_of_birth': userData['date_of_birth'],
            'gender': userData['gender'],
            'phone': userData['phone'],
            'identifier': userData['identifier'],
          });
          
          // Store token securely
          final tokenBox = Hive.box('token');
          await tokenBox.put('api_token', token);

          // Mark registration as complete
          final authBox = Hive.box('register');
          await authBox.put('isRegistered', true);

          // Success message
          if (mounted) {
            showSuccessSnack(context, 'Account created successfully!');
          }
          
          // Small delay to show success message
          await Future.delayed(const Duration(milliseconds: 700));
          
          if (!mounted) return;
          // Navigate to RootPage with proper routing
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => RootPage(),
            ),
            (route) => false, // Remove all previous routes
          );
          

        } else {
          // Backend returned error but with 200/201
          if (mounted) {
            showErrorSnack(context, res['data'] ?? 'An error occurred.');
          }
        }
      } else {
        // show server message if present
        String message = 'Registration failed. Please try again.';
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
      // Navigator.of(context, rootNavigator: true).pop();
      hideLoadingDialog(context);
      showErrorSnack(context, 'Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ---- AnimatedSwitcher transition (Scale + Fade) ----
  Widget _transitionBuilder(Widget child, Animation<double> animation) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
        child: child,
      ),
    );
  }

  // ---- Step content widgets ----
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      child: Form(
        key: _formKeyStep1,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 30,),
            Center(
              child: AnimatedLogo(size: 60)
            ),
            const SizedBox(height: 10),
            Text('Step 1 of 2: Basic Information',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 28),

            // NAME
            TextFormField(
              controller: nameController,
              cursorColor: AppColors.deepGreen,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: AppColors.darkGreen),
                prefixIcon: Icon(Icons.person_outlined, color: AppColors.deepGreen),
                filled: true,
                fillColor: AppColors.primaryGreen.withValues(alpha: 0.08),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your name';
                if (v.trim().length < 2) return 'Name must be at least 2 characters';
                return null;
              },
            ),
            const SizedBox(height: 18),

            // EMAIL
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your email';
                if (!v.contains('@') || !v.contains('.')) return 'Please enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 18),

            // PASSWORD
            _PasswordField(controller: passwordController),
            const SizedBox(height: 18),

            // CONFIRM PASSWORD
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              cursorColor: AppColors.deepGreen,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(color: AppColors.darkGreen),
                prefixIcon: Icon(Icons.lock_outline, color: AppColors.deepGreen),
                filled: true,
                fillColor: AppColors.primaryGreen.withValues(alpha: 0.08),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm your password';
                if (v != passwordController.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 28),

            ElevButtonBar(
              primaryLabel: 'Next',
              onPrimaryPressed: _nextFromStep1,
            ),
            SizedBox(height: 10,),
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
                    'Login',
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
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      child: Form(
        key: _formKeyStep2,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: AnimatedLogo(size: 60)
            ),
            const SizedBox(height: 8),
            Text('Step 2 of 2: Additional Details',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 28),

            // PHONE
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              cursorColor: AppColors.deepGreen,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: AppColors.darkGreen),
                prefixIcon: Icon(Icons.phone_outlined, color: AppColors.deepGreen),
                filled: true,
                fillColor: AppColors.primaryGreen.withValues(alpha: 0.08),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your phone number';
                if (v.trim().length < 10) return 'Please enter a valid phone number';
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Gender Dropdown
            DropdownButtonFormField<String>(
              initialValue: selectedGender,
              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Gender',
                labelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: AppColors.darkGreen),
                prefixIcon: Icon(Icons.wc_outlined, color: AppColors.deepGreen),
                filled: true,
                fillColor: AppColors.softGreen,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.deepGreen),
              dropdownColor: AppColors.softGreen,
              items: const [
                DropdownMenuItem(
                  value: 'Male',
                  child: Text('Male', style: TextStyle(fontWeight: FontWeight.normal)),
                ),
                DropdownMenuItem(
                  value: 'Female',
                  child: Text('Female', style: TextStyle(fontWeight: FontWeight.normal)),
                ),
                DropdownMenuItem(
                  value: 'Other',
                  child: Text('Other', style: TextStyle(fontWeight: FontWeight.normal)),
                ),
                DropdownMenuItem(
                  value: 'Prefer not to say',
                  child: Text('Prefer not to say', style: TextStyle(fontWeight: FontWeight.normal)),
                ),
              ],
              onChanged: (val) => setState(() => selectedGender = val),
              validator: (v) => v == null ? 'Please select your gender' : null,
            ),
            const SizedBox(height: 18),

            // Date of Birth (InputDecorator + InkWell)
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  labelStyle: TextStyle(color: AppColors.darkGreen),
                  prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.deepGreen),
                  filled: true,
                  fillColor: AppColors.primaryGreen.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                child: Text(
                  selectedDate == null ? 'Select date' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  style: TextStyle(color: selectedDate == null ? Colors.grey : Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _backToStep1,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.deepGreen),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Back', style: TextStyle(color: AppColors.darkGreen)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Complete', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.softGreen)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(color: AppColors.darkGreen),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      );
                    },
                    child: Text(
                      'Login',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Progress indicator widgets
    final progress = Row(
      children: [
        Expanded(
          child: Container(height: 6, decoration: BoxDecoration(color: _currentStep >= 0 ? AppColors.deepGreen : AppColors.softGreen, borderRadius: BorderRadius.circular(2))),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(height: 6, decoration: BoxDecoration(color: _currentStep == 1 ? AppColors.darkGreen : AppColors.softGreen, borderRadius: BorderRadius.circular(2))),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.mintGreen,
      extendBodyBehindAppBar: true, // Crucial for letting the background go behind the AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep == 1
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.deepGreen),
                onPressed: _backToStep1,
              )
            : null,
      ),
      body: Stack(
        fit: StackFit.expand, // Ensures the stack covers the entire screen area
        children: [
          // 1. Blob Background Component
          BlobBackground(),

          // 2. Main content overlaid on top
          Positioned.fill(
            child: SafeArea(
              child: Column( // This contains the original layout elements
                children: [
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12), child: progress),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      // AnimatedSwitcher gives us fade+scale transitions
                      child: AnimatedSwitcher(
                        duration: switchDuration,
                        transitionBuilder: _transitionBuilder,
                        layoutBuilder: (currentChild, previousChildren) {
                          // allow overlapping fade/scale during transitions
                          return Stack(children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ]);
                        },
                        child: _currentStep == 0
                            ? KeyedSubtree(key: const ValueKey(0), child: _buildStep1())
                            : KeyedSubtree(key: const ValueKey(1), child: _buildStep2()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------- Helper widgets -----------------------------

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
        fillColor: AppColors.primaryGreen.withValues(alpha: 0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.deepGreen),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please enter a password';
        if (v.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }
}

class ElevButtonBar extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  const ElevButtonBar({Key? key, required this.primaryLabel, required this.onPrimaryPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPrimaryPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(primaryLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.softGreen)),
      ),
    );
  }
}