import 'package:flutter/material.dart';
import '../../colors.dart';

class StatusSelector extends StatefulWidget {
  final Function(String) onStatusSelected;

  StatusSelector({required this.onStatusSelected});

  @override
  _StatusSelectorState createState() => _StatusSelectorState();
}

class _StatusSelectorState extends State<StatusSelector> {
  final List<String> statuses = ['All', 'Active', 'Completed'];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      color: Colors.white, // fully transparent background
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(statuses.length, (index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
                widget.onStatusSelected(statuses[index]);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  statuses[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSelected ? 20 : 20,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primaryGreen : AppColors.primaryGreen,
                    shadows: isSelected
                        ? [
                            Shadow(
                              color: Colors.white,
                              offset: Offset(0, 1),
                              blurRadius: 1,
                            )
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
