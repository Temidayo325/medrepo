import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'components/profile/secure_content_access.dart';
import 'components/profile/edit_health_record.dart';
import 'components/profile/add_emergency_contact.dart';
import 'components/profile/profile_picure.dart';
import 'colors.dart';
import 'components/profile/genotype.dart';
// import 'components/loader.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  // Calculate BMI safely
  double? calculateBMI(dynamic height, dynamic weight) {
    if (height == null || weight == null) return null;
    try {
      final h = double.parse(height.toString());
      final w = double.parse(weight.toString());
      if (h <= 0 || w <= 0) return null;
      final heightInMeters = h / 100;
      return w / (heightInMeters * heightInMeters);
    } catch (e) {
      return null;
    }
  }

  // Safe string getter
  String _safeString(dynamic value, [String defaultValue = '—']) {
    if (value == null) return defaultValue;
    final str = value.toString().trim();
    return str.isEmpty ? defaultValue : str;
  }

  // Check if data exists
  bool _hasData(Map<String, dynamic> data, List<String> keys) {
    return keys.any((key) {
      final value = data[key];
      if (value == null) return false;
      if (value is String) return value.trim().isNotEmpty;
      if (value is num) return value > 0;
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Safely get boxes with error handling
    late Box profileBox;
    late Box patientProfileBox;
    late Box emergencyContactsBox;

    try {
      profileBox = Hive.box('profile');
      patientProfileBox = Hive.box('patientProfile');
      emergencyContactsBox = Hive.box('emergencyContacts');
    } catch (e) {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Error loading profile data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Please restart the app'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        toolbarHeight: 90,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 25,
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: profileBox.listenable(),
        builder: (context, box, _) {
          // Safely get profile data
          Map<String, dynamic> profile = {};
          try {
            final rawData = box.toMap();
            // Convert top-level map keys to String
            profile = rawData.map((key, value) {
              // If value is a Map (like emergency contacts), convert it recursively
              if (value is Map) {
                return MapEntry(key.toString(), Map<String, dynamic>.from(value));
              } 
              // If value is a List of Maps, convert each Map
              else if (value is List) {
                return MapEntry(
                  key.toString(),
                  value.map((e) => e is Map ? Map<String, dynamic>.from(e) : e).toList(),
                );
              } 
              else {
                return MapEntry(key.toString(), value);
              }
            })
            ..removeWhere((key, value) => key == 'id' || key == 'identifier' || key == 'api_token');
          } catch (e) {}

          final hasProfileData = _hasData(profile, ['name', 'email', 'phone']);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ========== PROFILE AVATAR & NAME ==========
                  Center(
                    child: Column(
                      children: [
                        ProfileAvatar(),
                        SizedBox(height: 15),
                        Text(
                          _safeString(profile['name'], 'Your Profile'),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        if (!hasProfileData) ...[
                          SizedBox(height: 4),
                          Text(
                            'Tap Edit to get started',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // ========== BASIC INFORMATION SECTION ==========
                  _SectionHeader(
                    title: 'Basic Information',
                    onEdit: () => _showEditBasicInfoDialog(context, profile),
                  ),
                  SizedBox(height: 12),
                  _ProfileCard(
                    child: hasProfileData
                        ? Column(
                            children: [
                              _InfoRow(Icons.email, 'Email', _safeString(profile['email'])),
                              Divider(height: 24),
                              _InfoRow(Icons.phone, 'Phone', _safeString(profile['phone'])),
                              Divider(height: 24),
                              _InfoRow(Icons.cake, 'Date of Birth', _safeString(profile['date_of_birth'])),
                              Divider(height: 24),
                              _InfoRow(Icons.wc, 'Gender', _safeString(profile['gender'])),
                            ],
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                                  SizedBox(height: 12),
                                  Text(
                                    'No basic info added',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Tap Edit to add your information',
                                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 30),
                  MedicalInfoCard(),
                  SizedBox(height: 30),
                  // ========== HEALTH INFORMATION SECTION ==========
                  ValueListenableBuilder(
                    valueListenable: patientProfileBox.listenable(),
                    builder: (context, box, _) {
                      Map<String, dynamic> patientProfile = {};
                      try {
                        patientProfile = Map<String, dynamic>.from(box.toMap());
                      } catch (e) {}

                      final hasPatientProfile = _hasData(
                        patientProfile,
                        ['height', 'weight', 'chronic_conditions', 'allergies'],
                      );

                      final bmi = calculateBMI(
                        patientProfile['height'],
                        patientProfile['weight'],
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            title: 'Health Information',
                            onEdit: () => EditHealthInfoDialog(context, patientProfile).show(),
                          ),
                          SizedBox(height: 12),
                          _ProfileCard(
                            child: hasPatientProfile
                                ? Column(
                                    children: [
                                      // Height, Weight, BMI in a row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _StatCard(
                                            'Height',
                                            _safeString(patientProfile['height']),
                                            'cm',
                                          ),
                                          _StatCard(
                                            'Weight',
                                            _safeString(patientProfile['weight']),
                                            'kg',
                                          ),
                                          _StatCard(
                                            'BMI',
                                            bmi != null ? bmi.toStringAsFixed(1) : '—',
                                            'kg/m²',
                                          ),
                                        ],
                                      ),
                                      if (_safeString(patientProfile['chronic_conditions']) != '—' ||
                                          _safeString(patientProfile['allergies']) != '—') ...[
                                        Divider(height: 32),
                                      ],
                                      if (_safeString(patientProfile['chronic_conditions']) != '—') ...[
                                        _InfoRow(
                                          Icons.local_hospital,
                                          'Chronic Conditions',
                                          _safeString(patientProfile['chronic_conditions']),
                                        ),
                                        if (_safeString(patientProfile['allergies']) != '—')
                                          Divider(height: 24),
                                      ],
                                      if (_safeString(patientProfile['allergies']) != '—')
                                        _InfoRow(
                                          Icons.warning_amber_rounded,
                                          'Allergies',
                                          _safeString(patientProfile['allergies']),
                                        ),
                                      if (_safeString(patientProfile['family_history']) != '—') ...[
                                         Divider(height: 24),
                                        _InfoRow(
                                          Icons.local_hospital,
                                          'Family history',
                                          _safeString(patientProfile['family_history']),
                                        ),
                                        if (_safeString(patientProfile['family_history']) != '—')
                                          Divider(height: 24),
                                      ],
                                    ],
                                  )
                                : Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Icon(Icons.health_and_safety_outlined, size: 48, color: Colors.grey[400]),
                                          SizedBox(height: 12),
                                          Text(
                                            'No health info added',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Tap Edit to add your health details',
                                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 30),

                  // ========== EMERGENCY CONTACTS SECTION ==========
                  ValueListenableBuilder(
                    valueListenable: emergencyContactsBox.listenable(),
                    builder: (context, box, _) {
                      List<Map<String, dynamic>> contacts = [];
                        try {
                          final raw = box.get('contacts', defaultValue: []);
                          if (raw is List) {
                            contacts = raw
                                .whereType<Map>() // only maps
                                .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
                                .toList();
                          }
                        } catch (e) {}
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            title: 'Emergency Contacts',
                            onEdit: () => showEmergencyContactFlow(context),
                          ),
                          SizedBox(height: 12),
                          if (contacts.isEmpty)
                            _ProfileCard(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Icon(Icons.person_add_outlined, size: 48, color: Colors.grey[400]),
                                      SizedBox(height: 12),
                                      Text(
                                        'No emergency contacts added',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Tap Edit to add contacts',
                                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            ...contacts.asMap().entries.map((entry) {
                              // final index = entry.key;
                              final contact = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () => showEmergencyContactFlow(context),
                                  child: _ProfileCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.person, color: AppColors.primaryGreen, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _safeString(contact['name'], 'Unknown'),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryGreen,
                                                ),
                                              ),
                                            ),
                                            Icon(Icons.edit, size: 18, color: Colors.grey),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        _InfoRow(
                                          Icons.family_restroom,
                                          'Relationship',
                                          _safeString(contact['relationship']),
                                        ),
                                        Divider(height: 16),
                                        _InfoRow(Icons.phone, 'Phone', _safeString(contact['phone'])),
                                        Divider(height: 16),
                                        _InfoRow(Icons.email, 'Email', _safeString(contact['email'])),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 30),

                  // ========== VIRAL PANEL BUTTON ==========
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: Icon(Icons.biotech, color: Colors.white),
                      label: Text('View Viral Panel', style: TextStyle(color: Colors.white, fontSize: 16)),
                      onPressed: () async {
                        showSecureViralPanel(context: context);
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Edit Basic Info Dialog
  void _showEditBasicInfoDialog(BuildContext context, Map<String, dynamic> currentData) {
    final emailController = TextEditingController(text: _safeString(currentData['email'], ''));
    final phoneController = TextEditingController(text: _safeString(currentData['phone'], ''));
    final dobController = TextEditingController(text: _safeString(currentData['date_of_birth'], ''));
    String? selectedGender = _safeString(currentData['gender'], '').trim();
    if (selectedGender.isEmpty || selectedGender == '—') {
      selectedGender = null;
    } else {
      selectedGender = selectedGender[0].toUpperCase() + selectedGender.substring(1).toLowerCase();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Edit Basic Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: dobController,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: Icon(Icons.cake),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      dobController.text = date.toIso8601String().split('T')[0];
                    }
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.wc),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ['Male', 'Female', 'Other']
                      .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedGender = val;
                    });
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final payload = {
                      'email': emailController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'date_of_birth': dobController.text,
                      'gender': selectedGender?.toLowerCase(),
                    };

                    try {
                      // Update local storage
                      final profileBox = Hive.box('profile');
                      await profileBox.putAll(payload);

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Basic information updated'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error updating profile'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========== REUSABLE WIDGETS ==========

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;

  const _SectionHeader({required this.title, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
        ),
        TextButton.icon(
          onPressed: onEdit,
          icon: Icon(Icons.edit, size: 16, color: AppColors.primaryGreen),
          label: Text('Edit', style: TextStyle(color: AppColors.primaryGreen)),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Widget child;

  const _ProfileCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryGreen),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _StatCard(this.label, this.value, this.unit);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        if (unit.isNotEmpty && value != '—')
          Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}