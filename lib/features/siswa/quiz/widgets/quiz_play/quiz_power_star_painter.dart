import 'package:flutter/material.dart';

/// Painter untuk ikon bintang kuning Power-Up 4-sisi.
class QuizPowerStarPainter extends CustomPainter {
  final bool isActive;

  const QuizPowerStarPainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.44;

    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + r * 0.2, c.dy - r * 0.2, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + r * 0.2, c.dy + r * 0.2, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - r * 0.2, c.dy + r * 0.2, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - r * 0.2, c.dy - r * 0.2, c.dx, c.dy - r)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = isActive
            ? const Color(0xFFF3E0A2)
            : const Color(0xFF64748B),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF0E1420)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  @override
  bool shouldRepaint(covariant QuizPowerStarPainter oldDelegate) {
    return oldDelegate.isActive != isActive;
  }
}
