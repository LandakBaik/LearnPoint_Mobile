import 'package:flutter/material.dart';

/// Painter untuk bintang-bintang & tanda plus (+) pada latar langit malam.
class QuizSpaceBackgroundPainter extends CustomPainter {
  const QuizSpaceBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.78)
      ..style = PaintingStyle.fill;

    final crossPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.85)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Titik-titik bintang kecil
    final dots = <Offset>[
      Offset(size.width * 0.24, size.height * 0.08),
      Offset(size.width * 0.42, size.height * 0.11),
      Offset(size.width * 0.07, size.height * 0.14),
      Offset(size.width * 0.05, size.height * 0.38),
      Offset(size.width * 0.68, size.height * 0.41),
      Offset(size.width * 0.90, size.height * 0.16),
      Offset(size.width * 0.85, size.height * 0.49),
    ];

    for (final p in dots) {
      canvas.drawCircle(p, 1.8, dotPaint);
    }

    // Bintang berbentuk tanda plus (+)
    _drawCross(
      canvas,
      Offset(size.width * 0.27, size.height * 0.13),
      10,
      crossPaint,
    );
    _drawCross(
      canvas,
      Offset(size.width * 0.10, size.height * 0.25),
      9,
      crossPaint,
    );
    _drawCross(
      canvas,
      Offset(size.width * 0.84, size.height * 0.09),
      7,
      crossPaint,
    );
    _drawCross(
      canvas,
      Offset(size.width * 0.93, size.height * 0.37),
      9,
      crossPaint,
    );
  }

  void _drawCross(Canvas canvas, Offset c, double r, Paint paint) {
    canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), paint);
    canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
