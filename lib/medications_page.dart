import 'package:flutter/material.dart';
import 'components/app_title.dart';
import 'profile_page.dart';
import 'components/medication/time_flow.dart';
import 'components/medication/week_selector.dart';
import 'components/medication/med_overview_card.dart';

class MedicationPage extends StatelessWidget
{
  final List<Map<String, dynamic>> medications = [
    {
      'drug': 'Metformin',
      'form': 'tablet',
      'duration': '500mg • 2x daily',
      'quantity': 30,
    },
    {
      'drug': 'Insulin',
      'form': 'injection',
      'duration': 'Before meals',
      'quantity': 10,
    },
    {
      'drug': 'Atorvastatin',
      'form': 'tablet',
      'duration': 'Once nightly',
      'quantity': 28,
    },
    {
      'drug': 'Amoxicillin',
      'form': 'capsule',
      'duration': '1 cap • 8hrly',
      'quantity': 21,
    },
    {
      'drug': 'Vitamin D3',
      'form': 'tablet',
      'duration': '1 tab weekly',
      'quantity': 12,
    },
    {
      'drug': 'Cough Syrup',
      'form': 'syrup',
      'duration': '10ml • 3x daily',
      'quantity': 1,
    },
    {
      'drug': 'Aspirin',
      'form': 'tablet',
      'duration': '75mg daily',
      'quantity': 30,
    },
    {
      'drug': 'Diclofenac',
      'form': 'gel',
      'duration': 'Apply 2x daily',
      'quantity': 1,
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
                    name: data['drug'],
                    duration: data['duration'],
                    form: data['form'],
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