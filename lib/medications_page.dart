import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'components/app_title.dart';
import 'components/medication/time_flow.dart';
import 'components/medication/status_selector.dart';
import 'components/medication/med_overview_card.dart';
import 'components/medication/med_details.dart';
import 'components/medication/new_medication_sheet.dart';
import 'components/medication/sync_medication_log.dart';
import 'colors.dart';
import 'components/notifications.dart';
import 'components/send_post_request.dart';

class MedicationPage extends StatefulWidget {
  @override
  _MedicationPageState createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  final SyncService _syncService = SyncService();
  
  List<Map<String, dynamic>> medications = [];
  MedicationStatus activeStatus = MedicationStatus.all;
  String activeFilter = 'All';
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  // --- SYNC MEDICATION LOGS (Pull-to-Refresh) ---
  Future<void> _syncMedicationLogs() async {
    if (_isSyncing) return;
    
    setState(() {
      _isSyncing = true;
    });

    try {
      await _syncService.syncLogs();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ Medication logs synced successfully',
              style: TextStyle(color: AppColors.lightBackground),
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sync failed. Logs saved locally.',
              style: TextStyle(color: AppColors.lightBackground),
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  // --- LOAD MEDICATIONS ---
  Future<void> _loadMedications() async {
    final box = await Hive.openBox('medications');
    final raw = box.values.map((e) => Map<String, dynamic>.from(e)).toList();

    bool changed = false;
    for (int i = 0; i < raw.length; i++) {
      final med = raw[i];
      if (med['id'] == null) {
        med['id'] = 'local_${DateTime.now().millisecondsSinceEpoch}_$i';
        await box.putAt(i, med);
        changed = true;
      }
    }

    final meds = box.values.map((e) => Map<String, dynamic>.from(e)).toList();

    setState(() {
      medications = meds;
    });
  }

  // --- SCHEDULE REMINDERS ---
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
          NotificationService.scheduleMedicationReminder(
            id: baseAlarmId + notificationCount,
            medicationId: medicationId,
            medicationName: med['name'],
            scheduledTime: scheduledTime,
            dosage: med['dosage_strength'],
          );
        }
        notificationCount++;
      }
    }
  }

  // --- ADD OR UPDATE MEDICATION ---
  Future<void> _addOrUpdateMedication(Map<String, dynamic> med, {int? index}) async {
    final box = await Hive.openBox('medications');
    
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

    final int baseAlarmId = med['id'].toString().hashCode;
    for (int i = 0; i < 100; i++) {
      await NotificationService.cancelNotification(baseAlarmId + i);
    }

    final days = _parseDurationToDays(med['duration_of_therapy']);
    final startDate = DateTime.parse(med['created_at']);
    final endDate = startDate.add(Duration(days: days));

    if (DateTime.now().isBefore(endDate)) {
      _scheduleReminders(med);
    }

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

  // --- CONFIRM DELETE ---
  Future<bool> _confirmDeleteById(String id) async {
    final med = medications.firstWhere(
      (m) => m['id'].toString() == id.toString(), 
      orElse: () => {},
    );
    
    if (med.isEmpty) return false;

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
            child: Text('Cancel', style: TextStyle(color: AppColors.deepGreen)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: AppColors.lightGray)),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    try {
      final box = Hive.box('medications');
      
      int hiveIndex = -1;
      for (int i = 0; i < box.length; i++) {
        final item = box.getAt(i);
        if (item != null && item['id'].toString() == id.toString()) {
          hiveIndex = i;
          break;
        }
      }

      if (hiveIndex == -1) {
        _showError('Medication not found in storage');
        return false;
      }

      await box.deleteAt(hiveIndex);

      final int baseAlarmId = id.hashCode;
      for (int i = 0; i < 100; i++) {
        await NotificationService.cancelNotification(baseAlarmId + i);
      }

      setState(() {
        medications.removeWhere((m) => m['id'].toString() == id.toString());
      });

      final response = await sendDataToApi(
        'https://medrepo.fineworksstudio.com/api/patient/medications',
        {'id': med['id']},
        method: 'DELETE',
      );
      
      if (response['status'] == true && response['status_code'] < 400) {
        _showSuccess('"${med['name']}" deleted successfully!');
      }

      return true;
    } catch (e) {
      _showError('Error deleting medication: $e');
      return false;
    }
  }

  // --- FILTER CALLBACKS ---
  void _filterByStatus(MedicationStatus status) {
    setState(() {
      activeStatus = status;
    });
  }

  void _filterMedications(String filter) {
    setState(() {
      activeFilter = filter;
    });
  }

  // --- APPLY FILTERS ---
  List<Map<String, dynamic>> _applyLogicToData(List<Map<String, dynamic>> source) {
    final now = DateTime.now();
    
    var filtered = source.where((med) {
      if (activeStatus == MedicationStatus.all) return true;
      
      final startDate = DateTime.parse(med['created_at']);
      final days = _parseDurationToDays(med['duration_of_therapy']);
      final endDate = startDate.add(Duration(days: days));
      
      if (activeStatus == MedicationStatus.active) return now.isBefore(endDate);
      if (activeStatus == MedicationStatus.completed) return now.isAfter(endDate);
      return true;
    });

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

    final resultList = filtered.toList();
    resultList.sort((a, b) {
      final dateA = DateTime.parse(a['created_at']);
      final dateB = DateTime.parse(b['created_at']);
      return dateB.compareTo(dateA);
    });
    
    return resultList;
  }

  // --- OPEN EDIT SHEET ---
  Future<void> _openEditSheetById(String id) async {
    final box = await Hive.openBox('medications');
    final hiveList = box.values.map((e) => Map<String, dynamic>.from(e)).toList();
    final hiveIndex = hiveList.indexWhere((m) => m['id'].toString() == id.toString());
    
    if (hiveIndex == -1) return;
    
    final existingMed = hiveList[hiveIndex];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => NewMedicationSheet(
        onSave: _addOrUpdateMedication,
        existingMedication: existingMed,
        index: hiveIndex,
      ),
    );
  }

  // --- SHOW DETAILS ---
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
        medicationId: id,
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

  // --- CALCULATE TIME COUNTS ---
  Map<String, int> _calculateTimeCounts(List<Map<String, dynamic>> allMeds) {
    final now = DateTime.now();
    int week = 0;
    int month = 0;
    int year = 0;

    for (var med in allMeds) {
      final date = DateTime.parse(med['created_at']);
      
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      if (!date.isBefore(startOfWeek)) week++;
      
      if (date.year == now.year && date.month == now.month) month++;
      
      if (date.year == now.year) year++;
    }

    return {
      'This Week': week,
      'This Month': month,
      'This Year': year,
    };
  }

  // --- HELPER FUNCTIONS ---
  int _parseFrequencyToInt(String frequency) {
    final lower = frequency.toLowerCase();
    if (lower.contains('1x') || lower.contains('once')) return 1;
    if (lower.contains('2x') || lower.contains('twice')) return 2;
    if (lower.contains('3x') || lower.contains('thrice')) return 3;
    if (lower.contains('4x')) return 4;
    return 1;
  }

  int _parseDurationToDays(String duration) {
    final lower = duration.toLowerCase();
    final intValue = int.tryParse(RegExp(r'\d+').stringMatch(lower) ?? '0') ?? 0;
    if (lower.contains('week')) return intValue * 7;
    if (lower.contains('month')) return intValue * 30;
    return intValue;
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: AppColors.lightBackground)),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: AppColors.lightBackground)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
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
      body: RefreshIndicator(
        onRefresh: _syncMedicationLogs,
        color: AppColors.primaryGreen,
        backgroundColor: AppColors.lightBackground,
        child: Column(
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
            StatusSelector(
              selectedStatus: activeStatus, 
              onStatusSelected: _filterByStatus,
            ),

            // Syncing indicator
            if (_isSyncing)
              Container(
                padding: EdgeInsets.all(8),
                color: AppColors.primaryGreen.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Syncing medication logs...',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

            // Grid of medication cards
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box('medications').listenable(),
                builder: (context, Box box, _) {
                  final rawMeds = box.values.map((e) => Map<String, dynamic>.from(e)).toList();
                  List<Map<String, dynamic>> displayedMeds = _applyLogicToData(rawMeds);

                  if (displayedMeds.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medical_services_outlined, size: 80, color: AppColors.primaryGreen),
                            const SizedBox(height: 20),
                            Text(
                              "No medications found for this timeframe.",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Pull down to sync",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                            child: ValueListenableBuilder(
                              valueListenable: Hive.box('medication_logs').listenable(),
                              builder: (context, Box logBox, _) {
                                return IconTextCard(
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
                                );
                              },
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => NewMedicationSheet(onSave: _addOrUpdateMedication),
          );
        },
        icon: Icon(Icons.add, color: AppColors.lightBackground, size: 30),
        label: Text(
          "Add Medication", 
          style: TextStyle(color: AppColors.lightBackground, fontSize: 15)
        ),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }
}