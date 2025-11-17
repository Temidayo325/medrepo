import 'package:flutter/material.dart';
import 'components/test_card.dart';
import 'components/app_title.dart';
import 'components/test/add_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TestResultsPage extends StatelessWidget {
  TestResultsPage({super.key});

  IconData getTestIcon(String test) {
    if (test.contains('Blood')) return Icons.bloodtype_rounded;
    if (test.contains('Cholesterol')) return Icons.favorite_rounded;
    if (test.contains('PSA')) return Icons.male_rounded;
    if (test.contains('Hepatitis') || test.contains('HIV')) return Icons.biotech_rounded;
    if (test.contains('Malaria')) return Icons.bug_report_rounded;
    if (test.contains('COVID')) return Icons.coronavirus_rounded;
    return Icons.science_rounded;
  }

  void _openAddTestSheet(BuildContext context, {Map<String, dynamic>? existingTest, dynamic hiveKey}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddTestBottomSheet(
        existingTest: existingTest,
        hiveKey: hiveKey,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final box = Hive.box('tests');

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBar(
        title: 'Test results',
        colors: Colors.white,
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, Box testBox, _) {
            final testResults = testBox.values.toList().cast<Map>();

            // Sort by timestamp descending
            testResults.sort((a, b) {
              final tsA = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(2000);
              final tsB = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(2000);
              return tsB.compareTo(tsA);
            });

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: testResults.isEmpty
                  ? Center(
                      key: const ValueKey('empty_state'),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.science_rounded, size: 80, color: Colors.blueGrey.shade200),
                          const SizedBox(height: 10),
                          Text(
                            "No tests added yet",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _openAddTestSheet(context),
                            icon: const Icon(Icons.add, color: Colors.white, size: 25),
                            label: const Text("Add New Test", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      key: const ValueKey('list_view'),
                      physics: const BouncingScrollPhysics(),
                      itemCount: testResults.length,
                      itemBuilder: (context, index) {
                        final item = testResults[index];
                        final key = testBox.keyAt(index);

                        return Dismissible(
                          key: Key(key.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text("Delete Test", style: TextStyle(color: Colors.blueGrey)),
                                content: Text("Are you sure you want to delete this test?", style: TextStyle(color: Colors.blueGrey),),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text("Cancel", style: TextStyle(color: Colors.blueGrey),),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text("Delete", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            return confirmed ?? false;
                          },
                          onDismissed: (direction) async {
                            await testBox.delete(key);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Test deleted successfully!")),
                            );
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                            child: TestCard(
                              test: item['test']!,
                              result: item['result']!,
                              date: item['date']!,
                              unit: item['unit']!,
                              icon: getTestIcon(item['test']!), 
                            ),
                          ),
                        );
                      },
                    ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () => _openAddTestSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
