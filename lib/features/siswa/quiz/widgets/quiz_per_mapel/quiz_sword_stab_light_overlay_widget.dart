import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Widget overlay efek meredup & menggelap dari titik tusukan pedang
/// yang langsung berubah menjadi layar loading gelap sebelum masuk ke QuizLevel.
class QuizSwordStabLightOverlayWidget extends StatelessWidget {
  final double progress; // 0.0 -> 1.0 dari AnimationController utama
  final Offset center;
  final String? loadingTitle;

  const QuizSwordStabLightOverlayWidget({
    super.key,
    required this.progress,
    required this.center,
    this.loadingTitle,
  });

  @override
  Widget build(BuildContext context) {
    // Efek meredup/gelap mulai muncul tepat setelah pedang menancap penuh (progress > 0.40)
    if (progress <= 0.40) {
      return const SizedBox.shrink();
    }

    // Normalisasi progress peredupan dari 0.40..0.72 menjadi 0.0..1.0 agar cepat gelap penuh,
    // lalu 0.72..1.0 menampilkan layar loading di atas layar gelap.
    final darkT = ((progress - 0.40) / 0.32).clamp(0.0, 1.0);
    final curvedDark = Curves.easeOutCubic.transform(darkT);
    final loadingOpacity = ((progress - 0.58) / 0.25).clamp(0.0, 1.0);

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxScreenDim = math.sqrt(
            constraints.maxWidth * constraints.maxWidth +
                constraints.maxHeight * constraints.maxHeight,
          );

          // Radius bayangan gelap yang meluas dari titik tusukan ke seluruh layar
          final currentRadius = 16.0 + (maxScreenDim * 1.45 * curvedDark);

          // Opacity peredupan layar menyeluruh hingga benar-benar gelap pekat
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
                          alpha: (0.75 + 0.25 * curvedDark).clamp(0.0, 1.0),
                        ),
                        const Color(0xFF020617).withValues(
                          alpha: (0.90 * curvedDark).clamp(0.0, 1.0),
                        ),
                        const Color(0xFF041E24).withValues(
                          alpha: (0.55 * curvedDark).clamp(0.0, 1.0),
                        ),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.42, 0.75, 1.0],
                    ),
                  ),
                ),
              ),

              // 2. Peredupan seluruh layar hingga gelap penuh
              ColoredBox(
                color: Color.lerp(
                  const Color(0xFF020617),
                  const Color(0xFF050A14),
                  curvedDark,
                )!.withValues(alpha: fullScreenDimOpacity),
              ),

              // 3. Layar Loading saat layar sudah gelap (tanpa slide)
              if (loadingOpacity > 0)
                Opacity(
                  opacity: loadingOpacity,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 46,
                          height: 46,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.2,
                            color: const Color(0xFF67E8F9),
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          loadingTitle != null && loadingTitle!.isNotEmpty
                              ? 'Memasuki ${loadingTitle!}...'
                              : 'Memuat Peta Petualangan...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Menyiapkan level kuis',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.62),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
