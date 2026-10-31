import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Background halaman QuizPerMapel:
/// - Satu warna solid yang sedikit lebih gelap dari warna planet1.png
/// - Efek kabut gelap bergelombang (wavy dark fog) yang bergerak halus di bagian atas dan bawah layar
class QuizPerMapelBackgroundWidget extends StatefulWidget {
  final Color baseColor;

  const QuizPerMapelBackgroundWidget({
    super.key,
    this.baseColor = const Color.fromARGB(255, 5, 58, 68),
  });

  @override
  State<QuizPerMapelBackgroundWidget> createState() =>
      _QuizPerMapelBackgroundWidgetState();
}

class _QuizPerMapelBackgroundWidgetState
    extends State<QuizPerMapelBackgroundWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fogController;

  @override
  void initState() {
    super.initState();
    _fogController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _fogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.baseColor,
      child: AnimatedBuilder(
        animation: _fogController,
        builder: (context, _) {
          final phase = _fogController.value * 2 * math.pi;
          return CustomPaint(
            size: Size.infinite,
            painter: _WavyDarkFogPainter(phase: phase),
          );
        },
      ),
    );
  }
}

class _WavyDarkFogPainter extends CustomPainter {
  final double phase;

  const _WavyDarkFogPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    _paintTopDarkFog(canvas, size);
    _paintBottomDarkFog(canvas, size);
  }

  void _paintTopDarkFog(Canvas canvas, Size size) {
    // Lapisan kabut gelap atas (2 layer gelombang agar tampak dalam)
    final baseBottomY1 = size.height * 0.40;
    const amp1 = 39.0;

    final path1 = Path()..moveTo(-40, -40);
    for (double x = -40; x <= size.width + 40; x += 4) {
      final normX = (x / size.width) * 2 * math.pi * 0.8;
      final y = baseBottomY1 +
          math.sin(normX + phase) * amp1 +
          math.cos(normX * 2 - phase * 1.3) * (amp1 * 0.4);
      path1.lineTo(x, y);
    }
    path1
      ..lineTo(size.width + 40, -40)
      ..close();

    final rect1 = Rect.fromLTWH(0, 0, size.width, baseBottomY1 + amp1 * 2);
    final paint1 = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF010B0E).withValues(alpha: 0.92),
          const Color(0xFF021318).withValues(alpha: 0.65),
          const Color(0xFF021318).withValues(alpha: 0.18),
          Colors.transparent,
        ],
        stops: const [0.2, 0.65, 0.8, 1.0],
      ).createShader(rect1);

    canvas.drawPath(path1, paint1);

    // Layer kedua kabut atas yang lebih pekat di ujung atas
    final baseBottomY2 = size.height * 0.21;
    const amp2 = 20.0;
    final path2 = Path()..moveTo(-40, -40);
    for (double x = -40; x <= size.width + 40; x += 4) {
      final normX = (x / size.width) * 2 * math.pi * 1.8;
      final y = baseBottomY2 +
          math.cos(normX - phase * 1.2) * amp2 +
          math.sin(normX * 2.2 + phase) * (amp2 * 0.35);
      path2.lineTo(x, y);
    }
    path2
      ..lineTo(size.width + 40, -40)
      ..close();

    final rect2 = Rect.fromLTWH(0, 0, size.width, baseBottomY2 + amp2 * 2);
    final paint2 = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withValues(alpha: 0.80),
          const Color(0xFF010D11).withValues(alpha: 0.45),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(rect2);

    canvas.drawPath(path2, paint2);
  }

  void _paintBottomDarkFog(Canvas canvas, Size size) {
    // Lapisan kabut gelap bawah pertama
    final baseTopY1 = size.height * 0.62;
    const amp1 = 37.0;

    final path1 = Path()..moveTo(-40, size.height + 40);
    for (double x = -40; x <= size.width + 40; x += 4) {
      final normX = (x / size.width) * 2 * math.pi * 0.8;
      final y = baseTopY1 +
          math.sin(normX - phase) * amp1 +
          math.cos(normX * 2 + phase * 1.4) * (amp1 * 0.4);
      path1.lineTo(x, y);
    }
    path1
      ..lineTo(size.width + 40, size.height + 40)
      ..close();

    final rect1 = Rect.fromLTWH(
      0,
      baseTopY1 - amp1 * 2,
      size.width,
      size.height - baseTopY1 + amp1 * 2,
    );
    final paint1 = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFF010B0E).withValues(alpha: 0.95),
          const Color(0xFF021318).withValues(alpha: 0.68),
          const Color(0xFF021318).withValues(alpha: 0.20),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 0.8, 1.0],
      ).createShader(rect1);

    canvas.drawPath(path1, paint1);

    // Lapisan kabut gelap bawah kedua
    final baseTopY2 = size.height * 0.85;
    const amp2 = 13.0;
    final path2 = Path()..moveTo(-40, size.height + 40);
    for (double x = -40; x <= size.width + 40; x += 4) {
      final normX = (x / size.width) * 2 * math.pi * 1.0;
      final y = baseTopY2 +
          math.cos(normX + phase * 1.3) * amp2 +
          math.sin(normX * 2.1 - phase) * (amp2 * 0.35);
      path2.lineTo(x, y);
    }
    path2
      ..lineTo(size.width + 40, size.height + 40)
      ..close();

    final rect2 = Rect.fromLTWH(
      0,
      baseTopY2 - amp2 * 2,
      size.width,
      size.height - baseTopY2 + amp2 * 2,
    );
    final paint2 = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.black.withValues(alpha: 0.85),
          const Color(0xFF010D11).withValues(alpha: 0.48),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(rect2);

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _WavyDarkFogPainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
