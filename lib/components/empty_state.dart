// empty_state.dart
import 'package:flutter/material.dart';
import '../colors.dart'; // adjust path as needed

/// A reusable empty state widget to display an icon and a message.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final double iconSize;
  final Color color;
  final EdgeInsetsGeometry padding;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.message,
    this.iconSize = 32,
    this.color = AppColors.primaryGreen,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
