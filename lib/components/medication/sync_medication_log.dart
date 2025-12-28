import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import '../send_post_request.dart';

class SyncService {
  
  Future<void> syncLogs() async {
    // 1. Check if we have internet
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) return;

    final logBox = Hive.box('medication_logs');
    if (logBox.isEmpty) return;

    // 2. Get only unsynced logs
    final List<Map<String, dynamic>> logsToSync = [];
    final List<int> indicesToUpdate = [];
    
    for (int i = 0; i < logBox.length; i++) {
      final log = Map<String, dynamic>.from(logBox.getAt(i));
      if (log['synced'] != true) {  // Only sync unsynced logs
        logsToSync.add(log);
        indicesToUpdate.add(i);
      }
    }
    
    if (logsToSync.isEmpty) return;

    try {
      // 3. Post to the Laravel endpoint
      final response = await sendDataToApi(
        'https://medrepo.fineworksstudio.com/api/patient/medications/sync', 
        {'logs': logsToSync}
      );

      // 4. Check for success
      if (response['status_code'] != null) {
        print('Sync failed with status: ${response['status_code']}');
        throw Exception("Sync failed: ${response['message'] ?? 'Unknown error'}");
      }
      
      // Mark logs as synced instead of deleting them
      for (int index in indicesToUpdate) {
        final log = Map<String, dynamic>.from(logBox.getAt(index));
        log['synced'] = true;
        await logBox.putAt(index, log);
      }
      
      print('✓ Successfully synced ${logsToSync.length} logs');
      
    } catch (e) {
      print("Sync failed: $e");
      throw Exception("Sync failed: $e");
    }
  }
}