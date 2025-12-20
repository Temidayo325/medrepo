import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../colors.dart';
import '../snackbar/error.dart';
import '../snackbar/success.dart';
import 'viral_panel.dart';

// Placeholder for the sensitive content component (Your existing ViralPanelComponent)
class ViralPanelComponent extends StatelessWidget {
  const ViralPanelComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.deepGreen.withValues(alpha: 0.5)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.deepGreen, size: 40),
          SizedBox(height: 10),
          Text(
            'Viral Panel Results (Sensitive)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.deepGreen,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This data is highly sensitive and requires explicit user authentication to view. Viewing granted.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// Main page demonstrating the security logic
class SecureContentAccessPage extends StatefulWidget {
  const SecureContentAccessPage({super.key});

  @override
  State<SecureContentAccessPage> createState() => _SecureContentAccessPageState();
}

class _SecureContentAccessPageState extends State<SecureContentAccessPage> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isPanelVisible = false;
  bool _isChecking = false;

  void _showError(String message) {
    if (!mounted) return;
    showErrorSnack(context, message);
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    showSuccessSnack(context, message);
  }

  // CORE LOGIC IMPLEMENTATION
  Future<void> _handlePanelAccess() async {
    if (_isChecking) return;
    setState(() {
      _isChecking = true;
      _isPanelVisible = false; // Hide panel during check
    });

    try {
      // 1. Check if security features are available
      final bool canCheckBiometrics = await auth.canCheckBiometrics;
      final bool isDeviceSupported = await auth.isDeviceSupported();

      final bool hasSecurity = canCheckBiometrics && isDeviceSupported;

      if (hasSecurity) {
        // 2. Device has security features (Biometric/PIN/Pattern) - Trigger Auth
        final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to view sensitive viral panel results.',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false, // Allow device screen lock (PIN/Pattern) fallback
          ),
        );

        if (!mounted) return;

        if (didAuthenticate) {
          // Success: Display the panel
          setState(() => _isPanelVisible = true);
          _showSuccess('Authentication successful. Panel displayed.');
        } else {
          // Failure: Notify
          setState(() => _isPanelVisible = false);
          _showError('Authentication failed or canceled.');
        }
      } else {
        // 3. Device has NO security features - Show Confirmation Dialog
        final bool? proceed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Security Warning'),
              content: const Text(
                'Your device does not have a screen lock (PIN, pattern, or biometrics) enabled. Do you want to continue?',
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel', style: TextStyle(color: AppColors.deepGreen)),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  child: const Text('Proceed Anyway', style: TextStyle(color: Colors.white)),
                  onPressed: () => showViralPanelBottomSheet,
                ),
              ],
            );
          },
        );

        if (!mounted) return;

        if (proceed == true) {
          // Confirmation positive: Display the panel
          setState(() => _isPanelVisible = true);
          _showSuccess('Security bypassed by user confirmation. Panel displayed.');
        } else {
          // Confirmation negative: Notify
          setState(() => _isPanelVisible = false);
          _showError('Access denied by user confirmation.');
        }
      }
    } catch (e) {
      if (!mounted) return;
      // Catch any LocalAuth platform exceptions (e.g., permanent lockout)
      _showError('Security check error: $e');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGreen,
      appBar: AppBar(
        title: const Text('Secure Content Access'),
        backgroundColor: AppColors.deepGreen,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'View Viral panel',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.deepGreen),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap the button below to initiate the security check. You must authenticate or confirm to view the content.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 40),
              
              // Button to trigger the access logic
              ElevatedButton.icon(
                onPressed: _isChecking ? null : _handlePanelAccess,
                icon: _isChecking
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.security, color: Colors.white),
                label: Text(
                  _isChecking ? 'Checking Security...' : 'Access Viral Panel',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Animated display of the sensitive component
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child));
                },
                child: _isPanelVisible
                    ? KeyedSubtree(
                        key: const ValueKey('panel'),
                        child: const ViralPanelComponent(),
                      )
                    : Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_outline, color: Colors.black54, size: 24),
                            SizedBox(width: 10),
                            Text('Content Secured. Authentication Required.', style: TextStyle(color: Colors.black54)),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}