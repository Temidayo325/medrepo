import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../colors.dart';
import '../../components/loader.dart';
import '../../components/snackbar/error.dart';
import '../../components/snackbar/success.dart';
import '../../components/send_post_request.dart';

class AddTestBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? existingTest; // for editing
  final dynamic hiveKey; // key of the test in Hive

  const AddTestBottomSheet({super.key, this.existingTest, this.hiveKey});

  @override
  State<AddTestBottomSheet> createState() => _AddTestBottomSheetState();
}

class _AddTestBottomSheetState extends State<AddTestBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController testController = TextEditingController();
  final TextEditingController resultController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  bool isEditing = false;

  @override
  void initState() {
    super.initState();

    if (widget.existingTest != null) {
      isEditing = true;
      // populate fields with existing values
      testController.text = widget.existingTest!['test'] ?? '';
      resultController.text = widget.existingTest!['result'] ?? '';
      unitController.text = widget.existingTest!['unit'] ?? '';
      dateController.text = widget.existingTest!['date'] ?? '';
    } else {
      // default to today
      final now = DateTime.now();
      dateController.text =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    }
  }

  void _saveTest({bool closeAfterSave = false}) async {
    if (_formKey.currentState!.validate()) {
      // Show loader
      showLoadingDialog(context, message: isEditing ? "Updating test..." : "Saving test...");
      try {
        final box = Hive.box('tests');
        final now = DateTime.now();

        final testData = {
          "name": testController.text.trim(),
          "result": resultController.text.trim(),
          "unit": unitController.text.trim(),
          "date": dateController.text.trim(),
          "timestamp": now.toIso8601String(),
        };
        final response = await sendDataToApi('https://medrepo.fineworksstudio.com/api/patient/routine_test', testData,);
        hideLoadingDialog(context);
        if (response['status'] != true) {
          showErrorSnack(context, response['data'] ??'Failed to update health information',);
          return;
        }
        showSuccessSnack(context, isEditing ? "Test updated successfully" : "Test saved successfully",);
        if (isEditing && widget.hiveKey != null) {
          await box.put(widget.hiveKey, testData);
        } else {
          await box.add(testData);
        }
        if (closeAfterSave) {
          Navigator.pop(context); // close bottom sheet
        } else if (!isEditing) {
          // reset for rapid entry only for new tests
          testController.clear();
          resultController.clear();
          unitController.clear();
          final now = DateTime.now();
          dateController.text =
              "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        }
      } catch (e) {
        Navigator.of(context).pop();
        showErrorSnack(context, 'Failed to update test $e',);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 70,
                  height: 8,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                isEditing ? "Edit Test" : "Add New Test",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: testController,
                cursorColor: AppColors.darkGreen,
                decoration: InputDecoration(
                  labelText: "Test Name",
                  labelStyle: TextStyle(color: AppColors.darkGreen),
                  filled: true,
                  fillColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (value) => value == null || value.isEmpty ? "Test name is required" : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: resultController,
                cursorColor: AppColors.darkGreen,
                decoration: InputDecoration(
                  labelText: "Result",
                  labelStyle: TextStyle(color: AppColors.darkGreen),
                  filled: true,
                  fillColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (value) => value == null || value.isEmpty ? "Result is required" : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: unitController,
                cursorColor: AppColors.darkGreen,
                decoration: InputDecoration(
                  labelText: "Unit (optional)",
                  labelStyle: TextStyle(color: AppColors.darkGreen),
                  filled: true,
                  fillColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: dateController,
                cursorColor: AppColors.darkGreen,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Date",
                  labelStyle: TextStyle(color: AppColors.darkGreen),
                  filled: true,
                  fillColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  suffixIcon: Icon(Icons.calendar_month, color: Color.fromARGB(255, 3, 118, 30),),
                ),
                validator: (value) => value == null || value.isEmpty ? "Test date is required" : null,
                onTap: () async {
                  DateTime initialDate = DateTime.tryParse(dateController.text) ?? DateTime.now();

                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (pickedDate != null) {
                    dateController.text =
                        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.lightBackground,
                        side: BorderSide(color: AppColors.primaryGreen, width: 1),
                      ),
                      onPressed: () => _saveTest(closeAfterSave: false),
                      child: Text(isEditing ? "Update & Continue" : "Save & Add Another",
                          style: TextStyle(color: AppColors.primaryGreen, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _saveTest(closeAfterSave: true),
                      child: Text(isEditing ? "Update & Close" : "Save & Close",
                          style: const TextStyle(color: AppColors.lightBackground, fontSize: 16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
