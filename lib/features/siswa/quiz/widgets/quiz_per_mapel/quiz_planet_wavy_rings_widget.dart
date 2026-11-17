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

    final innerBaseRadius = planetSize * 0.465;
    final outerBaseRadius = planetSize * 0.515;
    final thirdBaseRadius = planetSize * 0.565;

    final innerPath = _buildSpacedWavyCirclePath(
      center: center,
      baseRadius: innerBaseRadius,
      waveCount: 3,
      amplitude: 20.5,
      phase: phase,
      waveDutyCycle: 0.42,
    );

    final outerPath = _buildSpacedWavyCirclePath(
      center: center,
      baseRadius: outerBaseRadius,
      waveCount: 3,
      amplitude: 20.5,
      phase: phase,
      waveDutyCycle: 0.42,
    );

    final thirdPath = _buildSpacedWavyCirclePath(
      center: center,
      baseRadius: thirdBaseRadius,
      waveCount: 3,
      amplitude: 20.5,
      phase: phase,
      waveDutyCycle: 0.42,
    );

    // Efek glow halus untuk ketiga garis
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

    final thirdStrokePaint = Paint()
      ..color = const Color(0xFF06B6D4).withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawPath(innerPath, glowPaint);
    canvas.drawPath(outerPath, glowPaint);
    canvas.drawPath(thirdPath, glowPaint);
    canvas.drawPath(innerPath, innerStrokePaint);
    canvas.drawPath(outerPath, outerStrokePaint);
    canvas.drawPath(thirdPath, thirdStrokePaint);
  }

  /// Membuat jalur lingkaran yang tetap bulat sempurna, namun memiliki beberapa
  /// riak gelombang (`waveCount`) yang dipisahkan oleh jarak busur lingkaran rata (`waveDutyCycle`),
  /// serta tiap bukit gelombangnya bergerak naik-turun secara dinamis.
  Path _buildSpacedWavyCirclePath({
    required Offset center,
    required double baseRadius,
    required int waveCount,
    required double amplitude,
    required double phase,
    double waveDutyCycle = 0.45,
  }) {
    final path = Path();
    const int steps = 220;

    for (int i = 0; i <= steps; i++) {
      final theta = (i / steps) * 2 * math.pi;

      // Posisi lokal di dalam 1 segmen gelombang (0.0 sampai 1.0)
      final rawCycle = ((theta * waveCount) + phase) / (2 * math.pi);
      final waveIndex = rawCycle.floor();
      final localPos = rawCycle - waveIndex;

      double waveOffset = 0.0;
      // Jika berada di dalam porsi aktif (waveDutyCycle), gambar 1 bukit gelombang halus (Hann window)
      // Sisanya (1.0 - waveDutyCycle) bernilai 0.0 (busur lingkaran murni sebagai jarak antar gelombang)
      if (localPos < waveDutyCycle) {
        final t = localPos / waveDutyCycle; // 0.0 -> 1.0
        // Kurva dasar bukit mulus dari 0 -> 1 -> 0
        final smoothCrest = 0.5 * (1.0 - math.cos(2 * math.pi * t));

        // Efek gerakan naik-turun pada tinggi tiap bukit gelombang seiring waktu (phase)
        final upDownPulse =
            0.65 + 0.35 * math.sin(phase * 3.0 + (waveIndex * 1.8));

        waveOffset = smoothCrest * amplitude * upDownPulse;
      }

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
