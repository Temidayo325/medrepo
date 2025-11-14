import 'package:flutter/material.dart';

// Holds the current index of the bottom navigation bar
class NavigationController {
  // Using ValueNotifier to allow listeners to rebuild automatically
  static final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
}
