import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final String? header; // optional header text
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const ProfileInfoCard({
    super.key,
    this.header,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin = const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    this.backgroundColor = Colors.white,
    this.borderColor = const Color.fromARGB(255, 177, 201, 213),
    this.borderWidth = 1,
    this.borderRadius = 16,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: Colors.grey.shade400.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                )
              ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (header != null) ...[
              Center(
                child: Text(
                  header!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 12), // spacing between header and content
            ],
            child, // actual content passed from parent
          ],
        ),
      ),
    );
  }
}
