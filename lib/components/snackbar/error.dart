import 'package:flutter/material.dart';
import '../../colors.dart';

void showErrorSnack(BuildContext context, String message, {int seconds = 8}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 20, left: 16, right: 16),
        duration: Duration(seconds: seconds),
      ),
    );
}