import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AddTestBottomSheet extends StatefulWidget {
  const AddTestBottomSheet({super.key});

  @override
  State<AddTestBottomSheet> createState() => _AddTestBottomSheetState();
}

class _AddTestBottomSheetState extends State<AddTestBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController testController = TextEditingController();
  final TextEditingController resultController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default to today
    final now = DateTime.now();
    dateController.text =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  void _saveTest({bool closeAfterSave = false}) async {
    if (_formKey.currentState!.validate()) {
      // Show loading modal
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

        final newTest = {
          "test": testController.text.trim(),
          "result": resultController.text.trim(),
          "unit": unitController.text.trim(),
          "date": dateController.text.trim(),
          "timestamp": now.toIso8601String(), // full timestamp
        };

        await box.add(newTest);

        // Close loader
        Navigator.of(context).pop();

        // Show success notification
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Test added successfully!"),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );

        if (closeAfterSave) {
          Navigator.pop(context); // Close bottom sheet
        } else {
          // Reset form for rapid entry
          testController.clear();
          resultController.clear();
          unitController.clear();
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
              /// --- DRAG HANDLE ---
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

              /// --- Title ---
              Text(
                "Add New Test",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade800,
                ),
              ),
              const SizedBox(height: 30),

              /// --- Test Name ---
              TextFormField(
                controller: testController,
                decoration: const InputDecoration(
                  labelText: "Test Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Test name is required" : null,
              ),
              const SizedBox(height: 18),

              /// --- Result ---
              TextFormField(
                controller: resultController,
                decoration: const InputDecoration(
                  labelText: "Result",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Result is required" : null,
              ),
              const SizedBox(height: 18),

              /// --- Unit (optional) ---
              TextFormField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: "Unit (optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),

              /// --- Date picker ---
              TextFormField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Date",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Test date is required" : null,
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

              /// --- Save Buttons ---
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.white, // button fill color
                        side: BorderSide(color: Colors.blueGrey, width: 2),
                      ),
                      onPressed: () => _saveTest(closeAfterSave: false),
                      child: const Text(
                        "Save & Add Another",
                        style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                      ),
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
                      child: const Text(
                        "Save & Close",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
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
