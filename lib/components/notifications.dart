import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:timezone/timezone.dart' as tz;
import 'medication/sync_medication_log.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static final SyncService _syncService = SyncService();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationAction,
    );

    // Request permissions for Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation
            <AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> _handleNotificationAction(
      NotificationResponse response) async {
    final payload = response.payload;
    final actionId = response.actionId;

    if (payload == null) return;

    // Parse payload to get medication details
    final parts = payload.split('|');
    if (parts.length < 3) return;

    final medicationId = parts[0];
    final medicationName = parts[1];
    final scheduledTime = parts[2];

    if (actionId == 'taken') {
      await _markAsTaken(medicationId, medicationName, scheduledTime);
    } else if (actionId == 'snooze') {
      await _snoozeNotification(medicationId, medicationName, scheduledTime);
    }
  }

  static Future<void> _markAsTaken(
      String medicationId, String medicationName, String scheduledTime) async {
    try {
      final logBox = Hive.box('medication_logs');
      final timestamp = DateTime.now().toIso8601String();

      // 1. Log locally in Hive
      final log = {
        'medication_id': medicationId,
        'medication_name': medicationName,
        'scheduled_time': scheduledTime,
        'taken_at': timestamp,
        'status': 'taken',
      };

      await logBox.add(log);

      // 2. Try to sync immediately
      try {
        await _syncService.syncLogs();
      } catch (e) {
        // Sync failed, but data is saved locally - will sync later
        print('Sync failed, will retry later: $e');
      }

      // 3. Show confirmation notification
      await _showConfirmationNotification(medicationName);
    } catch (e) {
      print('Error marking medication as taken: $e');
    }
  }

  static Future<void> _snoozeNotification(
      String medicationId, String medicationName, String scheduledTime) async {
    try {
      // Schedule notification for 10 minutes from now
      final snoozeTime = DateTime.now().add(const Duration(minutes: 10));
      
      await scheduleMedicationReminder(
        id: int.parse(medicationId) + 10000, // Different ID to avoid conflicts
        medicationId: medicationId,
        medicationName: medicationName,
        scheduledTime: snoozeTime,
        isSnoozed: true,
      );

      // Show snooze confirmation
      await _showSnoozeConfirmation(medicationName);
    } catch (e) {
      print('Error snoozing notification: $e');
    }
  }

  static Future<void> _showConfirmationNotification(String medicationName) async {
    const androidDetails = AndroidNotificationDetails(
      'confirmation_channel',
      'Confirmation',
      channelDescription: 'Medication taken confirmations',
      importance: Importance.low,
      priority: Priority.low,
      autoCancel: true,
      timeoutAfter: 3000, // Auto-dismiss after 3 seconds
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999999, // High ID to avoid conflicts
      '✓ Medication Logged',
      '$medicationName marked as taken',
      notificationDetails,
    );
  }

  static Future<void> _showSnoozeConfirmation(String medicationName) async {
    const androidDetails = AndroidNotificationDetails(
      'snooze_channel',
      'Snooze Confirmation',
      channelDescription: 'Medication snooze confirmations',
      importance: Importance.low,
      priority: Priority.low,
      autoCancel: true,
      timeoutAfter: 3000,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999998,
      '⏰ Reminder Snoozed',
      'Will remind you about $medicationName in 10 minutes',
      notificationDetails,
    );
  }

  static Future<void> scheduleMedicationReminder({
    required int id,
    required String medicationId,
    required String medicationName,
    required DateTime scheduledTime,
    String? dosage,
    bool isSnoozed = false,
  }) async {
    final payload = '$medicationId|$medicationName|${scheduledTime.toIso8601String()}';

    final androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Reminders to take your medications',
      importance: Importance.high,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'taken',
          '✓ Taken',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          'snooze',
          '⏰ Snooze 10min',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    final iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'medication_reminder',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final title = isSnoozed 
        ? '⏰ Snoozed Reminder: $medicationName'
        : '💊 Time for your medication';
    
    final body = dosage != null
        ? 'Take $medicationName - $dosage'
        : 'Take $medicationName';

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // For iOS - you need to configure categories with actions
  // static Future<void> configureIOSNotificationCategories() async {
  //   final List<DarwinNotificationCategory> categories = [
  //     DarwinNotificationCategory(
  //       'medication_reminder',
  //       actions: [
  //         DarwinNotificationAction.plain(
  //           'taken',
  //           '✓ Taken',
  //           options: <DarwinNotificationActionOption>{
  //             DarwinNotificationActionOption.destructive,
  //           },
  //         ),
  //         DarwinNotificationAction.plain(
  //           'snooze',
  //           '⏰ Snooze 10min',
  //         ),
  //       ],
  //     ),
  //   ];

    // await _notifications
    //     .resolvePlatformSpecificImplementation
    //         <IOSFlutterLocalNotificationsPlugin>()
    //     ?.setNotificationCategories(categories);
  // }

  // Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> checkPendingNotifications() async {
    await _notifications.pendingNotificationRequests();
  }
}