import 'package:flutter/material.dart';
import '../../colors.dart';
import '../loader.dart';
import '../send_post_request.dart';
import '../snackbar/error.dart';
import '../snackbar/success.dart';

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
  late final TextEditingController _dosageController;
  late final TextEditingController _quantityController;
  late final TextEditingController _therapyController;

  // Dropdown values
  String? _selectedDosageForm;
  String? _selectedFrequency;

  // Dropdown options
  final List<String> _dosageForms = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Suspension',
    'Cream',
    'Lotion',
    'Gutt',
    'Injection',
  ];

  final List<String> _frequencies = [
    'Once daily',
    'Twice daily',
    'Thrice daily',
  ];

  @override
  void initState() {
    super.initState();
    final med = widget.existingMedication;
    
    _nameController = TextEditingController(text: med?['name'] ?? '');
    _dosageController = TextEditingController(text: med?['dosage_strength'] ?? '');
    _quantityController =
        TextEditingController(text: med != null ? med['quantity'].toString() : '');
    _therapyController = TextEditingController(text: med?['duration_of_therapy'] ?? '');
    
    // Initialize dropdown values from existing medication
    _selectedDosageForm = med?['dosage_form'];
    _selectedFrequency = med?['frequency'];
  }

  @override
  void dispose() {
    _nameController.dispose();
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
                Center(
                  child: Container(
                    width: 70,
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  widget.existingMedication == null
                      ? "Add New Medication"
                      : "Edit Medication",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(height: 15),
                _buildTextField(_nameController, "Medication Name"),
                _buildTextField(_dosageController, "Dosage Strength (e.g., 500mg)"),
                _buildDropdownField(
                  label: "Dosage Form",
                  value: _selectedDosageForm,
                  items: _dosageForms,
                  onChanged: (value) {
                    setState(() {
                      _selectedDosageForm = value;
                    });
                  },
                ),
                _buildDropdownField(
                  label: "Frequency",
                  value: _selectedFrequency,
                  items: _frequencies,
                  onChanged: (value) {
                    setState(() {
                      _selectedFrequency = value;
                    });
                  },
                ),
                _buildTextField(_therapyController, "Duration of Therapy (e.g., 2 weeks)"),
                _buildTextField(_quantityController, "Quantity", isNumber: true),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 30),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Validate dropdown selections
                      if (_selectedDosageForm == null) {
                        showErrorSnack(context, 'Please select a dosage form');
                        return;
                      }
                      if (_selectedFrequency == null) {
                        showErrorSnack(context, 'Please select a frequency');
                        return;
                      }

                      // Dismiss keyboard first
                      FocusScope.of(context).unfocus();
                      await Future.delayed(const Duration(milliseconds: 100));
                      
                      final isCreating = widget.existingMedication == null;
                      
                      // Build the payload with consistent formatting
                      final newMed = {
                        'name': _nameController.text.trim(),
                        'dosage_form': _selectedDosageForm!, // Consistent format from dropdown
                        'frequency': _selectedFrequency!,    // Consistent format from dropdown
                        'dosage_strength': _dosageController.text.trim(),
                        'quantity': int.parse(_quantityController.text),
                        'duration_of_therapy': _therapyController.text.trim(),
                      };
                      
                      // CRITICAL: Preserve created_at and ID when updating
                      if (!isCreating) {
                        newMed['created_at'] = widget.existingMedication?['created_at'] ?? 
                                               DateTime.now().toIso8601String();
                      } else {
                        newMed['created_at'] = DateTime.now().toIso8601String();
                      }

                      debugPrint('=== MEDICATION SAVE REQUEST ===');
                      debugPrint('Is Creating: $isCreating');
                      debugPrint('Existing Medication ID: ${widget.existingMedication?['id']}');
                      debugPrint('Payload: $newMed');

                      try {
                        showLoadingDialog(context, message: "Saving medication ...");

                        final String url = isCreating
                            ? "https://medrepo.fineworksstudio.com/api/patient/medications"
                            : "https://medrepo.fineworksstudio.com/api/patient/medications/${widget.existingMedication?['id']}";

                        debugPrint('URL: $url');
                        debugPrint('Method: ${isCreating ? "POST" : "PUT"}');

                        final response = await sendDataToApi(
                          url,
                          newMed,
                          method: isCreating ? "POST" : "PUT",
                        );

                        debugPrint('=== API RESPONSE ===');
                        debugPrint('Status: ${response['status']}');
                        debugPrint('Message: ${response['message']}');
                        debugPrint('Response Data: ${response['data']}');
                        debugPrint('Data ID: ${response['data']?['id']}');
                        debugPrint('===================');

                        if (!mounted) return;
                        hideLoadingDialog(context);

                        if (response['status'] == false) {
                          showErrorSnack(context, response['message']);
                          return;
                        }

                        // CRITICAL: Use the data returned from the server
                        final savedMedication = Map<String, dynamic>.from(response['data']);
                        
                        debugPrint('=== SAVING TO HIVE ===');
                        debugPrint('Saved medication ID: ${savedMedication['id']}');
                        debugPrint('Saved medication: $savedMedication');
                        debugPrint('Index to save at: ${widget.index}');

                        showSuccessSnack(context, response['message']);
                        
                        // Pass the server response (with ID) to the parent
                        widget.onSave(savedMedication, index: widget.index);
                        
                        Navigator.pop(context);
                      } catch (e, stackTrace) {
                        debugPrint('=== ERROR ===');
                        debugPrint('Error: $e');
                        debugPrint('Stack trace: $stackTrace');
                        debugPrint('=============');
                        
                        if (!mounted) return;
                        
                        try {
                          hideLoadingDialog(context);
                        } catch (_) {}
                        
                        showErrorSnack(context, 'Failed to save medication: $e');
                      }
                    }
                  },
                  child: Text(
                    widget.existingMedication == null ? "Save Medication" : "Update Medication",
                    style: TextStyle(color: AppColors.lightBackground, fontSize: 17),
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
        cursorColor: AppColors.darkGreen,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) => value == null || value.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.darkGreen),
          filled: true,
          fillColor: AppColors.primaryGreen.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.darkGreen),
          filled: true,
          fillColor: AppColors.primaryGreen.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryGreen),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(color: AppColors.darkGreen),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "Please select $label" : null,
      ),
    );
  }
}