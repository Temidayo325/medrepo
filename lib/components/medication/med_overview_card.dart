import 'package:flutter/material.dart';
import '../../colors.dart';

class IconTextCard extends StatelessWidget {
  final String name;
  final String duration;
  final String form;
  final String durationOfTherapy;
  final int? quantity; // optional
  final VoidCallback? onTap;
  final Widget? trailing;

  const IconTextCard({
    Key? key,
    required this.name,
    required this.duration,
    required this.form,
    required this.durationOfTherapy,
    this.quantity,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  /// Returns an Image widget based on the dosage form
  Widget getDosageFormImage(String form) {
    final formLower = form.toLowerCase();
    String assetPath;

    switch (formLower) {
      case 'tablet':
        assetPath = 'assets/dosage_form/tablet.png';
      case 'injection':
        assetPath = 'assets/dosage_form/injection.png';
      case 'capsule':
        assetPath = 'assets/dosage_form/capsule.png';
      case 'syrup':
        assetPath = 'assets/dosage_form/syrup.png';
      case 'ointment':
        assetPath = 'assets/dosage_form/ointment.png';
      default:
        assetPath = 'assets/dosage_form/tablet.png';
    }

    return Image.asset(
      assetPath,
      width: 50,
      height: 50,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,   // pass modal trigger here
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            getDosageFormImage(form), // <-- now uses image
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.primaryGreen,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              duration,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
