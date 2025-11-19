import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'components/app_title.dart';
import 'components/medication/time_flow.dart';
import 'components/medication/status_selector.dart';
import 'components/medication/med_overview_card.dart';
import 'components/medication/med_details.dart';
import 'components/medication/new_medication_sheet.dart';
import 'colors.dart';

class MedicationPage extends StatefulWidget {
  @override
  _MedicationPageState createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  List<Map<String, dynamic>> medications = []; // source (Hive order)
  List<Map<String, dynamic>> filteredMedications = []; // what is displayed
  String activeStatus = 'All';
  String activeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  // --- LOAD and ensure each med has an id ---
  Future<void> _loadMedications() async {
    final box = await Hive.openBox('medications');
    final raw = box.values.map((e) => Map<String, dynamic>.from(e)).toList();

    // Ensure every med has an id; if missing, assign one and save back
    bool changed = false;
    for (int i = 0; i < raw.length; i++) {
      final med = raw[i];
      if (med['id'] == null) {
        med['id'] = DateTime.now().millisecondsSinceEpoch.toString() + '_$i';
        // update Hive at the same position
        await box.putAt(i, med);
        changed = true;
      }
    }

    // Reload from box if we modified it, to ensure consistency
    final meds = box.values.map((e) => Map<String, dynamic>.from(e)).toList();

    setState(() {
      medications = meds;
      filteredMedications = List.from(medications);
      _sortMedications();
    });
  }

  void _sortMedications() {
    filteredMedications.sort((a, b) {
      final dateA = DateTime.parse(a['created_at']);
      final dateB = DateTime.parse(b['created_at']);
      return dateB.compareTo(dateA);
    });
  }

  // --- Add or update medication (index = hive index in box) ---
  Future<void> _addOrUpdateMedication(Map<String, dynamic> med, {int? index}) async {
    final box = await Hive.openBox('medications');

    if (index != null) {
      // Update existing medication at Hive index
      // Ensure id is preserved (if sheet didn't include it)
      final existing = index >= 0 && index < medications.length ? medications[index] : null;
      if (existing != null && existing['id'] != null && med['id'] == null) {
        med['id'] = existing['id'];
      }
      // Ensure created_at exists
      med['created_at'] = med['created_at'] ?? existing?['created_at'] ?? DateTime.now().toIso8601String();

      await box.putAt(index, med);

      setState(() {
        medications[index] = med;
      });
    } else {
      // Add new medication: generate id and ensure created_at
      med['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      med['created_at'] = med['created_at'] ?? DateTime.now().toIso8601String();

      await box.add(med);

      // reload medications from box to keep indexes consistent
      final meds = box.values.map((e) => Map<String, dynamic>.from(e)).toList();
      setState(() {
        medications = meds;
      });
    }

    // Re-apply filters and sort
    _applyFilters();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(index != null ? "${med['name']} updated successfully!" : "${med['name']} added successfully!", style: TextStyle(color: AppColors.lightBackground),),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // --- Confirm delete using ID (returns bool for confirmDismiss) ---
  Future<bool> _confirmDeleteById(String id) async {
    final med = medications.firstWhere((m) => m['id'] == id, orElse: () => {});
    if (med.isEmpty) return false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Medication', style: TextStyle(color: AppColors.lightBackground),),
        content: Text('Are you sure you want to delete "${med['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    // Find hive index for this id
    final box = await Hive.openBox('medications');
    final hiveList = box.values.map((e) => Map<String, dynamic>.from(e)).toList();
    final hiveIndex = hiveList.indexWhere((m) => m['id'] == id);

    if (hiveIndex == -1) return false;

    await box.deleteAt(hiveIndex);

    // Update local lists
    setState(() {
      medications.removeWhere((m) => m['id'] == id);
      filteredMedications.removeWhere((m) => m['id'] == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${med['name']}" deleted successfully!', style: TextStyle(color: AppColors.lightBackground),),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    return true;
  }

  // --- Time filter callback ---
  void _filterMedications(String filter) {
    activeFilter = filter;
    _applyFilters();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Filtered by $filter • ${filteredMedications.length} meds", style: TextStyle(color: AppColors.primaryGreen),),
        backgroundColor: AppColors.lightBackground,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- Status filter callback ---
  void _filterByStatus(String status) {
    activeStatus = status;
    _applyFilters();
  }

  // --- Apply both status & time filters ---
  void _applyFilters() {
    final now = DateTime.now();
    List<Map<String, dynamic>> meds = List.from(medications);

    // Status filter
    if (activeStatus == 'Active') {
      meds = meds.where((med) {
        final startDate = DateTime.parse(med['created_at']);
        final endDate = startDate.add(Duration(days: _parseDurationToDays(med['duration_of_therapy'])));
        return now.isBefore(endDate);
      }).toList();
    } else if (activeStatus == 'Completed') {
      meds = meds.where((med) {
        final startDate = DateTime.parse(med['created_at']);
        final endDate = startDate.add(Duration(days: _parseDurationToDays(med['duration_of_therapy'])));
        return now.isAfter(endDate);
      }).toList();
    }

    // Time filter
    if (activeFilter == 'This Week') {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(Duration(days: 6));
      meds = meds.where((med) {
        final date = DateTime.parse(med['created_at']);
        return !date.isBefore(startOfWeek) && !date.isAfter(endOfWeek);
      }).toList();
    } else if (activeFilter == 'This Month') {
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      meds = meds.where((med) {
        final date = DateTime.parse(med['created_at']);
        return !date.isBefore(startOfMonth) && !date.isAfter(endOfMonth);
      }).toList();
    } else if (activeFilter == 'This Year') {
      final startOfYear = DateTime(now.year, 1, 1);
      final endOfYear = DateTime(now.year, 12, 31);
      meds = meds.where((med) {
        final date = DateTime.parse(med['created_at']);
        return !date.isBefore(startOfYear) && !date.isAfter(endOfYear);
      }).toList();
    }

    setState(() {
      filteredMedications = meds;
      _sortMedications();
    });
  }

  int _parseDurationToDays(String duration) {
    final lower = duration.toLowerCase();
    if (lower.contains('day')) return int.tryParse(lower.split(' ')[0]) ?? 0;
    if (lower.contains('week')) return (int.tryParse(lower.split(' ')[0]) ?? 0) * 7;
    if (lower.contains('month')) return (int.tryParse(lower.split(' ')[0]) ?? 0) * 30;
    return 0;
  }

  // --- Helpers to open edit sheet with correct hive index ---
  Future<void> _openEditSheetById(String id) async {
    // find hive index for id
    final box = await Hive.openBox('medications');
    final hiveList = box.values.map((e) => Map<String, dynamic>.from(e)).toList();
    final hiveIndex = hiveList.indexWhere((m) => m['id'] == id);

    if (hiveIndex == -1) return;

    final existingMed = hiveList[hiveIndex];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => NewMedicationSheet(
        onSave: _addOrUpdateMedication,
        existingMedication: existingMed,
        index: hiveIndex, // pass hive index so sheet's onSave updates correctly
      ),
    );
  }

  // --- Show details bottom sheet (no changes needed) ---
  void _showMedicationDetails(String id) {
    final med = medications.firstWhere((m) => m['id'] == id, orElse: () => {});
    if (med.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MedicationDetailsSheet(
        name: med['name'],
        duration: med['duration'],
        form: med['form'],
        quantity: med['quantity'],
        durationOfTherapy: med['duration_of_therapy'],
        createdAt: med['created_at'],
        dosageStrength: med['dosage_strength'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: CustomAppBar(
        title: 'Medications',
        colors: AppColors.lightBackground,
        backgroundColor: AppColors.primaryGreen,
      ),
      body: Column(
        children: [
          // Time filter row
          Container(
            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 15),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              border: Border(top: BorderSide(color: AppColors.lightBackground)),
            ),
            child: TimeFilterRow(onFilterSelected: _filterMedications),
          ),

          // Status selector
          StatusSelector(onStatusSelected: _filterByStatus),

          // Grid of medication cards (3 columns)
          Expanded(
            child: filteredMedications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medical_services_outlined,
                            size: 80, color: AppColors.primaryGreen),
                        SizedBox(height: 20),
                        Text(
                          "No medications found for this timeframe.",
                          style: TextStyle(
                              fontSize: 16,
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                    child: SingleChildScrollView(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: filteredMedications.length,
                        itemBuilder: (context, index) {
                          final data = filteredMedications[index];
                          final id = data['id'] as String;

                          return Dismissible(
                            key: Key(id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: AppColors.primaryGreen,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(Icons.delete, color: AppColors.lightBackground),
                            ),
                            confirmDismiss: (_) => _confirmDeleteById(id),
                            child: GestureDetector(
                              onLongPress: () => _openEditSheetById(id),
                              onTap: () => _showMedicationDetails(id),
                              child: IconTextCard(
                                name: data['name'],
                                duration: data['duration'],
                                form: data['form'],
                                quantity: data['quantity'],
                                durationOfTherapy: data['duration_of_therapy'],
                                trailing: IconButton(
                                  icon: Icon(Icons.edit, color: AppColors.primaryGreen),
                                  onPressed: () => _openEditSheetById(id),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Open new med sheet for add (no index)
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => NewMedicationSheet(onSave: _addOrUpdateMedication),
          );
        },
        icon: Icon(Icons.add, color: AppColors.lightBackground, size: 30),
        label: Text("Add Medication", style: TextStyle(color: AppColors.lightBackground, fontSize: 15)),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }
}
