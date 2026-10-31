import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Widget animasi 2 garis melingkar bergelombang di belakang gambar planet.
/// - Lingkaran pertama: diameter sedikit lebih besar dari diameter utama bola planet
///   (sehingga aksesoris planet seperti pedang/tiang menonjol keluar melewatinya).
/// - Lingkaran kedua: diameter sedikit lebih besar dari lingkaran pertama.
class QuizPlanetWavyRingsWidget extends StatefulWidget {
  final double planetSize;

  const QuizPlanetWavyRingsWidget({
    super.key,
    required this.planetSize,
  });

  @override
  State<QuizPlanetWavyRingsWidget> createState() =>
      _QuizPlanetWavyRingsWidgetState();
}

class _QuizPlanetWavyRingsWidgetState extends State<QuizPlanetWavyRingsWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvasSize = widget.planetSize * 1.35;

    return SizedBox(
      width: canvasSize,
      height: canvasSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final phase = _controller.value * 2 * math.pi;
          return CustomPaint(
            painter: _WavyRingsPainter(
              planetSize: widget.planetSize,
              phase: phase,
            ),
          );
        },
      ),
    );
  }
}

class _WavyRingsPainter extends CustomPainter {
  final double planetSize;
  final double phase;

  const _WavyRingsPainter({
    required this.planetSize,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Pada gambar planet1.png, bola inti planet memiliki diameter sekitar 76% dari ukuran kanvas gambar
    // (sisanya adalah aksesoris pedang dan tiang yang menancap keluar).
    // Maka:
    // - Ring 1 dibuat sedikit lebih besar dari bola utama planet (sekitar 0.415 * planetSize),
    //   sehingga pedang/tiang planet menembus/bertabrakan dengan garis ini.
    // - Ring 2 dibuat sedikit lebih besar dari Ring 1 (sekitar 0.465 * planetSize).
    final innerBaseRadius = planetSize * 0.415;
    final outerBaseRadius = planetSize * 0.465;

    final innerPath = _buildWavyCirclePath(
      center: center,
      baseRadius: innerBaseRadius,
      waveCount: 8,
      amplitude: 3.8,
      phase: phase,
      secondaryWaveCount: 12,
      secondaryAmplitude: 1.8,
    );

    final outerPath = _buildWavyCirclePath(
      center: center,
      baseRadius: outerBaseRadius,
      waveCount: 10,
      amplitude: 4.5,
      phase: -phase * 0.85,
      secondaryWaveCount: 6,
      secondaryAmplitude: 2.2,
    );

    // Efek glow halus untuk kedua garis
    final glowPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final innerStrokePaint = Paint()
      ..color = const Color(0xFF67E8F9).withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final outerStrokePaint = Paint()
      ..color = const Color(0xFF22D3EE).withValues(alpha: 0.48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas.drawPath(innerPath, glowPaint);
    canvas.drawPath(outerPath, glowPaint);
    canvas.drawPath(innerPath, innerStrokePaint);
    canvas.drawPath(outerPath, outerStrokePaint);
  }

  Path _buildWavyCirclePath({
    required Offset center,
    required double baseRadius,
    required int waveCount,
    required double amplitude,
    required double phase,
    required int secondaryWaveCount,
    required double secondaryAmplitude,
  }) {
    final path = Path();
    const int steps = 180;

    for (int i = 0; i <= steps; i++) {
      final theta = (i / steps) * 2 * math.pi;
      final waveOffset = math.sin(theta * waveCount + phase) * amplitude +
          math.cos(theta * secondaryWaveCount - phase * 1.5) *
              secondaryAmplitude;
      final r = baseRadius + waveOffset;

      final x = center.dx + r * math.cos(theta);
      final y = center.dy + r * math.sin(theta);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _WavyRingsPainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.planetSize != planetSize;
  }
}
