import 'package:flutter/material.dart';

class WeekSelector extends StatefulWidget {
  @override
  _WeekSelectorState createState() => _WeekSelectorState();
}

class _WeekSelectorState extends State<WeekSelector> {
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  int selectedIndex = 0; // tracks the currently selected day

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 30),
      color: Colors.blueGrey.shade100, // enough height for the text
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(days.length, (index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                child: Text(
                  days[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSelected ? 20 : 18,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: Colors.blueGrey.shade900,
                    shadows: isSelected
                        ? [
                            Shadow(
                              color: Colors.grey.shade400,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ]
                        : [],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
