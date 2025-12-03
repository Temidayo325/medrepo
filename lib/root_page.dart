import 'package:flutter/material.dart';
import 'colors.dart';

import 'home_page.dart';
import 'test_page.dart';
import 'medications_page.dart';
import 'profile_page.dart';
import 'components/navigation_controller.dart';
import 'components/side_bar_navigation.dart'; // Import your sidebar

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List of pages
  final List<Widget> pages = [
    HomePage(),
    TestResultsPage(),
    MedicationPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: NavigationController.selectedIndex,
      builder: (context, selectedIndex, _) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.lightBackground,
          
          // Right-side drawer (endDrawer)
          endDrawer: Drawer(
            child: YourSidebarComponent(), // Replace with your actual sidebar widget
          ),

          body: Stack(
            children: [
              // Main page content
              pages[selectedIndex],

              // Transparent right-edge drag area
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
                  onHorizontalDragEnd: (details) {
                    // Detect left swipe (negative velocity)
                    if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
                      _scaffoldKey.currentState?.openEndDrawer();
                    }
                  },
                  child: Container(
                    width: 40, // Width of the tap/drag area
                    color: Colors.transparent,
                    child: Center(
                      child: Container(
                        width: 3,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Bottom Navigation Bar
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.shade100,
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: AppColors.primaryGreen,
                unselectedItemColor: const Color.fromARGB(255, 0, 72, 3),
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Tests'),
                  BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Medication'),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                ],
                currentIndex: selectedIndex,
                onTap: (index) {
                  NavigationController.selectedIndex.value = index;
                  // Close drawer if open when switching pages
                  if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

