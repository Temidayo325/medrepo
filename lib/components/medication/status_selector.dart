import 'package:flutter/material.dart';
import '../../colors.dart';

// 1. Define an Enum for safety
enum MedicationStatus { all, active, completed }

class StatusSelector extends StatelessWidget {
  final MedicationStatus selectedStatus;
  
  final Function(MedicationStatus) onStatusSelected;

  StatusSelector({
    required this.selectedStatus,
    required this.onStatusSelected,
  });
  
  // Helper to convert Enum to display string
  String _getStatusName(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.all: return 'All';
      case MedicationStatus.active: return 'Active';
      case MedicationStatus.completed: return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      width: double.infinity,
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: MedicationStatus.values.map((status) {
            final isSelected = selectedStatus == status;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ChoiceChip(
                label: Text(_getStatusName(status)),
                selected: isSelected,
                onSelected: (_) => onStatusSelected(status),
                selectedColor: AppColors.primaryGreen,
                backgroundColor: AppColors.mintGreen,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.deepGreen,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                // Removes default checkmark for a cleaner look
                showCheckmark: false, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}