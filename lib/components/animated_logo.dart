import 'package:flutter/material.dart';
import 'dart:ui'; // For PathMetrics

/// An animated logo widget that draws a custom medical logo (three lines and a cross)
/// with a fading background on initialization.
class AnimatedLogo extends StatefulWidget {
  final double size;
  // Note: AppColors is not passed here, using hardcoded deep green for isolation.
  const AnimatedLogo({Key? key, required this.size}) : super(key: key);

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Animation for the background fading/scaling in
  late Animation<double> _bgAnimation;

  @override
  void initState() {
    super.initState();
    // 2.5 seconds total duration for a relaxed "writing" feel
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Background animation runs for the first 30% of the duration
    _bgAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );

    // Start animation on load
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _LogoPainter(
            progress: _controller.value,
            bgOpacity: _bgAnimation.value,
            // Hardcoded the colors used in the original login screen for consistency
            color: const Color(0xFF2E7D32), // Deep Green (Logo background color)
            lineColor: Colors.white,
          ),
        );
      },
    );
  }
}

/// CustomPainter to handle the drawing and animation of the logo lines.
class _LogoPainter extends CustomPainter {
  final double progress;
  final double bgOpacity;
  final Color color;
  final Color lineColor;

  _LogoPainter({
    required this.progress,
    required this.bgOpacity,
    required this.color,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Background (Rounded Rectangle)
    // It scales/fades in first
    if (bgOpacity > 0) {
      final bgPaint = Paint()
        ..color = color.withOpacity(bgOpacity)
        ..style = PaintingStyle.fill;

      // Draw rounded rect centered
      final RRect bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(10), // Rounded corners
      );
      
      // Scale effect for entry
      canvas.save();
      final double scale = 0.8 + (0.2 * bgOpacity);
      canvas.translate(size.width / 2, size.height / 2);
      canvas.scale(scale);
      canvas.translate(-size.width / 2, -size.height / 2);
      
      canvas.drawRRect(bgRect, bgPaint);
      canvas.restore();
    }

    // Define line paint properties
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06 // Relative thickness
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 2. Draw Lines & Cross
    // Helper to draw partial paths based on time interval
    void drawAnimatedPath(Path fullPath, double startInterval, double endInterval) {
      if (progress < startInterval) return;

      final double localProgress = (progress - startInterval) / (endInterval - startInterval);
      final double clampedProgress = localProgress.clamp(0.0, 1.0);

      if (clampedProgress <= 0) return;

      // Extract the sub-path
      final PathMetrics pathMetrics = fullPath.computeMetrics();
      for (PathMetric metric in pathMetrics) {
        final Path extract = metric.extractPath(0.0, metric.length * clampedProgress);
        canvas.drawPath(extract, linePaint);
      }
    }

    // --- Line Paths Construction ---
    final double w = size.width;
    final double h = size.height;

    // Line 1 (Top)
    Path line1 = Path()
      ..moveTo(w * 0.25, h * 0.35)
      ..lineTo(w * 0.75, h * 0.35);

    // Line 2 (Middle)
    Path line2 = Path()
      ..moveTo(w * 0.25, h * 0.48)
      ..lineTo(w * 0.75, h * 0.48);

    // Line 3 (Bottom)
    Path line3 = Path()
      ..moveTo(w * 0.25, h * 0.61)
      ..lineTo(w * 0.75, h * 0.61);

    // Cross (Vertical then Horizontal)
    Path crossVertical = Path()
      ..moveTo(w * 0.5, h * 0.68)
      ..lineTo(w * 0.5, h * 0.88);

    Path crossHorizontal = Path()
      ..moveTo(w * 0.38, h * 0.78)
      ..lineTo(w * 0.62, h * 0.78);

    // --- Execution (Staggered Timings) ---
    drawAnimatedPath(line1, 0.3, 0.45);
    drawAnimatedPath(line2, 0.45, 0.60);
    drawAnimatedPath(line3, 0.60, 0.75);
    
    // Draw cross: Vertical bar first, then horizontal
    drawAnimatedPath(crossVertical, 0.75, 0.85);
    drawAnimatedPath(crossHorizontal, 0.85, 0.95);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.bgOpacity != bgOpacity;
  }
}