import 'package:flutter/material.dart';

class NewMedicationSheet extends StatefulWidget {
  final Function(Map<String, dynamic> med, {int? index}) onSave;
  final Map<String, dynamic>? existingMedication; // optional for edit
  final int? index; // optional for edit

  const NewMedicationSheet({
    Key? key,
    required this.onSave,
    this.existingMedication,
    this.index,
  }) : super(key: key);

  @override
  _NewMedicationSheetState createState() => _NewMedicationSheetState();
}

class _NewMedicationSheetState extends State<NewMedicationSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _formController;
  late final TextEditingController _durationController;
  late final TextEditingController _dosageController;
  late final TextEditingController _quantityController;
  late final TextEditingController _therapyController;

  @override
  void initState() {
    super.initState();
    final med = widget.existingMedication;
    _nameController = TextEditingController(text: med?['name'] ?? '');
    _formController = TextEditingController(text: med?['form'] ?? '');
    _durationController = TextEditingController(text: med?['duration'] ?? '');
    _dosageController = TextEditingController(text: med?['dosage_strength'] ?? '');
    _quantityController =
        TextEditingController(text: med != null ? med['quantity'].toString() : '');
    _therapyController = TextEditingController(text: med?['duration_of_therapy'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _formController.dispose();
    _durationController.dispose();
    _dosageController.dispose();
    _quantityController.dispose();
    _therapyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.existingMedication == null
                      ? "Add New Medication"
                      : "Edit Medication",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                _buildTextField(_nameController, "Name"),
                _buildTextField(_formController, "Form (tablet, syrup, etc)"),
                _buildTextField(_durationController, "Duration (e.g., 500mg • 2x daily)"),
                _buildTextField(_dosageController, "Dosage Strength"),
                _buildTextField(_quantityController, "Quantity", isNumber: true),
                _buildTextField(_therapyController, "Duration of Therapy (e.g., 2 weeks)"),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 30),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newMed = {
                        'name': _nameController.text,
                        'form': _formController.text,
                        'duration': _durationController.text,
                        'dosage_strength': _dosageController.text,
                        'quantity': int.parse(_quantityController.text),
                        'duration_of_therapy': _therapyController.text,
                        'created_at': widget.existingMedication?['created_at'] ??
                            DateTime.now().toIso8601String(),
                      };
                      widget.onSave(newMed, index: widget.index);
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    widget.existingMedication == null ? "Save Medication" : "Update Medication",
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) => value == null || value.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
