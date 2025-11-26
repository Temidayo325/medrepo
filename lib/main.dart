import 'package:flutter/material.dart';
import 'root_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('tests');
  await Hive.openBox('emergencyContacts'); // box to store all test records
  await Hive.openBox('profile'); 
  await Hive.openBox('viralPanel');
  // final box = await Hive.openBox('profile'); // box to store all test records

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RootPage()
    );
  }
}