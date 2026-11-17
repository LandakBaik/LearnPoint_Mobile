import 'dart:math' as math;
import 'package:flutter/material.dart';

class WavyUpwardLightPainter extends CustomPainter {
  final double phase;

  const WavyUpwardLightPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    // Tinggi dasar pancaran cahaya dari bawah ke atas
    final baseGlowTop = size.height * 0.65;
    const waveAmplitude = 40.0;

    final path = Path()..moveTo(-40, size.height + 44);

    // Garis atas persegi yang bergelombang mengalir dari kiri ke kanan
    for (double x = -40; x <= size.width + 40; x += 2) {
      final normalizedX = (x / size.width) * 2 * math.pi * 1.5;
      final y = baseGlowTop +
          math.sin(normalizedX - phase) * waveAmplitude +
          math.cos(normalizedX * 2 - phase * 1.5) * (waveAmplitude * 0.35);
      path.lineTo(x, y);
    }

    path
      ..lineTo(size.width + 40, size.height + 40)
      ..close();

    // Gradasi persegi bersinar dari bawah ke atas + MaskFilter blur agar ujung gelombang sangat halus
    final rect = Rect.fromLTWH(
      0,
      baseGlowTop - 40,
      size.width,
      size.height - baseGlowTop + 40,
    );
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.cyanAccent.withValues(alpha: 0.64),
          Colors.blue.withValues(alpha: 0.25),
          Colors.blue.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.4, 0.7, 0.9, 1.0],
      ).createShader(rect);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavyUpwardLightPainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
