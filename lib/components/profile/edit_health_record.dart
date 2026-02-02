import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../colors.dart';
import '../loader.dart';
import '../snackbar/error.dart';
import '../send_post_request.dart';

class EditHealthInfoDialog {
  final BuildContext context;
  final Map<String, dynamic> currentData;

  EditHealthInfoDialog(this.context, this.currentData);

  void show() {
    final heightController = TextEditingController(
        text: currentData['height']?.toString() ?? '');
    final weightController = TextEditingController(
        text: currentData['weight']?.toString() ?? '');
    final conditionsController = TextEditingController(
        text: currentData['chronic_conditions'] ?? '');
    final allergiesController = TextEditingController(
        text: currentData['allergies'] ?? '');
    final familyHistoryController = TextEditingController(
        text: currentData['family_history'] ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Health Information',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen),
              ),
              SizedBox(height: 20),

              // Height + Weight row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: heightController,
                      cursorColor: AppColors.darkGreen,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Height (cm)',
                        labelStyle: TextStyle(color: AppColors.darkGreen),
                        prefixIcon: Icon(Icons.height, color: AppColors.darkGreen),
                        filled: true,
                        fillColor: AppColors.primaryGreen.withValues(alpha: 0.08),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: weightController,
                      cursorColor: AppColors.darkGreen,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        labelStyle: TextStyle(color: AppColors.darkGreen),
                        prefixIcon: Icon(Icons.monitor_weight, color: AppColors.darkGreen,),
                        filled: true,
                        fillColor: AppColors.primaryGreen.withValues(alpha: 0.08),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              TextField(
                controller: conditionsController,
                cursorColor: AppColors.darkGreen,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Chronic Conditions',
                  labelStyle: TextStyle(color: AppColors.darkGreen),
                  hintText: 'e.g., Diabetes Type 2, Hypertension',
                  prefixIcon: Icon(Icons.local_hospital, color: AppColors.darkGreen),
                  filled: true,
                  fillColor: AppColors.primaryGreen.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              SizedBox(height: 16),

              TextField(
                controller: allergiesController,
                cursorColor: AppColors.darkGreen,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Allergies',
                  labelStyle: TextStyle(color: AppColors.darkGreen),
                  hintText: 'e.g., Penicillin, Peanuts',
                  prefixIcon: Icon(Icons.warning_amber_rounded, color: AppColors.darkGreen),
                  filled: true,
                  fillColor: AppColors.primaryGreen.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              SizedBox(height: 16),

              TextField(
                controller: familyHistoryController,
                cursorColor: AppColors.darkGreen,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Family History',
                  labelStyle: TextStyle(color: AppColors.darkGreen),
                  hintText: 'e.g., Hypertension, Diabetes, Kidney Disease',
                  prefixIcon: Icon(Icons.warning_amber_rounded, color: AppColors.darkGreen),
                  filled: true,
                  fillColor: AppColors.primaryGreen.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              
              SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final payload = {
                    'height': double.tryParse(heightController.text) ?? 0,
                    'weight': double.tryParse(weightController.text) ?? 0,
                    'chronic_conditions': conditionsController.text,
                    'allergies': allergiesController.text,
                    'family_history': familyHistoryController.text,
                  };

                  showLoadingDialog(
                    context,
                    message: "Updating your health information...",
                  );

                  final response = await sendDataToApi(
                    'https://medrepo.fineworksstudio.com/api/patient/profile',
                    payload,
                  );

                  hideLoadingDialog(context);

                  if (response['status'] != true) {
                    showErrorSnack(
                      context,
                      response['data'] ??
                          'Failed to update health information',
                    );
                    return;
                  }

                  // Save to Hive
                  final patientProfileBox = Hive.box('patientProfile');
                  await patientProfileBox.putAll(payload);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Health information updated',
                        style: TextStyle(color: AppColors.mintGreen),
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
