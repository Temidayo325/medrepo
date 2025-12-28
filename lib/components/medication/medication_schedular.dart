import 'package:hive/hive.dart';
import '../notifications.dart'; // Ensure this points to your NotificationService file

class MedicationScheduler {
  /// The main entry point to rebuild the schedule.
  /// Call this in main.dart or after a successful login.
  static Future<void> refreshAllSchedules() async {
    try {
      final medicationsBox = Hive.box('medications');
      // Clear all existing to prevent duplicate alarms
      await NotificationService.cancelAllNotifications();

      for (var i = 0; i < medicationsBox.length; i++) {
        // Handle both Map and HiveObjects
        final dynamic medRaw = medicationsBox.getAt(i);
        if (medRaw != null) {
          // Convert to Map if necessary (standardizes Hive behavior)
          final Map<String, dynamic> med = Map<String, dynamic>.from(medRaw);
          await _rescheduleNotificationsForMedication(med);
        }
      }
    } catch (e) { }
  }

  static Future<void> _rescheduleNotificationsForMedication(Map<String, dynamic> med) async {
    try {
      final int totalDays = _parseDurationToDays(med['duration_of_therapy'] ?? '7 days');
      final int timesPerDay = _parseFrequencyToInt(med['frequency'] ?? 'once');
      final String medicationId = med['id'].toString();
      
      // Use hashCode for a unique base ID, but ensure it's within 32-bit int range
      final int baseAlarmId = medicationId.hashCode.abs() % 100000;

      final DateTime startDate = DateTime.parse(med['created_at'] ?? DateTime.now().toIso8601String());
      final DateTime endDate = startDate.add(Duration(days: totalDays));

      // Check if the treatment course is still ongoing
      if (DateTime.now().isBefore(endDate)) {
        int notificationCount = 0;

        for (int d = 0; d < totalDays; d++) {
          for (int t = 0; t < timesPerDay; t++) {
            // Android has a limit on total exact alarms (usually 50-100 per app)
            if (notificationCount >= 100) break;

            final int hourOffset = (t * (24 ~/ timesPerDay));
            DateTime scheduledTime = startDate.add(Duration(days: d, hours: hourOffset));

            // Only schedule if the specific dose time is in the future
            if (scheduledTime.isAfter(DateTime.now())) {
              await NotificationService.scheduleMedicationReminder(
                id: baseAlarmId + notificationCount,
                medicationId: medicationId,
                medicationName: med['name'] ?? 'Medication',
                scheduledTime: scheduledTime,
                dosage: med['dosage_strength'],
              );
            }
            notificationCount++;
          }
        }
      }
    } catch (e) {}
  }

  // --- Helper Parsers ---

  static int _parseDurationToDays(String duration) {
    final lower = duration.toLowerCase();
    final match = RegExp(r'\d+').firstMatch(duration);
    if (match == null) return 7;

    final number = int.tryParse(match.group(0)!) ?? 7;

    if (lower.contains('week')) return number * 7;
    if (lower.contains('month')) return number * 30;
    if (lower.contains('year')) return number * 365;

    return number;
  }

  static int _parseFrequencyToInt(String frequency) {
    final lower = frequency.toLowerCase();
    if (lower.contains('once')) return 1;
    if (lower.contains('twice')) return 2;
    if (lower.contains('thrice')) return 3;

    final match = RegExp(r'\d+').firstMatch(frequency);
    if (match != null) {
      return int.tryParse(match.group(0)!) ?? 1;
    }

    return 1;
  }

  static int frequencyToInt(String frequency) {
    return _parseFrequencyToInt(frequency);
  }

  static int durationToDays(String duration) {
    return _parseDurationToDays(duration);
  }
}