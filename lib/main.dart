import 'package:flutter/material.dart';
import 'login.dart';
import 'components/dio_request_instance.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'components/notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:flutter/foundation.dart';
import  'register.dart';
import 'components/medication/sync_medication_log.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'components/medication/medication_schedular.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  
  // For iOS - configure action categories
  // if (Platform.isIOS) {
  //   await NotificationService.configureIOSNotificationCategories();
  // }
  await Hive.initFlutter();
  await Hive.openBox('tests');
  await Hive.openBox('emergencyContacts'); // box to store all test records
  await Hive.openBox('profile'); 
  await Hive.openBox('medications');
  await Hive.openBox('symptoms');
  await Hive.openBox('patientProfile');
  await Hive.openBox('viralPanel');
  await Hive.openBox('medication_logs');
  // Hive.box('auth').put('isRegistered', true);
  await Hive.openBox('token');
  await Hive.openBox('register');
  // final box = await Hive.openBox('symptoms'); // box to store user profile

  // Only clear the box during development
  // if (kDebugMode) {
  //   await box.clear();
  //   print("Tests box cleared (debug mode)!");
  // }
  await NotificationService.initialize();
  await NotificationService.checkPendingNotifications();
  await MedicationScheduler.refreshAllSchedules();
  setupDioInterceptor();
  runApp(MyApp());
}

class MyApp extends StatelessWidget
{
  void initState() {
    // super.initState();
    
    // Initial sync on launch
    SyncService().syncLogs();

    // Updated for connectivity_plus v6.0.0+
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // If the list contains anything other than 'none', we have internet
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
        SyncService().syncLogs();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final authBox = Hive.box('register');
    final isRegistered = authBox.get('isRegistered', defaultValue: false);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isRegistered ? LoginScreen() : RegistrationScreen(),
    );
  }
}