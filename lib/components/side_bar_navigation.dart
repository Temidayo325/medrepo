import 'package:flutter/material.dart';
import 'profile/profile_picure.dart';
import '../colors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../symptoms_diary.dart';

class YourSidebarComponent extends StatelessWidget {
  const YourSidebarComponent({super.key});
  
  @override
  Widget build(BuildContext context) {
    final box = Hive.box('profile');
    final profile = Map<String, dynamic>.from(box.toMap());
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Sidebar Header
            Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
              ),
              child: Column( 
                  children: [
                      ProfileAvatar(),
                      SizedBox(height: 15,),
                      Text( profile['name'], style: TextStyle( fontSize: 22, fontWeight: FontWeight.bold,
                            color: AppColors.mintGreen,),
                        ),
                      // IconButton(
                      //   icon: Icon(Icons.close, color: Colors.white),
                      //   onPressed: () => Navigator.pop(context),
                      // ),
                  ]
                ),
              ),
            // Sidebar Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildSidebarItem(
                    context,
                    icon: Icons.home,
                    title: 'Home',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate or perform action
                    },
                  ),
                  _buildSidebarItem(
                    context,
                    icon: Icons.book,
                    title: 'Symptoms diary',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SymptomsDiaryPage()),
                      );
                      
                    },
                  ),
                  _buildSidebarItem(
                    context,
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to settings
                    },
                  ),
                  _buildSidebarItem(
                    context,
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to notifications
                    },
                  ),
                  _buildSidebarItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to help
                    },
                  ),
                  _buildSidebarItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to about
                    },
                  ),
                  Divider(height: 32, thickness: 1),
                  _buildSidebarItem(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    iconColor: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      // Perform logout
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Logout'),
                          content: Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                // Perform actual logout
                              },
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'MedRepo v1.0',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primaryGreen, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: iconColor ?? Colors.black87,
        ),
      ),
      onTap: onTap,
      hoverColor: AppColors.primaryGreen.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}