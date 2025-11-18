import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'components/app_title.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 🩺 Helper: get latest test by name
  Future<Map<String, dynamic>?> getLatestTest(String testName) async {
    final box = await Hive.openBox('tests');
    final tests = box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final lowerName = testName.toLowerCase();
    final filtered = tests.where(
      (t) => (t['test'] ?? "").toString().toLowerCase() == lowerName,
    ).toList();

    if (filtered.isEmpty) return null;

    filtered.sort((a, b) =>
        DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));

    return filtered.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: ValueListenableBuilder(
          valueListenable: Hive.box('profile').listenable(),
          builder: (context, box, _) {
            final profile = box.get('profile', defaultValue: {});
            final firstName = (profile["name"] ?? "").trim().split(" ").first;
            return CustomAppBar(
              title: "Hello $firstName",
              colors: Colors.blueGrey,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              margin: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blueGrey.shade50,
                    Colors.blueGrey.shade200,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Welcome to your health and wellness dashboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SvgPicture.asset(
                    'assets/dashboard.svg',
                    height: 100,
                    width: 80,
                  ),
                ],
              ),
            ),

            // 🔹 Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                "Here's your health in a glance",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Stats Row 1
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                  FutureBuilder<Map<String, dynamic>?>(
                    future: getLatestTest("Blood Pressure"),
                    builder: (context, snapshot) {
                      final bp = snapshot.data;
                      return _HealthCard(
                        title: "Blood Pressure",
                        value: bp?['result'] ?? "--",
                        unit: bp?['unit'] ?? "",
                        target: "<120/80 mmHg",
                        date: bp?['date'] ?? "No record",
                        icon: Icons.monitor_heart_outlined,
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  FutureBuilder<Map<String, dynamic>?>(
                    future: getLatestTest("Fasting Blood Sugar"),
                    builder: (context, snapshot) {
                      final fbs = snapshot.data;
                      return _HealthCard(
                        title: "Fasting Sugar",
                        value: fbs?['result'] ?? "--",
                        unit: fbs?['unit'] ?? "",
                        target: "<100 mg/dL",
                        date: fbs?['date'] ?? "No record",
                        icon: Icons.bloodtype_outlined,
                      );
                    },
                  ),
                ],
              ),
            ),

            // 🔹 Stats Row 2
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              child: Row(
                children: [
                  FutureBuilder<Map<String, dynamic>?>(
                    future: getLatestTest("Blood Cholesterol"),
                    builder: (context, snapshot) {
                      final chol = snapshot.data;
                      return _HealthCard(
                        title: "Blood Cholesterol",
                        value: chol?['result'] ?? "--",
                        unit: chol?['unit'] ?? "",
                        target: "<200 mg/dL",
                        date: chol?['date'] ?? "No record",
                        icon: Icons.food_bank,
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  FutureBuilder<Map<String, dynamic>?>(
                    future: getLatestTest("Blood PCV"),
                    builder: (context, snapshot) {
                      final pcv = snapshot.data;
                      return _HealthCard(
                        title: "Heamatocrit",
                        value: pcv?['result'] ?? "--",
                        unit: pcv?['unit'] ?? "%",
                        target: "34–54%",
                        date: pcv?['date'] ?? "No record",
                        icon: Icons.biotech_outlined,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🩺 Reusable Health Card Widget
class _HealthCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String target;
  final String date;
  final IconData icon;

  const _HealthCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.target,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey.shade50,
              Colors.blueGrey.shade200,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.blueGrey.shade400),
                const Spacer(),
                Text(
                  target,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 16, color: Colors.blueGrey.shade400),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
