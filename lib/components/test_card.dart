import 'package:flutter/material.dart';

class TestCard extends StatefulWidget {
  final String test;
  final String result;
  final String date;
  final IconData icon;
  final String unit;
  final bool highlight; // new
  final Color? glowColor; // optional custom glow color

  const TestCard({
    super.key,
    required this.test,
    required this.result,
    required this.unit,
    required this.date,
    required this.icon,
    this.highlight = false,
    this.glowColor,
  });

  @override
  State<TestCard> createState() => _TestCardState();
}

class _TestCardState extends State<TestCard> with SingleTickerProviderStateMixin {
  late bool _glow;

  @override
  void initState() {
    super.initState();
    _glow = widget.highlight;

    if (_glow) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _glow = false;
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant TestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger glow if highlight is now true
    if (widget.highlight && !oldWidget.highlight) {
      setState(() {
        _glow = true;
      });
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _glow = false);
      });
    }
  }

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
        boxShadow: _glow
            ? [
                BoxShadow(
                  color: widget.glowColor ?? Colors.blueAccent.withOpacity(0.7),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 0),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.blueGrey.shade200,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.test,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                  fontSize: 17)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(widget.icon, color: Colors.blueGrey.shade700, size: 30),
              const Spacer(),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: widget.result,
                        style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey)),
                    TextSpan(
                        text: widget.unit,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey.shade600,
                            letterSpacing: 1.4)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 18, color: Colors.blueGrey.shade500),
              const SizedBox(width: 8),
              Text(widget.date,
                  style:
                      TextStyle(fontSize: 15, color: Colors.blueGrey.shade600)),
            ],
          ),
        ],
      ),
    );
  }
}
