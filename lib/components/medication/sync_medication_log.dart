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

    // 2. Prepare data from Hive
    final List logsToSync = logBox.values.toList();

    try {
      // 3. Post to the Laravel endpoint we just built
      final response = await sendDataToApi('https://medrepo.fineworksstudio.com/api/patient/medications/sync', {'logs': logsToSync});

      if (response['statusCode'] == 200) {
        // 4. Clear Hive only if sync was successful
        await logBox.clear();
      }
    } catch (e) {
      throw Exception("Sync failed: $e");
    }
  }
}