import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Widget hiasan untuk menampilkan hand1.png dengan efek animasi menguap
/// (melayang perlahan + bayangan/uap yang naik ke atas sambil memudar + shimmer).
/// Ukuran gambar disesuaikan secara proporsional di sekitar planet tengah.
class QuizEvaporatingHandDecorationWidget extends StatefulWidget {
  final String imageAsset;
  final double widthFactor;

  const QuizEvaporatingHandDecorationWidget({
    super.key,
    this.imageAsset = 'assets/images/hand1.png',
    this.widthFactor = 0.76,
  });

  @override
  State<QuizEvaporatingHandDecorationWidget> createState() =>
      _QuizEvaporatingHandDecorationWidgetState();
}

class _QuizEvaporatingHandDecorationWidgetState
    extends State<QuizEvaporatingHandDecorationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final handWidth =
              (constraints.maxWidth * widget.widthFactor).clamp(240.0, 340.0);
          final handHeight =
              (constraints.maxHeight * 0.78).clamp(420.0, 660.0);

          final imageChild = SizedBox(
            width: handWidth,
            height: handHeight,
            child: Image.asset(
              widget.imageAsset,
              fit: BoxFit.contain,
            ),
          );

          return Align(
            alignment: const Alignment(0.0, 0.08),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = _controller.value;
                final angle = t * 2 * math.pi;

                // Gerakan mengambang halus pada gambar utama
                final mainDy = math.sin(angle) * 5.0;
                final mainDx = math.cos(angle) * 2.5;

                // Siklus uap 1 (0.0 -> 1.0)
                final vapor1Progress = t;
                final vapor1Dy = -vapor1Progress * 28.0;
                final vapor1Scale = 1.0 + (vapor1Progress * 0.05);
                final vapor1Opacity =
                    math.sin(vapor1Progress * math.pi).clamp(0.0, 1.0) * 0.40;

                // Siklus uap 2 (selisih setengah fase dari uap 1 agar uap tidak pernah putus)
                final vapor2Progress = (t + 0.5) % 1.0;
                final vapor2Dy = -vapor2Progress * 28.0;
                final vapor2Scale = 1.0 + (vapor2Progress * 0.05);
                final vapor2Opacity =
                    math.sin(vapor2Progress * math.pi).clamp(0.0, 1.0) * 0.40;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Layer Uap 1 (Naik dan menghilang perlahan)
                    Transform.translate(
                      offset: Offset(
                        math.sin(vapor1Progress * 2 * math.pi) * 4.0,
                        vapor1Dy,
                      ),
                      child: Transform.scale(
                        scale: vapor1Scale,
                        child: Opacity(
                          opacity: vapor1Opacity,
                          child: child,
                        ),
                      ),
                    ),

                    // Layer Uap 2 (Naik bergantian dengan Uap 1)
                    Transform.translate(
                      offset: Offset(
                        -math.sin(vapor2Progress * 2 * math.pi) * 4.0,
                        vapor2Dy,
                      ),
                      child: Transform.scale(
                        scale: vapor2Scale,
                        child: Opacity(
                          opacity: vapor2Opacity,
                          child: child,
                        ),
                      ),
                    ),

                    // Gambar Utama hand1.png dengan efek gradasi menguap (ShaderMask)
                    Transform.translate(
                      offset: Offset(mainDx, mainDy),
                      child: ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (rect) {
                          final waveShift = math.sin(angle) * 0.08;
                          return LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.90),
                              Colors.white.withValues(alpha: 0.72),
                              Colors.white.withValues(alpha: 0.38),
                              Colors.white.withValues(alpha: 0.85),
                            ],
                            stops: [
                              0.0,
                              (0.35 + waveShift).clamp(0.1, 0.6),
                              (0.65 + waveShift).clamp(0.4, 0.85),
                              1.0,
                            ],
                          ).createShader(rect);
                        },
                        child: child,
                      ),
                    ),
                  ],
                );
              },
              child: imageChild,
            ),
          );
        },
      ),
    );
  }
}
