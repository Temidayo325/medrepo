import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
import '../../colors.dart';
import '../empty_state.dart';

Future<void> showViralPanelBottomSheet(
    BuildContext context, List<Map<String, String>> viralPanel) async {
  if (!context.mounted) return;

  // Optional Hive box
  // final box = Hive.box('viralPanel');

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag indicator
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

                // Title
                const Text(
                  "Viral Panel",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 40),
                  itemCount: viralPanel.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,       // 2 boxes per row
                    mainAxisSpacing: 30,      // vertical space between rows
                    crossAxisSpacing: 20,     // horizontal space between boxes
                    mainAxisExtent: 120,      // fixed height for all boxes
                  ),
                  itemBuilder: (context, index) {
                    final test = viralPanel[index];
                    final shortName = test['short_name'] ?? '--';
                    final result = test['result'] ?? '';
                    final date = test['date'] ?? '--';

                    if (result.isEmpty) {
                      return EmptyState(icon: Icons.bug_report, message: "$shortName test unavailable", color: const Color.fromARGB(255, 94, 145, 103),);
                    }

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen, // green background for filled tests
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Short Name with virus icon
                          Row(
                            children: [
                              const Icon(
                                Icons.bug_report,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  shortName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Result centered
                          Center(
                            child: Text(
                              result,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          // Date with calendar icon
                          Row(
                            children: [
                              const Icon(
                                Icons.date_range,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                date,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                ),
// Viral Panel List                
                const SizedBox(height: 40), // bottom padding after last row
              ],
            ),
          ),
        ),
      );
    },
  );
}
