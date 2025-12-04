import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../colors.dart';
import '../send_post_request.dart'; // your API helper
import '../loader.dart';
import '../snackbar/error.dart';
import '../snackbar/success.dart';

class SymptomsDiaryForm extends StatefulWidget {
  final Map<String, dynamic>? existingSymptom;
  final VoidCallback? onSaved;

  const SymptomsDiaryForm({Key? key, this.existingSymptom, this.onSaved}) : super(key: key);

  @override
  _SymptomsDiaryFormState createState() => _SymptomsDiaryFormState();
}

class _SymptomsDiaryFormState extends State<SymptomsDiaryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _symptomController;
  late TextEditingController _notesController;
  String? _severity;

  final List<String> _severityOptions = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _symptomController = TextEditingController(text: widget.existingSymptom?['symptom'] ?? '');
    _notesController = TextEditingController(text: widget.existingSymptom?['notes'] ?? '');
    _severity = widget.existingSymptom?['severity'];
  }

  @override
  void dispose() {
    _symptomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveSymptom() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final newSymptom = {
      if (widget.existingSymptom != null) 'id': widget.existingSymptom!['id'],
      'symptom': _symptomController.text.trim(),
      'severity': _severity,
      'notes': _notesController.text.trim(),
      'resolved': widget.existingSymptom?['resolved'] ?? false,
      'resolution_date': widget.existingSymptom?['resolution_date'],
      'patient_id': 'CURRENT_PATIENT_UUID', // replace with actual patient ID
    };

    try {
      showLoadingDialog(context, message: "Adding symptom to your diary");
      final url = widget.existingSymptom == null
          ? 'https://medrepo.fineworksstudio.com/api/patient/symptoms'
          : 'https://medrepo.fineworksstudio.com/api/patient/symptoms/${widget.existingSymptom!['id']}';
      final method = widget.existingSymptom == null ? 'POST': 'PUT';
      final response = await sendDataToApi(url, newSymptom, method: method);
      hideLoadingDialog(context);
      
      if (response['status'] == true) {
        final box = Hive.box('symptoms');
        final raw = box.get('entries', defaultValue: []);

        // Properly cast the list and its items
        List<Map<String, dynamic>> current = raw.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();

        // Properly cast the response data
        Map<String, dynamic> symptomData = Map<String, dynamic>.from(response['data'] as Map);

        if (widget.existingSymptom != null) {
          final index = current.indexWhere((e) => e['id'] == widget.existingSymptom!['id']);
          if (index != -1) {
            current[index] = symptomData;
          }
        } else {
          current.add(symptomData);
        }

        await box.put('entries', current);
        showSuccessSnack(context, widget.existingSymptom == null ? "Symptom added successfully" : "Symptom updated successfully");
        widget.onSaved?.call();
        if (mounted) Navigator.pop(context);
      } else {
        showErrorSnack(context, response['message'] ?? 'Failed to save symptom');
      }
    } catch (e) {
      hideLoadingDialog(context);
      showErrorSnack(context, 'Error: ${e.toString()}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 25,
        right: 25,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.darkGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                widget.existingSymptom == null ? 'Add Symptom' : 'Edit Symptom',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
              ),
              SizedBox(height: 25),
              TextFormField(
                controller: _symptomController,
                cursorColor: AppColors.darkGreen,
                decoration: InputDecoration(
                  labelText: 'Symptom',
                  labelStyle: TextStyle(color: AppColors.darkGreen),
                  filled: true,
                  fillColor: AppColors.primaryGreen.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Symptom is required' : null,
              ),
              const SizedBox(height: 25),
              DropdownButtonFormField<String>(
                value: _severity,
                decoration: InputDecoration(
                  labelText: 'Severity',
                  filled: true,
                  fillColor: AppColors.primaryGreen.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: _severityOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _severity = val),
                validator: (v) => v == null ? 'Severity is required' : null,
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  filled: true,
                  fillColor: AppColors.primaryGreen.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Material(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primaryGreen,
                elevation: 3,
                child: InkWell(
                  onTap: _saveSymptom,
                  borderRadius: BorderRadius.circular(12),
                  splashColor: Colors.white.withValues(alpha: 0.2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      widget.existingSymptom == null ? 'Save Symptom' : 'Update Symptom',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}