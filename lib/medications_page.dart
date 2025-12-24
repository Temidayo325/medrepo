import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'components/app_title.dart';
import 'components/medication/time_flow.dart';
import 'components/medication/status_selector.dart';
import 'components/medication/med_overview_card.dart';
import 'components/medication/med_details.dart';
import 'components/medication/new_medication_sheet.dart';
import 'colors.dart';
import 'components/notifications.dart';
import 'components/send_post_request.dart';

class MedicationPage extends StatefulWidget {
  @override
  _MedicationPageState createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  List<Map<String, dynamic>> medications = []; // source (Hive order)
  List<Map<String, dynamic>> filteredMedications = []; // what is displayed
  MedicationStatus activeStatus = MedicationStatus.all;
  String activeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  int _parseFrequencyToInt(String frequency) {
    final lower = frequency.toLowerCase();
    if (lower.contains('1x') || lower.contains('once')) return 1;
    if (lower.contains('2x') || lower.contains('twice')) return 2;
    if (lower.contains('3x') || lower.contains('thrice')) return 3;
    if (lower.contains('4x')) return 4;
    
    // Default fallback if no match found
    return 1;
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
        // Only generate local ID if there's no server ID
        med['id'] = 'local_${DateTime.now().millisecondsSinceEpoch}_$i';
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

  void _scheduleReminders(Map<String, dynamic> med) {
    final int totalDays = _parseDurationToDays(med['duration_of_therapy']);
    final int timesPerDay = _parseFrequencyToInt(med['frequency']);
    final String medicationId = med['id'].toString(); 
    final int baseAlarmId = medicationId.hashCode;

    int notificationCount = 0;

    for (int d = 0; d < totalDays; d++) {
      for (int t = 0; t < timesPerDay; t++) {
        if (notificationCount >= 100) break; 

        final int hourOffset = (t * (24 ~/ timesPerDay));
        DateTime scheduledTime = DateTime.now().add(
          Duration(days: d, hours: hourOffset, seconds: 10)
        );

        if (scheduledTime.isAfter(DateTime.now())) {
          // Updated to match new NotificationService method signature
          NotificationService.scheduleMedicationReminder(
            id: baseAlarmId + notificationCount,
            medicationId: medicationId,
            medicationName: med['name'],
            scheduledTime: scheduledTime,
            dosage: med['dosage_strength'], // Optional: pass dosage info
          );
        }
        notificationCount++;
      }
    }
  }

  // --- Add or update medication (index = hive index in box) ---
  Future<void> _addOrUpdateMedication(Map<String, dynamic> med, {int? index}) async {
    final box = await Hive.openBox('medications');
    
    // --- 1. ID and Data Persistence ---
    if (index != null) {
      final existing = index >= 0 && index < medications.length ? medications[index] : null;
      if (med['id'] == null && existing?['id'] != null) {
        med['id'] = existing?['id'];
      }
      med['created_at'] = med['created_at'] ?? existing?['created_at'] ?? DateTime.now().toIso8601String();
      await box.putAt(index, med);
      setState(() {
        medications[index] = med;
      });
    } else {
      if (med['id'] == null) {
        med['id'] = 'local_${DateTime.now().millisecondsSinceEpoch}';
      }
      med['created_at'] = med['created_at'] ?? DateTime.now().toIso8601String();
      await box.add(med);
      final meds = box.values.map((e) => Map<String, dynamic>.from(e)).toList();
      setState(() {
        medications = meds;
      });
    }

    // --- 2. Notification Management ---
    // We use the hashcode of the String ID as the base for our 100 notification slots
    final int baseAlarmId = med['id'].toString().hashCode;
    
    // Clear all 100 potential slots before rescheduling
    // This prevents "ghost" notifications if frequency or duration changed
    for (int i = 0; i < 100; i++) {
      await NotificationService.cancelNotification(baseAlarmId + i);
    }

    // 3. Schedule new reminders if the medication is still within its therapy duration
    final days = _parseDurationToDays(med['duration_of_therapy']);
    final startDate = DateTime.parse(med['created_at']);
    final endDate = startDate.add(Duration(days: days));

    if (DateTime.now().isBefore(endDate)) {
      _scheduleReminders(med);
    }

    // --- 3. UI Refresh ---
    _applyFilters();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          index != null 
              ? "${med['name']} updated successfully!" 
              : "${med['name']} added successfully!",
          style: TextStyle(color: AppColors.lightBackground),
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- Confirm delete using ID (returns bool for confirmDismiss) ---
  Future<bool> _confirmDeleteById(String id) async {
    // Find medication in current list
    final med = medications.firstWhere(
      (m) => m['id'].toString() == id.toString(), 
      orElse: () => {},
    );
    
    if (med.isEmpty) {
      return false;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Delete Medication', 
          style: TextStyle(
            color: AppColors.primaryGreen, 
            fontWeight: FontWeight.bold
          )
        ),
        content: Text(
          'Are you sure you want to delete "${med['name']}"?', 
          style: TextStyle(color: AppColors.deepGreen),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.deepGreen),),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Delete', 
              style: TextStyle(color: AppColors.lightGray),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    try {
      // 1. Open Hive box
      final box = Hive.box('medications'); // Use box if already open, or await Hive.openBox
      
      // 2. Find the correct Hive index by comparing IDs as strings
      int hiveIndex = -1;
      for (int i = 0; i < box.length; i++) {
        final item = box.getAt(i);
        if (item != null && item['id'].toString() == id.toString()) {
          hiveIndex = i;
          break;
        }
      }

      if (hiveIndex == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: Medication not found in storage',
              style: TextStyle(color: AppColors.lightBackground)
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        return false;
      }

      // 3. Delete from Hive
      await box.deleteAt(hiveIndex);

      // 4. Cancel all scheduled notifications (100 possible slots)
      final int baseAlarmId = id.hashCode;
      for (int i = 0; i < 100; i++) {
        await NotificationService.cancelNotification(baseAlarmId + i);
      }

      // 5. Update local state
      setState(() {
        medications.removeWhere((m) => m['id'].toString() == id.toString());
        filteredMedications.removeWhere((m) => m['id'].toString() == id.toString());
      });

      // 6. Send api request
      print(med);
      final response = await sendDataToApi(
        'https://medrepo.fineworksstudio.com/api/patient/medications',
        {'id': med['id']}, // The function will append this to URL
        method: 'DELETE',
      );
      print(response);
      if(response['status'] == true && response['status_code'] < 400)
      {
        // 7. Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '"${med['name']}" deleted successfully!', 
              style: TextStyle(color: AppColors.lightBackground)
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting medication: $e',
            style: TextStyle(color: AppColors.lightBackground)
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      
      return false;
    }
  }

  // --- Time filter callback ---
  void _filterMedications(String filter) {
    setState(() {
      activeFilter = filter;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Filtered by $filter • ${filteredMedications.length} meds",
          style: TextStyle(color: AppColors.primaryGreen),
        ),
        backgroundColor: AppColors.lightBackground,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- Status filter callback ---
  void _filterByStatus(MedicationStatus status) {
    setState(() {
      activeStatus = status;
    });
  }

  // --- Apply both status & time filters ---
  void _applyFilters() {
    final now = DateTime.now();
    List<Map<String, dynamic>> meds = List.from(medications);
    // Status filter
    if (activeStatus == MedicationStatus.active) {
      meds = meds.where((med) {
          final startDate = DateTime.parse(med['created_at']);
          final endDate = startDate.add(Duration(days: _parseDurationToDays(med['duration_of_therapy'])));
          return now.isBefore(endDate);
      }).toList();
    } else if (activeStatus == MedicationStatus.completed) {
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
    final intValue = int.tryParse(RegExp(r'\d+').stringMatch(lower) ?? '0') ?? 0;
    if (lower.contains('week')) return intValue * 7;
    if (lower.contains('month')) return intValue * 30;
    return intValue; // default to days
  }

  List<Map<String, dynamic>> _applyLogicToData(List<Map<String, dynamic>> source) {
    final now = DateTime.now();
    // 1. Filter by Status (Active / Completed / All)
    var filtered = source.where((med) {
      if (activeStatus == MedicationStatus.all) return true;
      
      final startDate = DateTime.parse(med['created_at']);
      final days = _parseDurationToDays(med['duration_of_therapy']);
      final endDate = startDate.add(Duration(days: days));
      
      if (activeStatus == MedicationStatus.active) return now.isBefore(endDate);
      if (activeStatus == MedicationStatus.completed) return now.isAfter(endDate);
      return true;
    });

    // 2. Filter by Timeframe (Week / Month / Year)
    filtered = filtered.where((med) {
      if (activeFilter == 'All') return true;
      
      final date = DateTime.parse(med['created_at']);
      
      if (activeFilter == 'This Week') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return !date.isBefore(startOfWeek) && !date.isAfter(endOfWeek);
      } 
      
      if (activeFilter == 'This Month') {
        return date.year == now.year && date.month == now.month;
      } 
      
      if (activeFilter == 'This Year') {
        return date.year == now.year;
      }
      
      return true;
    });

    // 3. Convert to List and Sort (Newest First)
    final resultList = filtered.toList();
    resultList.sort((a, b) {
      final dateA = DateTime.parse(a['created_at']);
      final dateB = DateTime.parse(b['created_at']);
      return dateB.compareTo(dateA); // Descending order
    });
    
    return resultList;
  }
  // --- Helpers to open edit sheet with correct hive index ---
  Future<void> _openEditSheetById(String id) async {
    final box = await Hive.openBox('medications');
    final hiveList = box.values.map((e) => Map<String, dynamic>.from(e)).toList();
    final hiveIndex = hiveList.indexWhere((m) => m['id'].toString() == id.toString());
    if (hiveIndex == -1) {return;}    
    // find hive index for id
    if (hiveIndex == -1) { return;}
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
    final med = medications.firstWhere(
      (m) => m['id'].toString() == id.toString(), 
      orElse: () => {},
    );
    if (med.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MedicationDetailsSheet(
        name: med['name'],
        frequency: med['frequency'],
        dosage_form: med['dosage_form'],
        quantity: med['quantity'] is int 
          ? med['quantity'] 
          : int.tryParse(med['quantity'].toString()) ?? 0,
        durationOfTherapy: med['duration_of_therapy'],
        createdAt: med['created_at'],
        dosageStrength: med['dosage_strength'],
      ),
    );
  }

  Map<String, int> _calculateTimeCounts(List<Map<String, dynamic>> allMeds) {
    final now = DateTime.now();
    int week = 0;
    int month = 0;
    int year = 0;

    for (var med in allMeds) {
      final date = DateTime.parse(med['created_at']);
      
      // Week Logic
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      if (!date.isBefore(startOfWeek)) week++;
      
      // Month Logic
      if (date.year == now.year && date.month == now.month) month++;
      
      // Year Logic
      if (date.year == now.year) year++;
    }

    return {
      'This Week': week,
      'This Month': month,
      'This Year': year,
    };
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
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
              ),
              child: ValueListenableBuilder(
                valueListenable: Hive.box('medications').listenable(),
                builder: (context, Box box, _) {
                  final allMeds = box.values.map((e) => Map<String, dynamic>.from(e)).toList();
                  final timeCounts = _calculateTimeCounts(allMeds);

                  return TimeFilterRow(
                    selectedFilter: activeFilter,
                    onFilterSelected: _filterMedications,
                    counts: timeCounts,
                  );
                },
              ),
            ),
          ),

          // Status selector
          StatusSelector(selectedStatus: activeStatus, onStatusSelected: _filterByStatus,),
          // Grid of medication cards
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box('medications').listenable(),
              builder: (context, Box box, _) {
                // 1. Pull fresh data from Hive
                final rawMeds = box.values.map((e) => Map<String, dynamic>.from(e)).toList();
                
                // 2. Apply your existing filtering logic to the fresh data
                List<Map<String, dynamic>> displayedMeds = _applyLogicToData(rawMeds);

                if (displayedMeds.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medical_services_outlined, size: 80, color: AppColors.primaryGreen),
                        const SizedBox(height: 20),
                        Text(
                          "No medications found for this timeframe.",
                          style: TextStyle(
                              fontSize: 16,
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
  child: GridView.builder(
    // Remove shrinkWrap and change physics
    physics: const BouncingScrollPhysics(), // ADD THIS
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 0.75,
    ),
    itemCount: displayedMeds.length,
    itemBuilder: (context, index) {
      final data = displayedMeds[index];
      final id = data['id']?.toString() ?? 'item_$index';

      return Dismissible(
        key: Key(id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Icon(Icons.delete, color: AppColors.lightBackground),
        ),
        confirmDismiss: (_) => _confirmDeleteById(id),
        child: GestureDetector(
          onLongPress: () => _openEditSheetById(id),
          onTap: () => _showMedicationDetails(id),
          child: IconTextCard(
            medicationId: id,
            name: data['name'],
            frequency: data['frequency'],
            dosage_form: data['dosage_form'],
            quantity: data['quantity'] != null 
                ? int.tryParse(data['quantity'].toString()) 
                : null,
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
);
              },
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