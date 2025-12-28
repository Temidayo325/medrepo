import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../colors.dart';
import '../snackbar/success.dart';
// import '../snackbar/error.dart';
// import 'sync_medication_log.dart';
import '../notifications.dart';
import 'medication_schedular.dart';


class MedicationDetailsSheet extends StatefulWidget {
  final String medicationId;
  final String name;
  final String frequency;
  final String dosage_form;
  final int quantity;
  final String durationOfTherapy;
  final String createdAt;
  final String dosageStrength;

  const MedicationDetailsSheet({
    super.key,
    required this.medicationId,
    required this.name,
    required this.frequency,
    required this.dosage_form,
    required this.quantity,
    required this.durationOfTherapy,
    required this.createdAt,
    required this.dosageStrength,
  });

  @override
  State<MedicationDetailsSheet> createState() => _MedicationDetailsSheetState();
}

class _MedicationDetailsSheetState extends State<MedicationDetailsSheet> {
  // final SyncService _syncService = SyncService();
  
  List<Map<String, dynamic>> _generateScheduledDoses() {
    try {
      final startDate = DateTime.parse(widget.createdAt);
      final days = MedicationScheduler.durationToDays(widget.durationOfTherapy);
      final timesPerDay = MedicationScheduler.frequencyToInt(widget.frequency);
      final endDate = startDate.add(Duration(days: days));
      
      List<Map<String, dynamic>> doses = [];
      
      for (int d = 0; d < days; d++) {
        for (int t = 0; t < timesPerDay; t++) {
          final hourOffset = (t * (24 ~/ timesPerDay));
          final scheduledTime = startDate.add(Duration(days: d, hours: hourOffset));
          
          // Only include doses up to now (can't mark future doses as taken)
          if (scheduledTime.isBefore(DateTime.now()) && 
              scheduledTime.isBefore(endDate)) {
            doses.add({
              'scheduled_time': scheduledTime,
              'dose_number': t + 1,
              'day_number': d + 1,
            });
          }
        }
      }
      
      return doses.reversed.toList(); // Show most recent first
    } catch (e) {
      return [];
    }
  }
  
  bool _isDoseTaken(DateTime scheduledTime) {
    final logBox = Hive.box('medication_logs');
    final logs = logBox.values.where((log) {
      if (log['medication_id'] != widget.medicationId) return false;
      if (log['status'] != 'taken') return false;
      
      try {
        final logScheduledTime = DateTime.parse(log['scheduled_at']);
        // Check if within 30 minutes of scheduled time
        final difference = logScheduledTime.difference(scheduledTime).abs();
        return difference.inMinutes <= 30;
      } catch (e) {
        return false;
      }
    });
    
    return logs.isNotEmpty;
  }

  Image getDosageFormImage(String dosage_form, {double size = 60}) {
    String assetName;

    switch (dosage_form.toLowerCase()) {
      case 'tablet':
        assetName = 'assets/dosage_form/tablet.png';
      case 'injection':
        assetName = 'assets/dosage_form/injection.png';
      case 'capsule':
        assetName = 'assets/dosage_form/capsule.png';
      case 'syrup':
        assetName = 'assets/dosage_form/syrup.png';
      case 'suspension':
        assetName = 'assets/dosage_form/syrup.png';
      case 'cream':
      case 'lotion':
      case 'ointment':
        assetName = 'assets/dosage_form/ointment.png';
      case 'gutt':
        assetName = 'assets/dosage_form/syrup.png';
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

  String _getFormattedQuantity() {
    final formLower = widget.dosage_form.toLowerCase();
    
    switch (formLower) {
      case 'tablet':
        return widget.quantity == 1 ? '1 tablet' : '${widget.quantity} tablets';
      case 'capsule':
        return widget.quantity == 1 ? '1 capsule' : '${widget.quantity} capsules';
      case 'injection':
        return widget.quantity == 1 ? '1 injection' : '${widget.quantity} injections';
      case 'syrup':
      case 'suspension':
        return '${widget.quantity}mL';
      case 'cream':
      case 'lotion':
      case 'ointment':
        return '${widget.quantity}g';
      case 'gutt':
        return widget.quantity == 1 ? '1 drop' : '${widget.quantity} drops';
      default:
        return '${widget.quantity}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduledDoses = _generateScheduledDoses();
    
    return ValueListenableBuilder(
      valueListenable: Hive.box('medication_logs').listenable(),
      builder: (context, Box box, _) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SafeArea(
            top: false,
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

                /// --- Scrollable Content ---
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// --- Row with Image & Basic Info ---
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            getDosageFormImage(widget.dosage_form, size: 200),
                            SizedBox(width: 0),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 35),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Drug Name',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        color: Colors.grey
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      widget.name,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryGreen
                                      ),
                                    ),
                                    SizedBox(height: 25),
                                    Text(
                                      'Dosage Strength',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        color: Colors.grey
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      widget.dosageStrength,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryGreen
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// --- Additional Details ---
                        _buildDetailRow('Dosage form', widget.dosage_form),
                        _buildDetailRow('Dose', widget.frequency),
                        _buildDetailRow('Duration of therapy', widget.durationOfTherapy),
                        _buildDetailRow('Quantity', _getFormattedQuantity()),
                        _buildDetailRow('Created At', widget.createdAt),

                        /// --- Dose History Section ---
                        if (scheduledDoses.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Divider(color: Colors.grey[300], thickness: 1),
                          const SizedBox(height: 16),
                          
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dose History',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Mark missed doses as taken',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Dose list
                          ...List.generate(
                            scheduledDoses.length > 10 ? 10 : scheduledDoses.length,
                            (index) {
                              final dose = scheduledDoses[index];
                              final scheduledTime = dose['scheduled_time'] as DateTime;
                              final isTaken = _isDoseTaken(scheduledTime);
                              final isToday = _isToday(scheduledTime);
                              
                              return _buildDoseItem(
                                scheduledTime: scheduledTime,
                                doseNumber: dose['dose_number'],
                                dayNumber: dose['day_number'],
                                isTaken: isTaken,
                                isToday: isToday,
                              );
                            },
                          ),
                          
                          if (scheduledDoses.length > 10)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Center(
                                child: Text(
                                  'Showing last 10 doses',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                        ],

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  Widget _buildDoseItem({
    required DateTime scheduledTime,
    required int doseNumber,
    required int dayNumber,
    required bool isTaken,
    required bool isToday,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 25, right: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isTaken 
            ? AppColors.primaryGreen.withValues(alpha: 0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isToday 
              ? AppColors.primaryGreen 
              : Colors.transparent,
          width: isToday ? 2 : 0,
        ),
      ),
      child: Row(
        children: [
          // Checkbox/Status indicator
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTaken 
                  ? AppColors.primaryGreen 
                  : Colors.white,
              border: Border.all(
                color: isTaken 
                    ? AppColors.primaryGreen 
                    : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: isTaken
                ? Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
          
          const SizedBox(width: 12),
          
          // Time and dose info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _formatTime(scheduledTime),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepGreen,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'TODAY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(scheduledTime)} • Dose $doseNumber',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Action button
          if (!isTaken)
            TextButton(
              onPressed: () async {
                await NotificationService.markAsTaken(widget.medicationId, widget.name,scheduledTime.toIso8601String());
                if(mounted)
                {
                  showSuccessSnack(context, 'Dose marked as taken'); setState(() {});
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Mark',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          
          if (isTaken)
            Icon(
              Icons.check_circle,
              color: AppColors.primaryGreen,
              size: 18,
            ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour12:$minute $period';
  }
  
  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
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