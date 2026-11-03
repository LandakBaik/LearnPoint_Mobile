import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Widget overlay efek meredup & menggelap perlahan dari titik tusukan pedang
/// hingga seluruh layar menjadi gelap sebelum berpindah ke halaman QuizLevel.
class QuizSwordStabLightOverlayWidget extends StatelessWidget {
  final double progress; // 0.0 -> 1.0 dari AnimationController utama
  final Offset center;

  const QuizSwordStabLightOverlayWidget({
    super.key,
    required this.progress,
    required this.center,
  });

  @override
  Widget build(BuildContext context) {
    // Efek meredup/gelap mulai muncul tepat setelah pedang menancap penuh (progress > 0.42)
    if (progress <= 0.42) {
      return const SizedBox.shrink();
    }

    // Normalisasi progress peredupan dari 0.42..1.0 menjadi 0.0..1.0
    final darkT = ((progress - 0.42) / 0.58).clamp(0.0, 1.0);
    final curvedDark = Curves.easeInOutCubic.transform(darkT);

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxScreenDim = math.sqrt(
            constraints.maxWidth * constraints.maxWidth +
                constraints.maxHeight * constraints.maxHeight,
          );

          // Radius bayangan gelap yang meluas dari titik tusukan ke seluruh layar
          final currentRadius = 16.0 + (maxScreenDim * 1.45 * curvedDark);

          // Opacity peredupan layar menyeluruh hingga benar-benar gelap pekat di akhir transisi
          final fullScreenDimOpacity = Curves.easeInQuad.transform(darkT);

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Lingkaran bayangan gelap yang merambat keluar dari titik tusukan di planet
              Positioned(
                left: center.dx - currentRadius,
                top: center.dy - currentRadius,
                width: currentRadius * 2,
                height: currentRadius * 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.black.withValues(
                          alpha: (0.65 + 0.35 * curvedDark).clamp(0.0, 1.0),
                        ),
                        const Color(0xFF020617).withValues(
                          alpha: (0.85 * curvedDark).clamp(0.0, 1.0),
                        ),
                        const Color(0xFF041E24).withValues(
                          alpha: (0.50 * curvedDark).clamp(0.0, 1.0),
                        ),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.42, 0.75, 1.0],
                    ),
                  ),
                ),
              ),

              // 2. Peredupan seluruh layar secara bertahap hingga gelap penuh
              ColoredBox(
                color: Color.lerp(
                  const Color(0xFF020617),
                  Colors.black,
                  curvedDark,
                )!.withValues(alpha: fullScreenDimOpacity),
              ),
            ],
          );
        },
      ),
    );
  }
}
