import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../colors.dart';
import '../login.dart';
import '../symptoms_diary.dart';
import 'snackbar/error.dart';
import 'snackbar/success.dart';
import 'send_post_request.dart';
import 'profile/profile_picure.dart';
import '../about.dart';
import '../contact.dart';
import 'notifications.dart';
import 'medication/debug_notifications.dart';


Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
}) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout, size: 48, color: AppColors.primaryGreen),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 10),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.grey[200],
                    ),
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text("Cancel",
                        style: TextStyle(
                            fontSize: 16, color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text("Logout",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ) ??
  false;
}

Future<void> showLoader(BuildContext context) async {
  return showDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
}

void hideLoader(BuildContext context) {
  // Important: Use rootNavigator: true to pop a dialog shown with rootNavigator: true
  Navigator.of(context, rootNavigator: true).pop();
}

//--------------------------------------------------------------
// LOGOUT SERVICE (LOGIC ONLY — NO UI)
//--------------------------------------------------------------

class LogoutService {
  static Future<void> logout() async {
    // 1. Get the email before clearing profile
    final profileBox = Hive.box('profile');
    final email = profileBox.get('email');
    
    final tokenBox = Hive.box('token');
    final token = tokenBox.get('api_token');

    try {
      await NotificationService.cancelAllNotifications();
    } catch (e) {}
    // 2. API logout (runs only if token exists)
    if (token != null) {
      try {
        await sendDataToApi(
          'https://medrepo.fineworksstudio.com/api/patient/logout',
          {},
          method: "POST",
        );
      } catch (e) {
        // Continue with local logout even if API fails
      }
    }

    // 3. Clear all data (regardless of API success)
    final boxesToClear = [
      Hive.box('profile'),
      Hive.box('token'),
      Hive.box('emergencyContacts'),
      await Hive.openBox('tests'),
      await Hive.openBox('symptoms'),
      await Hive.openBox('patientProfile'),
      await Hive.openBox('viralPanel'),
      await Hive.openBox('medications'),
    ];

    for (final box in boxesToClear) {
      await box.clear();
    }
    
    // 4. Save the email for next login (after clearing)
    final authBox = Hive.box('register');
    await authBox.put('isRegistered', false);
    
    if (email != null && email.toString().isNotEmpty) {
      await authBox.put('saved_email', email);
    }
  }
}
//--------------------------------------------------------------
// REFACTORED SIDEBAR COMPONENT
//--------------------------------------------------------------

class YourSidebarComponent extends StatelessWidget {
  const YourSidebarComponent({super.key});

  // Fully refactored _handleLogout to manage async and context safety
  Future<void> _handleLogout(BuildContext context) async {
    // 1. Ask for confirmation
    final shouldLogout = await showConfirmationDialog(
      context: context,
      title: "Confirm Logout",
      message: "Are you sure you want to log out?",
    );
    if (!shouldLogout) return;
    // 2. Context Safety Check: Prevent "deactivated context" errors after the dialog closes.
    if (!context.mounted) return;

    // 3. Show Loader (using the root navigator)
    showLoader(context);

    bool success = false;
    try {
      // 4. Execute decoupled business logic (API, Hive clear)
      await LogoutService.logout();
      success = true;
    } catch (e) {
      // 5. Handle errors during service call
      if (context.mounted) {
        hideLoader(context);
        showErrorSnack(context, "Logout failed: $e");
      }
    }

    // 6. Final UI updates and navigation only if successful
    if (success) {
      // Context Safety Check again after the long API/Hive clear operation
      if (!context.mounted) return;

      hideLoader(context);
      showSuccessSnack(context, "You have logged out successfully");

      // 7. Redirect to Login screen using root navigator (to clear entire stack)
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = Map<String, dynamic>.from(Hive.box('profile').toMap());

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(profile),
            Expanded(child: _buildMenu(context)),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text("MedRepo v1.0", style: TextStyle(color: Colors.grey)),
            )
          ],
        ),
      ),
    );
  }

  //--------------------------------------------------------------
  // HEADER
  //--------------------------------------------------------------

  Widget _buildHeader(Map<String, dynamic> profile) {
    return Container(
      padding: const EdgeInsets.all(40),
      color: AppColors.primaryGreen,
      child: Column(
        children: [
          const ProfileAvatar(),
          const SizedBox(height: 15),
          Text(
            profile['name'] ?? 'Unknown User',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.mintGreen,
            ),
          ),
        ],
      ),
    );
  }

  //--------------------------------------------------------------
  // MENU LIST
  //--------------------------------------------------------------

  Widget _buildMenu(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // _menuTile(context,
            // icon: Icons.home, title: 'Home', onTap: () => Navigator.pop(context)),
        // _menuTile(context,
        //     icon: Icons.help_outline,
        //     title: 'Debug notifications',
        //     onTap: () {
        //       Navigator.pop(context);
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (_) => NotificationDebugScreen()),
        //       );
        //     }),
        _menuTile(context,
            icon: Icons.book,
            title: 'Symptoms Diary',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SymptomsDiaryPage()),
              );
            }),
        _menuTile(context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ContactUsPage()),
              );
            }),
        _menuTile(context,
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AboutUsPage()),
              );
            }),

        const Divider(),

        // LOGOUT
        _menuTile(context,
            icon: Icons.logout,
            iconColor: Colors.red,
            title: 'Logout',
            onTap: () async {
              // Start the safe, async logout process
              await _handleLogout(context);
            }),
      ],
    );
  }

  //--------------------------------------------------------------
  // REUSABLE MENU TILE
  //--------------------------------------------------------------

  Widget _menuTile(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap,
      Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primaryGreen),
      title: Text(title,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: iconColor ?? Colors.black87)),
      onTap: onTap,
      hoverColor: AppColors.primaryGreen.withValues(alpha: .1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}