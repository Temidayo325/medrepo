import 'package:flutter/material.dart';
import 'root_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:flutter/foundation.dart';
import  'register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('tests');
  await Hive.openBox('emergencyContacts'); // box to store all test records
  await Hive.openBox('profile'); 
  await Hive.openBox('patientProfile');
  await Hive.openBox('viralPanel');
  // Hive.box('auth').put('isRegistered', true);
  await Hive.openBox('token');
  await Hive.openBox('register');
  // final box = await Hive.openBox('tests'); // box to store user profile

  // Only clear the box during development
  // if (kDebugMode) {
  //   await box.clear();
  //   print("Tests box cleared (debug mode)!");
  // }
  runApp(MyApp());
}

class MyApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
    final authBox = Hive.box('register');
    final isRegistered = authBox.get('isRegistered', defaultValue: false);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isRegistered ? RootPage() : RegistrationScreen(),
    );
  }
}