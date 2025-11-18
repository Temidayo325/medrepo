import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'components/profile/profile_picure.dart';
import 'components/profile/profile_info.dart';
import 'components/profile/add_emergency_contact.dart';
import 'components/profile/edit_profile.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final Map<String, dynamic> defaultContacts = {
    'contact1': {'name': '', 'phone': '', 'email': ''},
    'contact2': {'name': '', 'phone': '', 'email': ''},
  };

  final Map<String, dynamic> defaultProfile = {
      "name": "",
      "age": "",
      "gender": "",
      "phone": "",
      "email": "",
      "bloodGroup": "",
      "genotype": "",
      "bmi": "",
      "conditions": "",
    };

  @override
  Widget build(BuildContext context) {
    final emergencyBox = Hive.box('emergencyContacts');
    final profileBox = Hive.box('profile');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,
        leading: Icon(Icons.arrow_back, color: Colors.blueGrey.shade800, size: 25),
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 25,
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => showEditProfileBottomSheet(context),
            child: const Text(
              "Edit",
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
      ),

      body: ValueListenableBuilder(
        valueListenable: profileBox.listenable(),
        builder: (context, box, _) {
          final raw = box.get("profile", defaultValue: defaultProfile);

          /// --- Normalize values to avoid null ---
          final profile = Map<String, dynamic>.from(raw)
            .map((key, value) => MapEntry(key, value ?? ""));

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  /// Avatar
                  ProfileAvatar(),
                  SizedBox(height: 15),

                  /// Name
                  Text(
                    profile["name"].toString().isEmpty
                        ? "No name"
                        : profile["name"],
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade800,
                    ),
                  ),

                  SizedBox(height: 25),

                  /// PROFILE INFO
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${profile['age']} yo, ${profile['gender']}",
                              style: TextStyle(fontSize: 17),
                            ),
                            SizedBox(height: 3),
                            Text("${profile['phone']}", style: TextStyle(fontSize: 17)),
                            Text("${profile['email']}", style: TextStyle(fontSize: 17)),
                          ],
                        ),
                      ),
                      SizedBox(width: 30),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${profile['bloodGroup']}, ${profile['genotype']}, BMI: ${profile['bmi']}",
                              style: TextStyle(fontSize: 17),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Hgt: ${profile['height']}cm, Wgt: ${profile['weight']} kg",
                              style: TextStyle(fontSize: 17),
                            ),
                            SizedBox(height: 2,),
                            Text(
                              "Chronic: ${profile['conditions']}",
                              style: TextStyle(fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  /// EMERGENCY CONTACTS
                  ValueListenableBuilder(
                    valueListenable: emergencyBox.listenable(),
                    builder: (context, box, _) {
                      final stored = box.get(
                        'emergencyContacts',
                        defaultValue: defaultContacts,
                      );

                      final contacts = Map<String, dynamic>.from(stored);

                      final c1 = Map<String, dynamic>.from(contacts['contact1']);
                      final c2 = Map<String, dynamic>.from(contacts['contact2']);

                      return Column(
                        children: [
                          ProfileInfoCard(
                            header: 'Emergency Contact 1',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoRow(Icons.person, c1['name'] ?? ''),
                                SizedBox(height: 8),
                                _infoRow(Icons.phone, c1['phone'] ?? ''),
                                SizedBox(height: 8),
                                _infoRow(Icons.email, c1['email'] ?? ''),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          ProfileInfoCard(
                            header: 'Emergency Contact 2',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoRow(Icons.person, c2['name'] ?? ''),
                                SizedBox(height: 8),
                                _infoRow(Icons.phone, c2['phone'] ?? ''),
                                SizedBox(height: 8),
                                _infoRow(Icons.email, c2['email'] ?? ''),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 25),

                  /// BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      final current = Map<String, dynamic>.from(
                        emergencyBox.get('emergencyContacts', defaultValue: defaultContacts),
                      );

                      await showEmergencyContactsBottomSheet(context, current);
                    },
                    child: Text('Edit Emergency Contacts',
                        style: TextStyle(color: Colors.blueGrey)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Reusable icon row
  Widget _infoRow(IconData icon, String? text) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.blueGrey),
        SizedBox(width: 6),
        Text(
          (text == null || text.isEmpty) ? "—" : text,
          style: TextStyle(fontSize: 15, letterSpacing: 1.2),
        ),
      ],
    );
  }
}
