import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../notifications.dart';
import '../send_post_request.dart';

class NotificationDebugScreen extends StatefulWidget {
  const NotificationDebugScreen({Key? key}) : super(key: key);

  @override
  State<NotificationDebugScreen> createState() => _NotificationDebugScreenState();
}

class _NotificationDebugScreenState extends State<NotificationDebugScreen> {
  List<Map<String, dynamic>> _logs = [];
  List<PendingNotificationRequest> _pendingNotifications = [];
  String _debugOutput = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadLogs();
    await _loadPendingNotifications();
  }

  Future<void> _loadLogs() async {
    try {
      // Check if box is already open
      Box logBox;
      if (Hive.isBoxOpen('medication_logs')) {
        logBox = Hive.box('medication_logs');
      } else {
        logBox = await Hive.openBox('medication_logs');
      }

      final logs = logBox.values
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      setState(() {
        _logs = logs;
        _debugOutput += '✓ Loaded ${logs.length} logs from Hive\n';
      });
    } catch (e) {
      setState(() {
        _debugOutput += '✗ Error loading logs: $e\n';
      });
    }
  }

  Future<void> _loadPendingNotifications() async {
    try {
      final FlutterLocalNotificationsPlugin notifications =
          FlutterLocalNotificationsPlugin();
      
      final pending = await notifications.pendingNotificationRequests();
      
      setState(() {
        _pendingNotifications = pending;
        _debugOutput += '✓ Found ${pending.length} pending notifications\n';
      });
    } catch (e) {
      setState(() {
        _debugOutput += '✗ Error loading notifications: $e\n';
      });
    }
  }

  Future<void> _testMarkAsTaken(PendingNotificationRequest notification) async {
    setState(() {
      _debugOutput += '\n--- Testing "Mark as Taken" ---\n';
    });

    try {
      // Parse the payload
      if (notification.payload == null) {
        setState(() {
          _debugOutput += '✗ Notification has no payload\n';
        });
        return;
      }

      final parts = notification.payload!.split('|');
      if (parts.length < 3) {
        setState(() {
          _debugOutput += '✗ Invalid payload format: ${notification.payload}\n';
        });
        return;
      }

      final medicationId = parts[0];
      final medicationName = parts[1];
      final scheduledTime = parts[2];

      setState(() {
        _debugOutput += '✓ Parsed payload:\n';
        _debugOutput += '  - Medication ID: $medicationId\n';
        _debugOutput += '  - Name: $medicationName\n';
        _debugOutput += '  - Scheduled: $scheduledTime\n';
      });

      // Check if log box is open
      Box logBox;
      if (Hive.isBoxOpen('medication_logs')) {
        logBox = Hive.box('medication_logs');
        setState(() {
          _debugOutput += '✓ Log box already open\n';
        });
      } else {
        logBox = await Hive.openBox('medication_logs');
        setState(() {
          _debugOutput += '✓ Opened log box\n';
        });
      }
      final localLogId = 'log_${DateTime.now().millisecondsSinceEpoch}_$medicationId';
      // Create log entry
      final log = {
        'medication_id': medicationId,
        'local_log_id': localLogId,
        'medication_name': medicationName,
        'scheduled_at': scheduledTime,
        'taken_at': DateTime.now().toIso8601String(),
        'status': 'taken',
        'test_mode': true, // Flag to identify test entries
      };

      setState(() {
        _debugOutput += '✓ Created log entry:\n';
        _debugOutput += '  ${log.toString()}\n';
      });

      // Add to Hive
      await logBox.add(log);
      setState(() {
        _debugOutput += '✓ Successfully added to Hive!\n';
        _debugOutput += '  Total logs now: ${logBox.length}\n';
      });

      // Now test the sync
      setState(() {
        _debugOutput += '\n--- Testing Sync ---\n';
      });
      
      await _testSync();

      // Reload logs to show the new entry
      await _loadLogs();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Test log added and sync attempted!'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e, stackTrace) {
      setState(() {
        _debugOutput += '✗ ERROR: $e\n';
        _debugOutput += 'Stack trace: $stackTrace\n';
      });
    }
  }

  Future<void> _testSync() async {
    try {
      // 1. Check connectivity
      setState(() {
        _debugOutput += 'Checking internet connectivity...\n';
      });
      
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        setState(() {
          _debugOutput += '✗ No internet connection\n';
        });
        return;
      }
      
      setState(() {
        _debugOutput += '✓ Internet connected (${connectivityResult.toString()})\n';
      });

      // 2. Check Hive box
      final logBox = Hive.box('medication_logs');
      if (logBox.isEmpty) {
        setState(() {
          _debugOutput += '✗ Log box is empty\n';
        });
        return;
      }

      setState(() {
        _debugOutput += '✓ Found ${logBox.length} logs to sync\n';
      });

      // 3. Prepare data
      final List logsToSync = logBox.values.toList();
      setState(() {
        _debugOutput += '✓ Prepared ${logsToSync.length} logs\n';
        _debugOutput += '  Data: ${logsToSync.toString()}\n';
      });

      // 4. Make API call
      setState(() {
        _debugOutput += 'Calling API...\n';
      });

      final response = await sendDataToApi(
        'https://medrepo.fineworksstudio.com/api/patient/medications/sync',
        {'logs': logsToSync},
      );

      setState(() {
        _debugOutput += '\n--- API Response ---\n';
        _debugOutput += 'Response: ${response.toString()}\n';
      });

      // Check for error status_code (injected by DioException handler)
      if (response['status_code'] != null) {
        setState(() {
          _debugOutput += '✗ Sync failed with status ${response['status_code']}\n';
          _debugOutput += 'Error: ${response['message'] ?? 'Unknown error'}\n';
        });
      } else {
        setState(() {
          _debugOutput += '✓ Sync successful!\n';
          _debugOutput += 'Note: In production, ${logBox.length} logs would be cleared\n';
        });
      }

    } catch (e, stackTrace) {
      setState(() {
        _debugOutput += '✗ SYNC ERROR: $e\n';
        _debugOutput += 'Stack trace: $stackTrace\n';
      });
    }
  }

  Future<void> _clearTestLogs() async {
    try {
      final logBox = Hive.box('medication_logs');
      final keysToDelete = <dynamic>[];

      // Find all test entries
      for (var i = 0; i < logBox.length; i++) {
        final log = Map<String, dynamic>.from(logBox.getAt(i) as Map);
        if (log['test_mode'] == true) {
          keysToDelete.add(logBox.keyAt(i));
        }
      }

      // Delete them
      for (var key in keysToDelete) {
        await logBox.delete(key);
      }

      setState(() {
        _debugOutput += '\n✓ Cleared ${keysToDelete.length} test logs\n';
      });

      await _loadLogs();
    } catch (e) {
      setState(() {
        _debugOutput += '✗ Error clearing test logs: $e\n';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Debugger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Debug Output
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Debug Output',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _debugOutput = '';
                            });
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _debugOutput.isEmpty ? 'No debug output yet' : _debugOutput,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Manual Sync Button
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manual Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _testSync,
                            icon: const Icon(Icons.sync),
                            label: const Text('Test Sync Now'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _loadData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh Data'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Pending Notifications
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Notifications (${_pendingNotifications.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_pendingNotifications.isEmpty)
                      const Text('No pending notifications')
                    else
                      ..._pendingNotifications.map((notification) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(notification.title ?? 'No title'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notification.body ?? 'No body'),
                                const SizedBox(height: 4),
                                Text(
                                  'ID: ${notification.id}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                if (notification.payload != null)
                                  Text(
                                    'Payload: ${notification.payload}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => _testMarkAsTaken(notification),
                              child: const Text('Test "Taken"'),
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Stored Logs
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Medication Logs (${_logs.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_logs.any((log) => log['test_mode'] == true))
                          TextButton(
                            onPressed: _clearTestLogs,
                            child: const Text('Clear Test Logs'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_logs.isEmpty)
                      const Text('No logs stored')
                    else
                      ..._logs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final log = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: log['test_mode'] == true
                              ? Colors.yellow.shade50
                              : null,
                          child: ListTile(
                            title: Text(log['medication_name'] ?? 'Unknown'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status: ${log['status']}'),
                                Text('Taken: ${log['taken_at']}'),
                                if (log['test_mode'] == true)
                                  const Text(
                                    'TEST ENTRY',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Text('#$index'),
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}