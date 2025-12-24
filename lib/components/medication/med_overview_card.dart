import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../colors.dart';

class IconTextCard extends StatelessWidget {
  final String name;
  final String frequency;
  final String dosage_form;
  final String durationOfTherapy;
  final String medicationId; // ADD THIS - needed to calculate adherence
  final int? quantity;
  final VoidCallback? onTap;
  final Widget? trailing;

  const IconTextCard({
    Key? key,
    required this.name,
    required this.frequency,
    required this.dosage_form,
    required this.durationOfTherapy,
    required this.medicationId, // ADD THIS
    this.quantity,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  Widget getDosageFormImage(String dosage_form) {
    final formLower = dosage_form.toLowerCase();
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
      width: 60,
      height: 60,
      fit: BoxFit.contain,
    );
  }

  // Calculate adherence rate based on logs in Hive
  double _calculateAdherenceRate() {
    try {
      final logBox = Hive.box('medication_logs');
      
      // Get all logs for this medication
      final logs = logBox.values.where((log) {
        return log['medication_id'] == medicationId && log['status'] == 'taken';
      }).toList();

      // Parse frequency to get expected doses per day
      final timesPerDay = _parseFrequencyToInt(frequency);
      
      // Parse duration to get total days
      final totalDays = _parseDurationToDays(durationOfTherapy);
      
      // Calculate expected total doses
      final expectedDoses = timesPerDay * totalDays;
      
      // Actual doses taken
      final actualDoses = logs.length;
      
      if (expectedDoses == 0) return 0.0;
      
      // Calculate percentage
      final adherenceRate = (actualDoses / expectedDoses) * 100;
      
      // Cap at 100%
      return adherenceRate > 100 ? 100.0 : adherenceRate;
    } catch (e) {
      print('Error calculating adherence: $e');
      return 0.0;
    }
  }

  int _parseFrequencyToInt(String frequency) {
    final lower = frequency.toLowerCase();
    if (lower.contains('once')) return 1;
    if (lower.contains('twice') || lower.contains('2')) return 2;
    if (lower.contains('thrice') || lower.contains('three') || lower.contains('3')) return 3;
    if (lower.contains('four') || lower.contains('4')) return 4;
    
    // Try to extract number from string like "5 times daily"
    final match = RegExp(r'\d+').firstMatch(frequency);
    if (match != null) {
      return int.tryParse(match.group(0)!) ?? 1;
    }
    
    return 1; // Default
  }

  int _parseDurationToDays(String duration) {
    final lower = duration.toLowerCase();
    
    // Extract number
    final match = RegExp(r'\d+').firstMatch(duration);
    if (match == null) return 7; // Default to 7 days
    
    final number = int.tryParse(match.group(0)!) ?? 7;
    
    // Convert to days based on unit
    if (lower.contains('week')) return number * 7;
    if (lower.contains('month')) return number * 30;
    if (lower.contains('year')) return number * 365;
    
    // Assume days if no unit specified
    return number;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('medication_logs').listenable(),
      builder: (context, Box box, _) {
        final adherenceRate = _calculateAdherenceRate();
        
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withValues(alpha: 0.3),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top section - Dosage form image
                getDosageFormImage(dosage_form),
                
                // Middle section - Medication info
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primaryGreen,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        frequency,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Bottom section - Adherence wheel
                const SizedBox(height: 8),
                _buildAdherenceWheel(adherenceRate),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdherenceWheel(double rate) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Circle
        SizedBox(
          height: 45,
          width: 45,
          child: CircularProgressIndicator(
            value: rate / 100,
            backgroundColor: Colors.grey[200],
            color: _getAdherenceColor(rate),
            strokeWidth: 5,
          ),
        ),
        // Percentage Text
        Text(
          "${rate.toInt()}%",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Color _getAdherenceColor(double rate) {
    if (rate >= 90) return AppColors.deepGreen;
    if (rate >= 70) return AppColors.primaryGreen;
    if (rate >= 50) return AppColors.warning;
    return AppColors.error;
  }
}