import 'package:flutter/material.dart';
import '../../colors.dart';

class MedicationDetailsSheet extends StatelessWidget {
  final String name;
  final String duration;
  final String form;
  final int quantity;
  final String durationOfTherapy;
  final String createdAt;
  final String dosageStrength;

  const MedicationDetailsSheet({
    super.key,
    required this.name,
    required this.duration,
    required this.form,
    required this.quantity,
    required this.durationOfTherapy,
    required this.createdAt,
    required this.dosageStrength,
  });

  Image getDosageFormImage(String form, {double size = 60}) {
    String assetName;

    switch (form.toLowerCase()) {
      case 'tablet':
        assetName = 'assets/dosage_form/tablet.png';
      case 'injection':
        assetName = 'assets/dosage_form/injection.png';
      case 'capsule':
        assetName = 'assets/dosage_form/capsule.png';
      case 'syrup':
        assetName = 'assets/dosage_form/syrup.png';
      case 'ointment':
        assetName = 'assets/dosage_form/ointment.png';
      default:
        assetName = 'assets/dosage_form/tablet.png';
    }

    return Image.asset(
      assetName,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// --- DRAG HANDLE ---
              Center(
                child: Container(
                  width: 70,
                  height: 8,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              /// --- Row with Image & Basic Info ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  getDosageFormImage(form, size: 200),
                  SizedBox(width: 0),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 35),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Drug Name',
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.grey),
                          ),
                          SizedBox(height: 4),
                          Text(
                            name,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                          ),
                          SizedBox(height: 25),
                          Text(
                            'Dosage Strength',
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.grey),
                          ),
                          SizedBox(height: 4),
                          Text(
                            dosageStrength,
                            style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// --- Additional Details ---
              _buildDetailRow('Dosage form', form),
              _buildDetailRow('Dose', duration),
              _buildDetailRow('Duration of therapy', durationOfTherapy),
              _buildDetailRow('Quantity', 'Total: $quantity'),
              _buildDetailRow('Created At', createdAt),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
