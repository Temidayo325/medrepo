import 'package:flutter/material.dart';
import '../../colors.dart';

class TimeFilterRow extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final Map<String, int> counts; // New: Holds counts like {'This Week': 5}

  const TimeFilterRow({
    Key? key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.counts,
  }) : super(key: key);

  final List<String> options = const ['This Week', 'This Month', 'This Year'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: options.map((option) {
        final isSelected = selectedFilter == option;
        return GestureDetector(
          onTap: () => onFilterSelected(option),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              option, 
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryGreen : AppColors.lightBackground,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}