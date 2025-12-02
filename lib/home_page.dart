import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'components/app_title.dart';
import 'colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  ValueNotifier<int?> selectedHealthCard = ValueNotifier(null);
  // 🩺 Helper: get latest test by name
  Future<Map<String, dynamic>?> getLatestTest(String testName) async {
    final box = await Hive.openBox('tests');
    final tests = box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final lowerName = testName.toLowerCase();
    final filtered = tests.where(
      (t) => (t['name'] ?? "").toString().toLowerCase() == lowerName,
    ).toList();

    if (filtered.isEmpty) return null;

    filtered.sort((a, b) =>
        DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));

    return filtered.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: ValueListenableBuilder(
          valueListenable: Hive.box('profile').listenable(),
          builder: (context, box, _) {
            final preProfile = Hive.box('profile');
            final profile = preProfile.toMap();
            final firstName = (profile["name"] ?? "").trim().split(" ").first;
            return CustomAppBar(
              title: "Hello $firstName",
              colors: AppColors.primaryGreen,
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
                    Color(0xFF3EB06F),// primary green
                    Color(0xFF6FDCA1), 
                    // Color(0xFF3EB06F),// primary green
                    // Color(0xFF2A8C56), 
                    Color(0xFF3EB06F).withValues(alpha: 0.9),
                    // Color(0xFF3EB06F).withValues(alpha: 0.4),
                    // Color(0xFF3EB06F),   // primary green
                    // Color(0xFFF7F8FC)
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
                        color: AppColors.lightBackground,
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
                  color: AppColors.primaryGreen,
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
                      return HealthCard(
                        index: 0,
                        selectedNotifier: selectedHealthCard,
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
                      return HealthCard(
                        index: 1,
                        selectedNotifier: selectedHealthCard,
                        title: "Fasting blood sugar",
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
                      return HealthCard(
                        index: 2,
                        selectedNotifier: selectedHealthCard,
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
                      return HealthCard(
                        index: 3,
                        selectedNotifier: selectedHealthCard,
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

class HealthCard extends StatefulWidget {
  final int index;
  final ValueNotifier<int?> selectedNotifier;

  final String title;
  final String value;
  final String unit;
  final String target;
  final String date;
  final IconData icon;

  const HealthCard({
    super.key,
    required this.index,
    required this.selectedNotifier,
    required this.title,
    required this.value,
    required this.unit,
    required this.target,
    required this.date,
    required this.icon,
  });

  @override
  State<HealthCard> createState() => _HealthCardState();
}

class _HealthCardState extends State<HealthCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder<int?>(
        valueListenable: widget.selectedNotifier,
        builder: (context, selectedIndex, _) {
          final bool isSelected = selectedIndex == widget.index;
          final bool active = isSelected || _isHovered;

          return MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),

            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),

              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                splashColor: AppColors.primaryGreen.withValues(alpha: 0.2),

                onTap: () {
                  // toggle but ensure only one at a time
                  widget.selectedNotifier.value =
                      isSelected ? null : widget.index;
                },

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,

                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: active ? AppColors.primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(15),

                    // ★ Glow border when selected
                    border: Border.all(
                      color: isSelected
                          ? AppColors.lightBackground
                          : Colors.transparent,
                      width: 2,
                    ),

                    // ★ Outer glow shadow
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.35),
                              blurRadius: 18,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            widget.icon,
                            size: 21,
                            color: active
                                ? Colors.white
                                : Colors.black45,
                          ),
                          const Spacer(),
                          Text(
                            widget.target,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: active
                                  ? Colors.white70
                                  : Colors.black45,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              active ? Colors.white : Colors.black45,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.value,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: active
                                  ? Colors.white
                                  : AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.unit,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: active
                                  ? Colors.white70
                                  : Colors.black45,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: active
                                ? Colors.white70
                                : Colors.blueGrey.shade400,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.date,
                            style: TextStyle(
                              fontSize: 14,
                              color: active
                                  ? Colors.white70
                                  : Colors.blueGrey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

