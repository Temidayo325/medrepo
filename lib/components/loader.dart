import 'package:flutter/material.dart';
import './../colors.dart';

/// Shows a themed loading dialog with customizable text
void showLoadingDialog(BuildContext context, {String message = "Please wait..."}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => Dialog(
      elevation: 0,
      backgroundColor: AppColors.mintGreen,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.deepGreen),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.darkGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Hides the currently shown loading dialog
void hideLoadingDialog(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
}
