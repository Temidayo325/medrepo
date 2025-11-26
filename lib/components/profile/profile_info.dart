import 'package:flutter/material.dart';
// import '../../colors.dart';

class ProfileInfoCard extends StatelessWidget {
  final String header;
  final Widget child;

  const ProfileInfoCard({
    required this.header,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // full width inside parent padding
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, // subtle contrast
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color.fromARGB(255, 3, 118, 30),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
