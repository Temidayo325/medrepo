import 'package:flutter/material.dart';
const Color _deepGreen = Color(0xFF2E7D32); // Placeholder for AppColors.deepGreen
const Color _primaryGreen = Color(0xFFC8E6C9); // Placeholder for AppColors.primaryGreen

class BlobBackground extends StatelessWidget {
  const BlobBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Returning a Stack that fills its parent.
    return Stack(
      fit: StackFit.expand,
      children: [
        // Top Right Blob
        Positioned(
          top: -100,
          right: -100,
          child: Opacity(
            opacity: 0.3,
            child: CustomPaint(
              size: const Size(300, 300), 
              painter: _BlobPainter(color: _deepGreen),
            ),
          ),
        ),
        
        // Bottom Left Blob
        Positioned(
          bottom: -120, 
          left: -120,
          child: Opacity(
            opacity: 0.3,
            child: CustomPaint(
              size: const Size(300, 300), 
              painter: _BlobPainter(color: _primaryGreen),
            ),
          ),
        ),
      ],
    );
  }
}

/// CustomPainter to draw a single organic blob shape.
class _BlobPainter extends CustomPainter {
  final Color color;

  _BlobPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Create an organic blob shape
    path.moveTo(size.width * 0.5, size.height * 0.1);
    
    // Top curve
    path.cubicTo(
      size.width * 0.8, size.height * 0.1,
      size.width * 0.9, size.height * 0.3,
      size.width * 0.85, size.height * 0.5,
    );
    
    // Right curve
    path.cubicTo(
      size.width * 0.8, size.height * 0.7,
      size.width * 0.7, size.height * 0.85,
      size.width * 0.5, size.height * 0.9,
    );
    
    // Bottom curve
    path.cubicTo(
      size.width * 0.3, size.height * 0.95,
      size.width * 0.15, size.height * 0.8,
      size.width * 0.1, size.height * 0.6,
    );
    
    // Left curve
    path.cubicTo(
      size.width * 0.05, size.height * 0.4,
      size.width * 0.2, size.height * 0.15,
      size.width * 0.5, size.height * 0.1,
    );
    
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}