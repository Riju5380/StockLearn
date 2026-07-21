import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final bool showText;
  final double fontSize;

  const LogoWidget({
    super.key,
    this.size = 80.0,
    this.showText = true,
    this.fontSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF10B981)], // Deep Navy to Emerald Green
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: CustomPaint(
              size: Size(size * 0.55, size * 0.55),
              painter: LogoPainter(),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF0F172A),
                letterSpacing: 0.5,
              ),
              children: const [
                TextSpan(text: 'Stock'),
                TextSpan(
                  text: 'Learn',
                  style: TextStyle(
                    color: Color(0xFF10B981), // Emerald Green
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw stylized bars rising
    final double w = size.width;
    final double h = size.height;

    // Bar 1 (Shortest)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, h * 0.6, w * 0.2, h * 0.4),
        Radius.circular(w * 0.06),
      ),
      fillPaint,
    );

    // Bar 2 (Medium)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.3, h * 0.35, w * 0.2, h * 0.65),
        Radius.circular(w * 0.06),
      ),
      fillPaint,
    );

    // Bar 3 (Tallest with arrow path)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.6, h * 0.1, w * 0.2, h * 0.9),
        Radius.circular(w * 0.06),
      ),
      fillPaint,
    );

    // Dynamic trend line showing exponential growth
    final path = Path()
      ..moveTo(w * 0.05, h * 0.55)
      ..quadraticBezierTo(w * 0.45, h * 0.4, w * 0.85, h * 0.05);

    canvas.drawPath(path, paint);

    // Draw small upward arrow cap at the end of the trend line
    final arrowPath = Path()
      ..moveTo(w * 0.65, h * 0.05)
      ..lineTo(w * 0.88, h * 0.02)
      ..lineTo(w * 0.85, h * 0.25);
    
    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
