import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:medrepo/components/side_bar_navigation.dart';
import 'dart:async'; 
import '../loader.dart';
import '../send_post_request.dart';
// Assuming these are external imports, we keep them:
import '../../colors.dart'; 
import '../snackbar/error.dart'; 
import '../snackbar/success.dart';

// Assuming EmptyState is defined elsewhere (e.g., 'empty_state.dart')
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.color = AppColors.mediumGray,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // FIX: Replaced color.withValues(alpha: 0.6) with color.withOpacity(0.6)
        Icon(icon, size: 50, color: color.withValues(alpha: 0.6)),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: color),
        ),
      ],
    );
  }
}
/// Handles the full workflow: Security check -> Data Fetching -> Displaying the Viral Panel.
Future<void> showSecureViralPanel({
  required BuildContext context,
}) async {
  final LocalAuthentication auth = LocalAuthentication();
  const List<String> allowedShortNames = ['hpv', 'hiv', 'hbv'];

  Future<List<Map<String, String>>> fetchViralPanelData() async {
    try {
      final response = await sendDataToApi("https://medrepo.fineworksstudio.com/api/patient/special_test", {}, method: "GET");
      if (response['statuus'] == true && response['status_code'] == 200 && response['data'] is List) {
         return List<Map<String, String>>.from(response['data']);
      } else {
         // API indicated failure or data was not a List, return empty list
         return []; 
    }
  } catch (e) {
      // Critical: Network error or exception occurred, return empty list
     return []; 
  }
  }

  // Filters the raw data to only include 'hpv', 'hiv', 'hbv'.
  List<Map<String, String>> filterPanelData(List<Map<String, String>> rawData) {
    return rawData.where((test) {
      final shortName = test['short_name']?.toLowerCase() ?? '';
      return allowedShortNames.contains(shortName);
    }).toList();
  }
  
  // Displays the bottom sheet with the filtered data.
  Future<void> showViralPanelBottomSheet(List<Map<String, String>> viralPanel) async {
    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final filteredPanel = viralPanel;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag indicator
                  Center(
                    child: Container(
                      width: 70,
                      height: 6,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Title
                  const Text(
                    "Viral Panel",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepGreen,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Content Display (GridView or EmptyState)
                  filteredPanel.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60.0),
                          child: EmptyState(
                            icon: Icons.search_off_rounded,
                            message: "No results available for HPV, HIV, or HBV at this time.",
                            color: AppColors.mediumGray,
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 40),
                          itemCount: filteredPanel.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            mainAxisExtent: 130,
                          ),
                          itemBuilder: (context, index) {
                            final test = filteredPanel[index];
                            final shortName = test['short_name']?.toUpperCase() ?? '--';
                            final result = test['result'] ?? '';
                            final date = test['date'] ?? '--';

                            final bool isPositive = result.toUpperCase().contains('POSITIVE');
                            final Color cardColor = isPositive ? AppColors.error : AppColors.primaryGreen;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: cardColor.withOpacity(0.4), 
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Short Name with virus icon
                                  Row(
                                    children: [
                                      const Icon(Icons.bug_report, size: 16, color: Colors.white),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          shortName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Result centered
                                  Center(
                                    child: Text(
                                      result,
                                      style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  // Date with calendar icon
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_month, size: 14, color: Colors.white70),
                                      const SizedBox(width: 6),
                                      Text(
                                        date,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  try {
    // Step 1: Check security availability
    final bool canCheckBiometrics = await auth.canCheckBiometrics;
    final bool isDeviceSupported = await auth.isDeviceSupported();

    final bool hasSecurity = canCheckBiometrics && isDeviceSupported;
    bool proceedToFetch = false;
    
    if (hasSecurity) {
      // Device has security - Trigger Biometric/PIN Auth
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Authenticate to access sensitive viral panel results.',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      proceedToFetch = didAuthenticate;
      if (didAuthenticate) {
        // Use imported function
        showSuccessSnack(context, "Authentication successful. Fetching data...");
      } else {
        // Use imported function
        showErrorSnack(context, 'Authentication failed or canceled.');
      }

    } else {
      // Device has NO security - Show Confirmation Dialog
      final bool? confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Security Warning'),
            content: const Text(
              'Your device screen lock is not enabled. Proceeding will expose sensitive data without protection. Do you want to continue?',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel', style: TextStyle(color: AppColors.deepGreen)),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Proceed Anyway', style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );
      proceedToFetch = confirmed == true;
      showLoadingDialog(context, message: "Loading viral panel");
      if (confirmed == true) {
        // Use imported function
        showSuccessSnack(context, "Security bypass confirmed. Fetching data...");
      } else {
        // Use imported function
        showErrorSnack(context, "Access denied by user confirmation.");
      }
    }

    if (!context.mounted) return;

    if (proceedToFetch) {
      // Auth/Confirmation successful - Fetch and filter data
      final rawData = await fetchViralPanelData();
      final filteredData = filterPanelData(rawData);
     hideLoadingDialog(context);
      // Display the bottom sheet with the results
      await showViralPanelBottomSheet(filteredData);
    }

  } catch (e) {
    if (!context.mounted) return;
    // Use imported function
    showErrorSnack(context, 'Access error: ${e.toString()}');
  } finally {
    hideLoader(context);
  }
}

// ==========================================================
// EXAMPLE IMPLEMENTATION 
// ==========================================================
class SecureContentAccessPage extends StatefulWidget {
  const SecureContentAccessPage({super.key});

  @override
  State<SecureContentAccessPage> createState() => _SecureContentAccessPageState();
}

class _SecureContentAccessPageState extends State<SecureContentAccessPage> {
  bool _isChecking = false;

  void _handlePanelAccess() async {
    // This wrapper function handles the local state update (loading spinner)
    // before calling the public service function.
    if (_isChecking) return;
    setState(() => _isChecking = true);
    
    await showSecureViralPanel(
      context: context
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGreen,
      appBar: AppBar(
        title: const Text('Secure Content Access Demo'),
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
                'View Sensitive Health Data',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.deepGreen),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap to access and view the latest Viral Panel results securely. Authentication and data fetch happen before the panel is displayed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.darkGray),
              ),
              const SizedBox(height: 40),

              // Button to trigger the access logic
              ElevatedButton.icon(
                onPressed: _isChecking ? null : _handlePanelAccess,
                icon: _isChecking
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.security, color: Colors.white),
                label: Text(
                  _isChecking ? 'Authenticating & Fetching...' : 'Access Viral Panel',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}