import 'package:flutter/material.dart';
import 'colors.dart';

import 'home_page.dart';
import 'test_page.dart';
import 'medications_page.dart';
import 'profile_page.dart';
import 'components/navigation_controller.dart';

class RootPage extends StatelessWidget {
  RootPage({super.key});

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
          backgroundColor: AppColors.lightBackground,
          body: pages[selectedIndex],

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
                onTap: (index) =>
                    NavigationController.selectedIndex.value = index,
              ),
            ),
          ),
        );
      },
    );
  }
}
