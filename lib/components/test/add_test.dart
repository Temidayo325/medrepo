import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const CircularProgressIndicator(),
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      try {
        final box = Hive.box('tests');
        final now = DateTime.now();

        final testData = {
          "test": testController.text.trim(),
          "result": resultController.text.trim(),
          "unit": unitController.text.trim(),
          "date": dateController.text.trim(),
          "timestamp": now.toIso8601String(),
        };

        if (isEditing && widget.hiveKey != null) {
          // update existing entry
          await box.put(widget.hiveKey, testData);
        } else {
          // add new entry
          await box.add(testData);
        }

        Navigator.of(context).pop(); // close loader

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? "Test updated successfully!" : "Test added successfully!"),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save test: $e"),
            backgroundColor: Colors.red,
          ),
        );
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
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                isEditing ? "Edit Test" : "Add New Test",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade800,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: testController,
                decoration: const InputDecoration(
                  labelText: "Test Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? "Test name is required" : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: resultController,
                decoration: const InputDecoration(
                  labelText: "Result",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? "Result is required" : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: "Unit (optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Date",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                validator: (value) => value == null || value.isEmpty ? "Test date is required" : null,
                onTap: () async {
                  DateTime initialDate = DateTime.tryParse(dateController.text) ?? DateTime.now();

                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
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
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.blueGrey, width: 2),
                      ),
                      onPressed: () => _saveTest(closeAfterSave: false),
                      child: Text(isEditing ? "Update & Continue" : "Save & Add Another",
                          style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _saveTest(closeAfterSave: true),
                      child: Text(isEditing ? "Update & Close" : "Save & Close",
                          style: const TextStyle(color: Colors.white, fontSize: 16)),
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
