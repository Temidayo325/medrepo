import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';

import 'components/profile/profile_picure.dart';
import 'components/profile/profile_info.dart';
import 'components/profile/add_emergency_contact.dart';
import 'components/profile/viral_panel.dart';
import 'components/profile/edit_profile.dart';
import 'components/empty_state.dart';
import 'colors.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final Map<String, dynamic> defaultContacts = {
    'contact1': {'name': '', 'phone': '', 'email': ''},
    'contact2': {'name': '', 'phone': '', 'email': ''},
  };
  
  final List<Map<String, String>> defaultViralPanel = [
    {'full_name': '','short_name': '','result': '','date': '',},
    {'full_name': '','short_name': '','result': '','date': '',},
    {'full_name': '','short_name': '','result': '','date': '',},
  ];

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
      "allergies": "",
    };

  @override
  Widget build(BuildContext context) {
    final emergencyBox = Hive.box('emergencyContacts');
    final viralPanelBox = Hive.box('viralPanel');
    final profileBox = Hive.box('profile');

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        toolbarHeight: 90,
        // leading: Icon(Icons.arrow_back, color: AppColors.primaryGreen, size: 25),
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 25,
            color: Color.fromARGB(255, 3, 118, 30),
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
                color: AppColors.primaryGreen,
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
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // keeps vertical centering
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Avatar
                  ProfileAvatar(),
                  SizedBox(height: 15),
                  /// Name - Enhanced empty state
                  hasProfileData 
                    ? Text(
                        profile["name"],
                        // textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 3, 118, 30),
                        ),
                      )
                    : Column(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 40,
                            color: Color.fromARGB(255, 3, 118, 30),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Your Profile",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 3, 118, 30),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Tap Edit to get started",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),

                  SizedBox(height: 25),

                  /// PROFILE INFO - Enhanced empty state
                  hasProfileData
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20), // fully rounded
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:[
                                  _infoCard("${profile['age']}", "Age"),
                                  SizedBox(width: 10),
                                  _infoCard("${profile['bmi']}", "BMI", unit: "kg/m²"),
                                  SizedBox(width: 10),
                                  _infoCard("${profile['bloodGroup']}", "BG"),
                                  SizedBox(width: 10),
                                  _infoCard("${profile['genotype']}", "Genotype"),
                                ]
                              )
                            ],)
                        ),
                        SizedBox(height: 35),
                        Text("Contact information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Color.fromARGB(255, 3, 118, 30))),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                              _additionalInfo(Icons.mail, "${profile['email']}"),
                              SizedBox(width:15),
                              _additionalInfo(Icons.phone, "${profile['phone']}")
                          ]
                        ),
                        
                        SizedBox(height: 35),
                        Text("Physical Features", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Color.fromARGB(255, 3, 118, 30))),
                        SizedBox(height:5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                              _additionalInfo(Icons.height, "${profile['height']} cm"),
                              SizedBox(width:5),
                              _additionalInfo(Icons.monitor_weight, "${profile['weight']} Kg"),
                              SizedBox(width: 5),
                              _additionalInfo(Icons.people_outline, "${profile['gender']}"),
                          ]
                        ),

                        SizedBox(height: 35),
                        Text("Chronic features", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Color.fromARGB(255, 3, 118, 30))),
                        SizedBox(height: 5),
                        Text("${profile['conditions']}", style: TextStyle(color: Colors.black45, fontSize: 17, letterSpacing: 1.2),),

                        SizedBox(height: 35),
                        Text("Allergies", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Color.fromARGB(255, 3, 118, 30))),
                        SizedBox(height: 5),
                        Builder(
                          builder: (_) {
                            final allergyString = profile['allergies'] ?? '';
                            if (allergyString.trim().isEmpty) {
                              return Text(
                                "None",
                                style: TextStyle(color: Colors.black45, fontSize: 16),
                              );
                            }
                            final allergies = allergyString.split(',').map((e) => e.trim()).toList();
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: allergies.map((allergy) {
                                return _additionalInfo(Icons.warning_amber_rounded, allergy);
                              }).toList(),
                            );
                          },
                        ),
                      ]
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
                              color: AppColors.primaryGreen,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "No Health Info Yet",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Add your details to track your health",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),

                  SizedBox(height: 35),

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
                                : EmptyState(icon: Icons.person_add_outlined, message: "No Contact Added"),
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
                                : EmptyState(icon: Icons.person_add_outlined, message: "No Contact Added"),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 25),
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
                  SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      final LocalAuthentication auth = LocalAuthentication();
                      final bool canAuthenticate = await auth.isDeviceSupported();
                      bool isAuthenticated = false;
                      if (canAuthenticate) {
                        try {
                          isAuthenticated = await auth.authenticate(
                            localizedReason: 'Please authenticate to view your viral panel',
                            options: const AuthenticationOptions(
                              stickyAuth: true,
                              biometricOnly: false,
                            ),
                          );
                        } catch (e) {
                          isAuthenticated = false;
                        }
                      } else {
                        // Fallback for devices without security
                        isAuthenticated = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Confirm Access"),
                                backgroundColor: AppColors.lightBackground,
                                content: Text(
                                    "This device has no security check enabled. Proceed to view the panel?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text("Cancel", style: TextStyle(color: const Color.fromARGB(255, 51, 146, 78)),),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text("Authorize", style: TextStyle(color: const Color.fromARGB(255, 51, 146, 78), fontWeight: FontWeight.bold),),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                      }

                      if (isAuthenticated) {
                        final currentList = List<Map<String, String>>.from(
                          viralPanelBox.get('viralPanel', defaultValue: defaultViralPanel),
                        );

                        await showViralPanelBottomSheet(context, currentList);
                      } else {
                        // Optionally show a message if authentication failed
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Authorization failed!")),
                        );
                      }
                    },
                    child: const Text('Viral Panel', style: TextStyle(color: Colors.blueGrey)),
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

  Widget _infoCard(String? value, String details, {String? unit}) {
    final displayValue = (value == null || value.isEmpty) ? "--" : value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                displayValue,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: Color.fromARGB(255, 3, 118, 30),
                ),
              ),

              // Add spacing only if unit exists
              if (unit != null && unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 10, // smaller than value
                    color: Color.fromARGB(255, 3, 118, 30),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            details,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
}


  Widget _additionalInfo(IconData icon, String? text)
  {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // fully rounded
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black45),
          SizedBox(width: 6),
          Text(
              (text == null || text.isEmpty) ? "-----" : text,
              style: TextStyle(fontSize: 14, letterSpacing: 1,),
            ),
        ],
      )
    );
  }
}