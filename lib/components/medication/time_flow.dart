import 'package:flutter/material.dart';

class TimeFilterRow extends StatefulWidget {
  @override
  _TimeFilterRowState createState() => _TimeFilterRowState();
}

class _TimeFilterRowState extends State<TimeFilterRow> {
  int selectedIndex = 0; // Tracks the currently selected button

  final List<String> options = ['This Week', 'This Month', 'This Year'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(options.length, (index) {
        final isSelected = selectedIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ]
                  : [],
            ),
            child: Text(
              options[index],
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blueGrey : Colors.white,
                letterSpacing: 1.1,
              ),
            ),
          ),
        );
      }),
    );
  }
}
