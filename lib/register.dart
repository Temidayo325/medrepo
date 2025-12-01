import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'root_page.dart';
import 'components/loader.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix errors before continuing')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix errors before submitting')),
      );
      return;
    }

    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gender')),
      );
      return;
    }
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a date of birth')),
      );
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

    // LOG outgoing data (inspect console / debug console)
    debugPrint('=== REGISTER REQUEST BODY ===');
    debugPrint(const JsonEncoder.withIndent('  ').convert(payload));
    debugPrint('=============================');

    // Show progress indicator dialog (non-dismissible)
    showLoadingDialog(context, message: 'Creating your account...');

    try {
      final response = await http.post(
        Uri.parse('https://medrepo.fineworksstudio.com/api/patient/create'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(payload),
      );

      // Log response
      debugPrint('=== REGISTER RESPONSE (status: ${response.statusCode}) ===');
      try {
        final decoded = jsonDecode(response.body);
        debugPrint(const JsonEncoder.withIndent('  ').convert(decoded));
      } catch (_) {
        debugPrint(response.body);
      }
      debugPrint('=======================================================');

      if (!mounted) return;
      
      // Close loading dialog first
      Navigator.of(context, rootNavigator: true).pop();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = jsonDecode(response.body);
        
        debugPrint('=== PARSED RESPONSE ===');
        debugPrint('Status: ${res['status']}');
        debugPrint('Message: ${res['message']}');
        debugPrint('Has data: ${res['data'] != null}');
        debugPrint('Has token: ${res['token'] != null}');
        debugPrint('=====================');
        
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(res['message'] ?? 'Account created successfully!'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          
          // Small delay to show success message
          await Future.delayed(const Duration(milliseconds: 800));
          
          if (!mounted) return;
          
          debugPrint('=== NAVIGATING TO ROOT PAGE ===');
          
          // Navigate to RootPage with proper routing
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => RootPage(),
            ),
            (route) => false, // Remove all previous routes
          );
          
          debugPrint('=== NAVIGATION COMPLETE ===');

        } else {
          // Backend returned error but with 200/201
          debugPrint('Backend error: ${res['message']}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(res['message'] ?? 'An error occurred.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } else {
        // show server message if present
        String message = 'Registration failed. Please try again.';
        try {
          final err = jsonDecode(response.body);
          if (err is Map && err['data'] != null) message = err['data'];
          if (err is Map && err['message'] != null) message = err['message'];
        } catch (_) {}
        
        debugPrint('Server error: $message');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('=== NETWORK ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('====================');
      
      if (!mounted) return;
      
      // Make sure to close loading dialog on error
      Navigator.of(context, rootNavigator: true).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Network error. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
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
            // logo
            Center(
              child: SvgPicture.asset(
                'assets/medrepo_logo.svg',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 8),
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
              child: SvgPicture.asset(
                'assets/medrepo_logo.svg',
                width: 100,
                height: 100,
              ),
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
              value: selectedGender,
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
      body: Column(
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