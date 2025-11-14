import 'package:flutter/material.dart';

class IconTextCard extends StatelessWidget {
  final String name;        // Bold text
  final String duration;     // Smaller text
  final String form;        

  const IconTextCard({
    Key? key,
    required this.name,
    required this.duration,
    required this.form,
  }) : super(key: key);

  IconData getDosageFormIcon(String form) {
    switch (form.toLowerCase()) {
      case 'tablet':
        return Icons.medication_rounded;
      case 'injection':
        return Icons.vaccines_rounded;
      case 'capsule':
        return Icons.local_pharmacy_rounded;
      case 'syrup':
        return Icons.local_drink_rounded;
      case 'ointment':
        return Icons.science_rounded;
      default:
        return Icons.health_and_safety_rounded;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          getDosageFormIcon(form),
          size: 40,
          color: Colors.blueGrey.shade700,
        ),
        SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.blueGrey.shade800,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Text(
          duration,
          style: TextStyle(
            fontSize: 14,
            color: Colors.blueGrey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
