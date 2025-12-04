import 'package:flutter/material.dart';
import '../../colors.dart';

void showSuccessSnack(BuildContext context, String message, {int seconds = 8}) {
  final rootContext = Navigator.of(context, rootNavigator: true).context;

  ScaffoldMessenger.of(rootContext).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      duration: Duration(seconds: seconds),
    ),
  );
}