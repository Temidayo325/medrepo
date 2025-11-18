import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'components/app_title.dart';
import 'components/medication/time_flow.dart';
import 'components/medication/status_selector.dart';
import 'components/medication/med_overview_card.dart';
import 'components/medication/med_details.dart';
import 'components/medication/new_medication_sheet.dart';

class MedicationPage extends StatefulWidget {
  @override
  _MedicationPageState createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  List<Map<String, dynamic>> medications = [];
  List<Map<String, dynamic>> filteredMedications = [];
  String activeStatus = 'All';
  String activeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  void _loadMedications() async {
    final box = await Hive.openBox('medications');
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

  void _addOrUpdateMedication(Map<String, dynamic> med, {int? index}) async {
    final box = await Hive.openBox('medications');

    if (index != null) {
      // Update existing medication
      await box.putAt(index, med);

      setState(() {
        medications[index] = med;
      });
    } else {
      // Add new medication
      await box.add(med);

      setState(() {
        medications.add(med);
      });
    }

    // After modifying the medications list, re-apply filters
    _filterByStatus(activeStatus);
    if (activeFilter != 'All') _filterMedications(activeFilter);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(index != null
            ? "${med['name']} updated successfully!"
            : "${med['name']} added successfully!"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmDelete(int index) async {
    final med = medications[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Medication'),
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

    if (confirmed == true) {
      final box = await Hive.openBox('medications');
      await box.deleteAt(index);

      setState(() {
        medications.removeAt(index);
        _filterByStatus(activeStatus);
        if (activeFilter != 'All') _filterMedications(activeFilter);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${med['name']}" deleted successfully!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _filterMedications(String filter) {
    activeFilter = filter;
    _applyFilters();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Filtered by $filter • ${filteredMedications.length} meds"),
        backgroundColor: Colors.blueGrey,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _filterByStatus(String status) {
    activeStatus = status;
    _applyFilters();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Medications',
        colors: Colors.white,
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: TimeFilterRow(onFilterSelected: _filterMedications),
          ),
          StatusSelector(onStatusSelected: _filterByStatus),
          Expanded(
            child: filteredMedications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medical_services_outlined,
                            size: 80, color: Colors.blueGrey.shade200),
                        SizedBox(height: 20),
                        Text(
                          "No medications found for this timeframe.",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: filteredMedications.length,
                        itemBuilder: (context, index) {
                          final data = filteredMedications[index];
                          return Dismissible(
                            key: Key(data['created_at'] + index.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _confirmDelete(index),
                            child: GestureDetector(
                              onLongPress: () => _editMedication(index, data),
                              child: IconTextCard(
                                name: data['name'],
                                duration: data['duration'],
                                form: data['form'],
                                quantity: data['quantity'],
                                durationOfTherapy: data['duration_of_therapy'],
                                onTap: () => _showMedicationDetails(index, data),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blueGrey),
                                  onPressed: () => _editMedication(index, data),
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
        onPressed: () {
          // Add
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => NewMedicationSheet(onSave: _addOrUpdateMedication),
          );
        },
        icon: Icon(Icons.add, color: Colors.white, size: 30),
        label: Text("Add Medication",
            style: TextStyle(color: Colors.white, fontSize: 15)),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  void _editMedication(int index, Map<String, dynamic> med) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => NewMedicationSheet(
        onSave: _addOrUpdateMedication,
        existingMedication: medications[index],
        index: index,
      ),
    );
  }

  void _showMedicationDetails(int index, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MedicationDetailsSheet(
        name: data['name'],
        duration: data['duration'],
        form: data['form'],
        quantity: data['quantity'],
        durationOfTherapy: data['duration_of_therapy'],
        createdAt: data['created_at'],
        dosageStrength: data['dosage_strength'],
      ),
    );
  }
}
