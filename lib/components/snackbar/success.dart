import 'package:flutter/material.dart';
import '../../colors.dart';

void showSuccessSnack(BuildContext context, String message, {int seconds = 8}) {
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Health information updated"),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: seconds),
      ),
    );
}