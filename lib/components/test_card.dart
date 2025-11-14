import 'package:flutter/material.dart';

class TestCard extends StatelessWidget {
  final String test;
  final String result;
  final String date;
  final IconData icon;
  final String unit;


  const TestCard({
    super.key,
    required this.test,
    required this.result,
    required this.unit,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey.shade50, Colors.blueGrey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(test, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 17),),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(icon, color: Colors.blueGrey.shade700, size: 30),
              Spacer(),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: result, style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.blueGrey),),
                    TextSpan(text: unit, style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade600, letterSpacing: 1.4),),
                  ],
                ),
              )

            ],),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 18, color: Colors.blueGrey.shade500),
              SizedBox(width: 8),
              Text(date, style: TextStyle(fontSize: 15, color: Colors.blueGrey.shade600,),),
            ],
          ),
        ],
      ),
      );
  }
}
