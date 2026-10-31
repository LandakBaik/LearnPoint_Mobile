import 'package:flutter/material.dart';

/// CustomPainter untuk menggambar variasi bentuk paku/kristal/corong seperti di sketsa
/// sebagai placeholder sebelum asset gambar menu tersedia.
class QuizShardPlaceholderPainter extends CustomPainter {
  final int variantIndex;
  final Color baseColor;

  QuizShardPlaceholderPainter({
    required this.variantIndex,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h / 2;

    final path = Path();

    if (variantIndex == 0) {
      // Variasi 1: Bentuk corong dengan topi melengkung di ujung luar (seperti sketsa)
      path.moveTo(0, cy - 3);
      path.lineTo(w * 0.82, h * 0.14);
      path.quadraticBezierTo(w * 0.88, h * 0.02, w * 0.94, h * 0.10);
      path.quadraticBezierTo(w, cy, w * 0.94, h * 0.90);
      path.quadraticBezierTo(w * 0.88, h * 0.98, w * 0.82, h * 0.86);
      path.lineTo(0, cy + 3);
      path.close();
    } else if (variantIndex == 1) {
      // Variasi 2: Bentuk jarum runcing di pangkal, melebar tegas di ujung
      path.moveTo(0, cy);
      path.lineTo(w * 0.85, h * 0.16);
      path.lineTo(w * 0.92, h * 0.08);
      path.quadraticBezierTo(w, cy, w * 0.92, h * 0.92);
      path.lineTo(w * 0.85, h * 0.84);
      path.close();
    } else {
      // Variasi 3: Bentuk kristal agak asimetris
      path.moveTo(0, cy - 2);
      path.lineTo(w * 0.80, h * 0.12);
      path.lineTo(w * 0.95, h * 0.20);
      path.quadraticBezierTo(w * 1.02, cy, w * 0.93, h * 0.82);
      path.lineTo(w * 0.80, h * 0.88);
      path.lineTo(0, cy + 2);
      path.close();
    }

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF0891B2),
          Color(0xFF0E7490),
          Color(0xFF155E75),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF22D3EE).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;

    canvas.drawShadow(
      path,
      const Color(0xFF22D3EE).withValues(alpha: 0.3),
      6,
      false,
    );
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant QuizShardPlaceholderPainter oldDelegate) {
    return oldDelegate.variantIndex != variantIndex ||
        oldDelegate.baseColor != baseColor;
  }
}
