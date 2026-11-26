import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/features/siswa/quiz/config/quiz_assets.dart';

/// Latar belakang kosmik luar angkasa dengan bintang & nebula halus
/// yang senada dengan halaman Quiz & Gacha.
class InventorySpaceBackdropWidget extends StatefulWidget {
  const InventorySpaceBackdropWidget({super.key});

  @override
  State<InventorySpaceBackdropWidget> createState() =>
      _InventorySpaceBackdropWidgetState();
}

class _InventorySpaceBackdropWidgetState
    extends State<InventorySpaceBackdropWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _twinkleController;

  @override
  void initState() {
    super.initState();
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF06091E),
                Color(0xFF0E153A),
                Color(0xFF17143D),
                Color(0xFF070B1E),
              ],
              stops: [0.0, 0.35, 0.7, 1.0],
            ),
          ),
        ),
        Opacity(
          opacity: 0.35,
          child: Image.asset(
            QuizAssets.gachaStars,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
        AnimatedBuilder(
          animation: _twinkleController,
          builder: (context, _) {
            return CustomPaint(
              painter: _CosmicStarsPainter(phase: _twinkleController.value),
            );
          },
        ),
      ],
    );
  }
}

class _CosmicStarsPainter extends CustomPainter {
  final double phase;

  const _CosmicStarsPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final cyanCenter = Offset(size.width * 0.15, size.height * 0.12);
    canvas.drawCircle(
      cyanCenter,
      size.width * 0.55,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF38BDF8).withValues(alpha: 0.14),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: cyanCenter, radius: size.width * 0.55)),
    );

    final purpleCenter = Offset(size.width * 0.88, size.height * 0.25);
    canvas.drawCircle(
      purpleCenter,
      size.width * 0.5,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFA855F7).withValues(alpha: 0.14),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: purpleCenter, radius: size.width * 0.5)),
    );

    const stars = <(double, double, double)>[
      (0.08, 0.07, 1.6),
      (0.22, 0.15, 1.3),
      (0.38, 0.06, 2.0),
      (0.55, 0.12, 1.4),
      (0.74, 0.08, 1.8),
      (0.91, 0.14, 1.5),
      (0.14, 0.29, 1.7),
      (0.64, 0.26, 1.5),
      (0.83, 0.33, 2.1),
      (0.28, 0.37, 1.2),
    ];

    for (int i = 0; i < stars.length; i++) {
      final s = stars[i];
      final wave = 0.45 + 0.55 * math.sin((phase * math.pi) + i * 1.1).abs();
      canvas.drawCircle(
        Offset(size.width * s.$1, size.height * s.$2),
        s.$3,
        Paint()..color = Colors.white.withValues(alpha: (0.65 * wave).clamp(0.15, 0.9)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CosmicStarsPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
