import 'package:flutter/material.dart';
import 'components/test_card.dart';
import 'components/app_title.dart';

class TestResultsPage extends StatelessWidget {
  TestResultsPage({super.key});

  // Placeholder test data (you’ll later replace this with API data)
  final List<Map<String, String>> testResults = [
    {'test': 'Blood Pressure', 'result': '120/80', 'unit': 'mmHg', 'date': '2025-11-03'},
    {'test': 'Fasting Blood Sugar', 'result': '92', 'unit': 'mg/dL', 'date': '2025-11-04'},
    {'test': 'Total Cholesterol', 'result': '180', 'unit': 'mg/dL', 'date': '2025-11-05'},
    {'test': 'LDL Cholesterol', 'result': '110', 'unit': 'mg/dL', 'date': '2025-11-05'},
    {'test': 'HDL Cholesterol', 'result': '55', 'unit': 'mg/dL', 'date': '2025-11-05'},
    {'test': 'PSA (Prostate Specific Antigen)', 'result': '2.3', 'unit': 'ng/mL', 'date': '2025-11-06'},
    {'test': 'Hepatitis B Surface Antigen (HBsAg)', 'result': 'Negative', 'unit': '', 'date': '2025-11-06'},
    {'test': 'HIV 1 & 2 Screening', 'result': 'Non-reactive', 'unit': '', 'date': '2025-11-06'},
    {'test': 'Malaria Parasite Test', 'result': 'Negative', 'unit': '', 'date': '2025-11-07'},
    {'test': 'COVID-19 PCR Test', 'result': 'Not Detected', 'unit': '', 'date': '2025-11-07'},
  ];

  IconData getTestIcon(String test) {
    if (test.contains('Blood')) return Icons.bloodtype_rounded;
    if (test.contains('Cholesterol')) return Icons.favorite_rounded;
    if (test.contains('PSA')) return Icons.male_rounded;
    if (test.contains('Hepatitis') || test.contains('HIV')) return Icons.biotech_rounded;
    if (test.contains('Malaria')) return Icons.bug_report_rounded;
    if (test.contains('COVID')) return Icons.coronavirus_rounded;
    return Icons.science_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBar(
        title: 'Test results',
        colors: Colors.white,
        backgroundColor: Colors.blueGrey,
        ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: testResults.length,
          itemBuilder: (context, index) {
            final item = testResults[index];
            return TestCard(
              test: item['test']!,
              result: item['result']!,
              date: item['date']!,
              icon: getTestIcon(item['test']!),
              unit: item['unit']!
            );
          },
        ),
      ),
    );
  }
}
