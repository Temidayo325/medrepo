import 'package:flutter/material.dart';
import 'components/app_title.dart';
import 'components/medication/time_flow.dart';
import 'components/medication/week_selector.dart';
import 'components/medication/med_overview_card.dart';
import 'components/medication/med_details.dart';

class MedicationPage extends StatelessWidget
{
  final List<Map<String, dynamic>> medications = [
  {
    'name': 'Metformin',
    'form': 'tablet',
    'duration': '500mg • 2x daily',
    'dosage_strength': '500mg',
    'quantity': 30,
    'duration_of_therapy': '2 weeks',
    'created_at': '2025-11-01',
  },
  {
    'name': 'Insulin',
    'form': 'injection',
    'duration': 'Before meals',
    'dosage_strength': '10 units',
    'quantity': 10,
    'duration_of_therapy': '1 week',
    'created_at': '2025-11-03',
  },
  {
    'name': 'Atorvastatin',
    'form': 'tablet',
    'duration': 'Once nightly',
    'dosage_strength': '20mg',
    'quantity': 28,
    'duration_of_therapy': '4 weeks',
    'created_at': '2025-11-02',
  },
  {
    'name': 'Amoxicillin',
    'form': 'capsule',
    'duration': '1 cap • 8hrly',
    'dosage_strength': '500mg',
    'quantity': 21,
    'duration_of_therapy': '7 days',
    'created_at': '2025-11-04',
  },
  {
    'name': 'Vitamin D3',
    'form': 'tablet',
    'duration': '1 tab weekly',
    'dosage_strength': '1000 IU',
    'quantity': 12,
    'duration_of_therapy': '12 weeks',
    'created_at': '2025-11-01',
  },
  {
    'name': 'Cough Syrup',
    'form': 'syrup',
    'duration': '10ml • 3x daily',
    'dosage_strength': '10ml',
    'quantity': 1,
    'duration_of_therapy': '3 days',
    'created_at': '2025-11-05',
  },
  {
    'name': 'Aspirin',
    'form': 'tablet',
    'duration': '75mg daily',
    'dosage_strength': '75mg',
    'quantity': 30,
    'duration_of_therapy': '1 month',
    'created_at': '2025-11-03',
  },
  {
    'name': 'Diclofenac',
    'form': 'gel',
    'duration': 'Apply 2x daily',
    'dosage_strength': '50mg/g',
    'quantity': 1,
    'duration_of_therapy': '7 days',
    'created_at': '2025-11-06',
  },
];

  @override
  Widget build(BuildContext context)
  {
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
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: TimeFilterRow(),
          ),
          WeekSelector(),
          Expanded(
            child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: SingleChildScrollView(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // let outer scroll handle it
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.8,
                ),
                itemCount: medications.length,
                itemBuilder: (context, index) {
                  final data = medications[index];
                  return IconTextCard(
                    name: data['name'],
                    duration: data['duration'],
                    form: data['form'],
                    quantity: data['quantity'],
                    durationOfTherapy: data['duration_of_therapy'],
                    onTap: () {
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
                    },
                  );
                },
              ),
            ),
          ),
          )
        ]
      )
    );
  }
}