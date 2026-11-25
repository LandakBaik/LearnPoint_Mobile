import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Painter ilustrasi Pulau Melayang, Kastil, Pohon, dan Bulan Purnama.
class QuizFloatingIslandScenePainter extends CustomPainter {
  const QuizFloatingIslandScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.45;
    final cy = size.height * 0.58;

    // 1. Bulan di sebelah kanan dengan cincin orbit tipis
    final moonCenter = Offset(size.width * 0.83, size.height * 0.48);
    const moonRadius = 33.0;

    final orbitPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(moonCenter, moonRadius + 10, orbitPaint);
    canvas.drawCircle(moonCenter, moonRadius + 18, orbitPaint);

    // Badan Bulan
    canvas.drawCircle(
      moonCenter,
      moonRadius,
      Paint()..color = const Color(0xFFF1DE9E),
    );
    // Bayangan lembut sisi kanan bawah bulan
    canvas.drawCircle(
      moonCenter + const Offset(4, 4),
      moonRadius - 4,
      Paint()..color = const Color(0xFFE4CC83).withValues(alpha: 0.45),
    );
    // Kawah-kawah bulan
    canvas.drawCircle(
      moonCenter + const Offset(-10, -8),
      4.5,
      Paint()..color = const Color(0xFFD5BC74),
    );
    canvas.drawCircle(
      moonCenter + const Offset(10, -14),
      3.0,
      Paint()..color = const Color(0xFFD5BC74),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: moonCenter + const Offset(6, 16),
        width: 11,
        height: 6,
      ),
      Paint()..color = const Color(0xFF3E3A35),
    );
    // Kilau lengkung kiri atas bulan
    canvas.drawArc(
      Rect.fromCircle(center: moonCenter, radius: moonRadius - 5),
      math.pi * 1.05,
      math.pi * 0.35,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // 2. Pulau Terbang (Tanah Cokelat + Rumput Hijau)
    final islandRect = Rect.fromCenter(
      center: Offset(cx, cy + 10),
      width: 162,
      height: 74,
    );

    // Bagian bawah tanah (mangkuk/kerucut melengkung)
    final rockPath = Path()
      ..moveTo(islandRect.left + 6, cy + 4)
      ..quadraticBezierTo(cx, cy + 72, islandRect.right - 6, cy + 4)
      ..close();
    canvas.drawPath(
      rockPath,
      Paint()..color = const Color(0xFF6B4D3C),
    );

    // Bayangan gelap di dasar bawah tanah
    final rockShadowPath = Path()
      ..moveTo(islandRect.left + 16, cy + 16)
      ..quadraticBezierTo(cx + 8, cy + 68, islandRect.right - 16, cy + 12)
      ..quadraticBezierTo(cx, cy + 52, islandRect.left + 16, cy + 16)
      ..close();
    canvas.drawPath(
      rockShadowPath,
      Paint()..color = const Color(0xFF4D3529),
    );

    // Lapisan rumput hijau bagian atas pulau
    final grassRect = Rect.fromCenter(
      center: Offset(cx, cy + 3),
      width: 162,
      height: 36,
    );
    canvas.drawOval(
      grassRect.shift(const Offset(0, 3)),
      Paint()..color = const Color(0xFF6A9459),
    );
    canvas.drawOval(
      grassRect,
      Paint()..color = const Color(0xFF8DBA78),
    );

    // 3. Pohon Bulat di Kiri Kastil
    final treeTrunkRect = Rect.fromLTWH(cx - 56, cy - 16, 6, 15);
    canvas.drawRect(
      treeTrunkRect,
      Paint()..color = const Color(0xFF5A3E30),
    );
    canvas.drawCircle(
      Offset(cx - 53, cy - 23),
      13,
      Paint()..color = const Color(0xFF75A362),
    );
    canvas.drawCircle(
      Offset(cx - 56, cy - 26),
      8,
      Paint()..color = const Color(0xFF8DBA78),
    );

    // 4. Kastil / Bangunan Sekolah
    final wallPaint = Paint()..color = const Color(0xFFEFE5CF);
    final wallShadowPaint = Paint()..color = const Color(0xFFDDD0B4);
    final roofPaint = Paint()..color = const Color(0xFFBF6952);

    // Menara Kiri
    canvas.drawRect(Rect.fromLTWH(cx - 32, cy - 34, 18, 34), wallShadowPaint);
    _drawTriangleRoof(
      canvas,
      Offset(cx - 34, cy - 34),
      Offset(cx - 12, cy - 34),
      Offset(cx - 23, cy - 50),
      roofPaint,
    );

    // Menara Kanan
    canvas.drawRect(Rect.fromLTWH(cx + 22, cy - 34, 18, 34), wallShadowPaint);
    _drawTriangleRoof(
      canvas,
      Offset(cx + 20, cy - 34),
      Offset(cx + 42, cy - 34),
      Offset(cx + 31, cy - 50),
      roofPaint,
    );

    // Bangunan Utama Tengah
    canvas.drawRect(Rect.fromLTWH(cx - 16, cy - 48, 40, 48), wallPaint);
    _drawTriangleRoof(
      canvas,
      Offset(cx - 20, cy - 48),
      Offset(cx + 28, cy - 48),
      Offset(cx + 4, cy - 70),
      roofPaint,
    );

    // Bendera Kuning di Puncak Atap
    canvas.drawLine(
      Offset(cx + 4, cy - 70),
      Offset(cx + 4, cy - 84),
      Paint()
        ..color = const Color(0xFFEFE5CF)
        ..strokeWidth = 1.8,
    );
    final flagPath = Path()
      ..moveTo(cx + 4, cy - 84)
      ..lineTo(cx + 16, cy - 79)
      ..lineTo(cx + 4, cy - 74)
      ..close();
    canvas.drawPath(flagPath, Paint()..color = const Color(0xFFF3CA58));

    // Pintu Lengkung Gelap
    final doorRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(cx - 2, cy - 20, 12, 20),
      topLeft: const Radius.circular(6),
      topRight: const Radius.circular(6),
    );
    canvas.drawRRect(doorRect, Paint()..color = const Color(0xFF1B2438));

    // Jendela kecil
    canvas.drawCircle(
      Offset(cx + 4, cy - 33),
      3.5,
      Paint()..color = const Color(0xFF1B2438),
    );
    canvas.drawCircle(
      Offset(cx - 23, cy - 20),
      2.5,
      Paint()..color = const Color(0xFF1B2438),
    );
    canvas.drawCircle(
      Offset(cx + 31, cy - 20),
      2.5,
      Paint()..color = const Color(0xFF1B2438),
    );
  }

  void _drawTriangleRoof(
    Canvas canvas,
    Offset left,
    Offset right,
    Offset top,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(left.dx, left.dy)
      ..lineTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
