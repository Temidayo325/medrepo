import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// import 'components/send_post_request.dart';
// import 'components/snackbar/error.dart';
// import 'components/snackbar/success.dart';
// import 'components/loader.dart';
import 'components/profile/edit_health_record.dart';
import 'components/profile/add_emergency_contact.dart';
import 'colors.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  // Calculate BMI
  double? calculateBMI(String? height, String? weight) {
    if (height == null || weight == null || height.isEmpty || weight.isEmpty) {
      return null;
    }
    try {
      final h = double.parse(height) / 100; // convert cm to m
      final w = double.parse(weight);
      return w / (h * h);
    } catch (e) {
      return null;
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Access"),
        backgroundColor: AppColors.lightBackground,
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: AppColors.primaryGreen)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Authorize", style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final profileBox = Hive.box('profile');
    final patientProfileBox = Hive.box('patientProfile');
    final emergencyContactsBox = Hive.box('emergencyContacts');

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
          final profile = Map<String, dynamic>.from(
            box.toMap()..removeWhere((key, value) => key == 'id' || key == 'identifier'),
          );

          final hasProfileData = (profile['name'] ?? '').toString().isNotEmpty;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Avatar & Basic Info
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                          child: Icon(Icons.person, size: 50, color: AppColors.primaryGreen),
                        ),
                        SizedBox(height: 15),
                        Text(
                          hasProfileData ? profile['name'] ?? 'No Name' : 'Your Profile',
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

                  // Basic Profile Section
                  _SectionHeader(
                    title: 'Basic Information',
                    onEdit: () => _showEditBasicInfoDialog(context, profile),
                  ),
                  SizedBox(height: 12),
                  _ProfileCard(
                    child: hasProfileData
                        ? Column(
                            children: [
                              _InfoRow(Icons.email, 'Email', profile['email'] ?? '—'),
                              Divider(height: 24),
                              _InfoRow(Icons.phone, 'Phone', profile['phone'] ?? '—'),
                              Divider(height: 24),
                              _InfoRow(Icons.cake, 'Date of Birth', profile['date_of_birth'] ?? '—'),
                              Divider(height: 24),
                              _InfoRow(Icons.wc, 'Gender', profile['gender'] ?? '—'),
                            ],
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('No basic info added', style: TextStyle(color: Colors.grey)),
                            ),
                          ),
                  ),
                  SizedBox(height: 30),

                  // Patient Profile Section (Height, Weight, BMI, Conditions, Allergies)
                  ValueListenableBuilder(
                    valueListenable: patientProfileBox.listenable(),
                    builder: (context, box, _) {
                      final patientProfile = Map<String, dynamic>.from(box.toMap());
                      final hasPatientProfile = patientProfile.isNotEmpty;

                      final bmi = calculateBMI(
                        patientProfile['height']?.toString(),
                        patientProfile['weight']?.toString(),
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
                                          _StatCard('Height', '${patientProfile['height'] ?? '—'}', 'cm'),
                                          _StatCard('Weight', '${patientProfile['weight'] ?? '—'}', 'kg'),
                                          _StatCard('BMI', bmi != null ? bmi.toStringAsFixed(1) : '—', 'kg/m2'),
                                        ],
                                      ),
                                      Divider(height: 32),
                                      _InfoRow(
                                        Icons.local_hospital,
                                        'Chronic Conditions',
                                        patientProfile['chronic_conditions'] ?? 'None',
                                      ),
                                      Divider(height: 24),
                                      _InfoRow(
                                        Icons.warning_amber_rounded,
                                        'Allergies',
                                        patientProfile['allergies'] ?? 'None',
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Text('No health info added', style: TextStyle(color: Colors.grey)),
                                    ),
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 30),

                  // Emergency Contacts Section
                  ValueListenableBuilder(
                    valueListenable: emergencyContactsBox.listenable(),
                    builder: (context, box, _) {
                      final contacts = List<Map<String, dynamic>>.from(
                        box.get('contacts', defaultValue: []),
                      );

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
                                  child: Text('No emergency contacts added', style: TextStyle(color: Colors.grey)),
                                ),
                              ),
                            )
                          else
                            ...contacts.asMap().entries.map((entry) {
                              final index = entry.key;
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
                                                contact['name'] ?? 'Unknown',
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
                                        _InfoRow(Icons.family_restroom, 'Relationship', contact['relationship'] ?? '—'),
                                        Divider(height: 16),
                                        _InfoRow(Icons.phone, 'Phone', contact['phone'] ?? '—'),
                                        Divider(height: 16),
                                        _InfoRow(Icons.email, 'Email', contact['email'] ?? '—'),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 30),

                  // Viral Panel Button
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
                        // Authentication logic here (same as before)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Viral panel feature coming soon')),
                        );
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
    final emailController = TextEditingController(text: currentData['email']);
    final phoneController = TextEditingController(text: currentData['phone']);
    final dobController = TextEditingController(text: currentData['date_of_birth']);
    String? selectedGender = currentData['gender'];

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
                  value: selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.wc),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (val) => setState(() => selectedGender = val),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    // Update basic profile (API call to patient update endpoint)
                    final payload = {
                      'email': emailController.text,
                      'phone': phoneController.text,
                      'date_of_birth': dobController.text,
                      'gender': selectedGender?.toLowerCase(),
                    };
                    
                    // TODO: Make API call here
                    // final response = await http.put(...);
                    
                    // Update local storage
                    final profileBox = Hive.box('profile');
                    await profileBox.putAll(payload);
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Basic information updated'), backgroundColor: AppColors.success),
                    );
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

// Reusable Widgets
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
                value.isEmpty ? '—' : value,
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
        if (unit.isNotEmpty)
          Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}