import 'package:flutter/material.dart';

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
        break;
      case 'injection':
        assetPath = 'assets/dosage_form/injection.png';
        break;
      case 'capsule':
        assetPath = 'assets/dosage_form/capsule.png';
        break;
      case 'syrup':
        assetPath = 'assets/dosage_form/syrup.png';
        break;
      case 'ointment':
        assetPath = 'assets/dosage_form/ointment.png';
        break;
      default:
        assetPath = 'assets/dosage_form/tablet.png';
    }

    return Image.asset(
      assetPath,
      width: 40,
      height: 40,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,   // pass modal trigger here
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.blueGrey.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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
                fontSize: 15,
                color: Colors.blueGrey.shade800,
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
                color: Colors.blueGrey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
