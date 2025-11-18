import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'components/app_title.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              title: "Hello $firstName",      // <-- AUTOMATICALLY UPDATES
              colors: Colors.blueGrey,   // optional
            );
          },
        ),
      ),

      // 🌿 BODY
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
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
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

            // 🔹 Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                  // Card 1
                  _HealthCard(
                    title: "Blood Pressure",
                    value: "120/80",
                    unit: "mmHg",
                    target: "<120/80mmHg",
                    date: "04/05/2025",
                    icon: Icons.monitor_heart_outlined,
                  ),
                  const SizedBox(width: 20),
                  // Card 2
                  _HealthCard(
                    title: "Fasting Sugar",
                    value: "95",
                    unit: "mg/dL",
                    target: "<100mg/dL",
                    date: "03/05/2025",
                    icon: Icons.bloodtype_outlined,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              child: Row(
                children: [
                  // Card 1
                  _HealthCard(
                    title: "Blood Cholesterol",
                    value: "150",
                    unit: "md/dL",
                    target: "<200mg/dL",
                    date: "07/02/2025",
                    icon: Icons.food_bank,
                  ),
                  const SizedBox(width: 20),
                  // Card 2
                  _HealthCard(
                    title: "Heamatocrit",
                    value: "38",
                    unit: "%",
                    target: ">34%",
                    date: "15/10/2025",
                    icon: Icons.biotech_outlined,
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
                SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 16, color: Colors.blueGrey.shade400),
                SizedBox(width: 8),
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
