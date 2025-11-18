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

          // Check if profile is empty
          final bool hasProfileData = profile["name"].toString().isNotEmpty;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  /// Avatar
                  ProfileAvatar(),
                  SizedBox(height: 15),

                  /// Name - Enhanced empty state
                  hasProfileData 
                    ? Text(
                        profile["name"],
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade800,
                        ),
                      )
                    : Column(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 40,
                            color: Colors.blueGrey.shade300,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Your Profile",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey.shade400,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Tap Edit to get started",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey.shade300,
                            ),
                          ),
                        ],
                      ),

                  SizedBox(height: 25),

                  /// PROFILE INFO - Enhanced empty state
                  hasProfileData
                    ? Row(
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
                      )
                    : Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blueGrey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.health_and_safety_outlined,
                              size: 48,
                              color: Colors.blueGrey.shade300,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "No Health Info Yet",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey.shade600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Add your details to track your health",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blueGrey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),

                  SizedBox(height: 20),

                  /// EMERGENCY CONTACTS - Enhanced empty state (side by side)
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

                      final bool hasContact1 = (c1['name'] ?? '').toString().isNotEmpty;
                      final bool hasContact2 = (c2['name'] ?? '').toString().isNotEmpty;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ProfileInfoCard(
                              header: 'Emergency Contact 1',
                              child: hasContact1 
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _infoRow(Icons.person, c1['name'] ?? '', compact: true),
                                      SizedBox(height: 8),
                                      _infoRow(Icons.phone, c1['phone'] ?? '', compact: true),
                                      SizedBox(height: 8),
                                      _infoRow(Icons.email, c1['email'] ?? '', compact: true),
                                    ],
                                  )
                                : _emptyContactState(),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ProfileInfoCard(
                              header: 'Emergency Contact 2',
                              child: hasContact2 
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _infoRow(Icons.person, c2['name'] ?? '', compact: true),
                                      SizedBox(height: 8),
                                      _infoRow(Icons.phone, c2['phone'] ?? '', compact: true),
                                      SizedBox(height: 8),
                                      _infoRow(Icons.email, c2['email'] ?? '', compact: true),
                                    ],
                                  )
                                : _emptyContactState(),
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

  /// Empty state for contacts
  Widget _emptyContactState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 32,
              color: Colors.blueGrey.shade300,
            ),
            SizedBox(height: 8),
            Text(
              "No contact added",
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable icon row
  Widget _infoRow(IconData icon, String? text, {bool compact = false}) {
    return Row(
      children: [
        Icon(icon, size: compact ? 18 : 22, color: Colors.blueGrey),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            (text == null || text.isEmpty) ? "—" : text,
            style: TextStyle(
              fontSize: compact ? 13 : 15, 
              letterSpacing: compact ? 0.5 : 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}