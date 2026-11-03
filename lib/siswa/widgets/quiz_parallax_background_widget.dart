import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class QuizParallaxBackgroundWidget extends StatefulWidget {
  final double topBgHeight;
  final ValueListenable<double> scrollOffset;

  const QuizParallaxBackgroundWidget({
    super.key,
    required this.topBgHeight,
    required this.scrollOffset,
  });

  @override
  State<QuizParallaxBackgroundWidget> createState() =>
      _QuizParallaxBackgroundWidgetState();
}

class _QuizParallaxBackgroundWidgetState
    extends State<QuizParallaxBackgroundWidget>
    with TickerProviderStateMixin {
  late final AnimationController _moveRightController;
  late final AnimationController _twinkleWaveController;
  late final AnimationController _fallenLightWaveController;
  late final Animation<double> _twinkleSweepAnimation;

  @override
  void initState() {
    super.initState();

    // Controller untuk menggeser stars2 pelan ke kanan lalu loop kembali dari kiri
    _moveRightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 80),
    )..repeat();

    // Controller untuk gelombang kedipan bintang berurutan dari KIRI ke KANAN
    _twinkleWaveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _twinkleSweepAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(_twinkleWaveController);

    // Controller untuk efek bergelombang pada cahaya fallenstar (fallenstar_light)
    _fallenLightWaveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _moveRightController.dispose();
    _twinkleWaveController.dispose();
    _fallenLightWaveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: widget.topBgHeight,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background Utama (Langit malam + tanah)
            Image.asset(
              'assets/images/vg_main.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),

            // 2. Layer Spiral Angin (Efek gelombang opacity mengalir seperti kedip bintang)
            AnimatedBuilder(
              animation: _twinkleSweepAnimation,
              builder: (context, spiralChild) {
                return ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment(_twinkleSweepAnimation.value - 1.0, -0.2),
                      end: Alignment(_twinkleSweepAnimation.value + 1.0, 0.2),
                      tileMode: TileMode.repeated,
                      colors: [
                        Colors.white.withValues(alpha: 0.28),
                        Colors.white,
                        Colors.white.withValues(alpha: 0.40),
                        Colors.white,
                        Colors.white.withValues(alpha: 0.28),
                      ],
                      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                    ).createShader(rect);
                  },
                  child: spiralChild,
                );
              },
              child: Image.asset(
                'assets/images/vg_spiral.png',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),

            // 3. Layer 3 Bintang Kuning Besar
            Image.asset(
              'assets/images/vg_big_stars.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),

            // 4. Layer stars2 (Bintang kecil geser pelan ke kanan & kedip berurutan dari kiri ke kanan)
            AnimatedBuilder(
              animation: Listenable.merge([
                _moveRightController,
                _twinkleSweepAnimation,
              ]),
              builder: (context, starChild) {
                final dx = _moveRightController.value * screenWidth;

                return ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) {
                    // Gelombang opacity bergerak dari kiri ke kanan secara berurutan
                    return LinearGradient(
                      begin: Alignment(_twinkleSweepAnimation.value - 1.0, 0),
                      end: Alignment(_twinkleSweepAnimation.value + 1.0, 0),
                      tileMode: TileMode.repeated,
                      colors: [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white,
                        Colors.white.withValues(alpha: 0.25),
                        Colors.white,
                        Colors.white.withValues(alpha: 0.15),
                      ],
                      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                    ).createShader(rect);
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gambar utama bergeser dari 0 ke kanan (screenWidth)
                      Transform.translate(
                        offset: Offset(dx, 0),
                        child: starChild,
                      ),
                      // Gambar kedua menyambung masuk dari sebelah kiri (-screenWidth menuju 0)
                      Transform.translate(
                        offset: Offset(dx - screenWidth, 0),
                        child: starChild,
                      ),
                    ],
                  ),
                );
              },
              child: Image.asset(
                'assets/images/stars2.png',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),

            // 5. Layer Fog / Kabut Bawah (Di bawah fallenstar)
            Image.asset(
              'assets/images/vg_mist.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),

            // 6. Layer Cahaya Fallenstar (fallenstar_light) dibuat bergelombang
            _buildWavyFallenStarLight(screenWidth),

            // 7. Layer Fallenstar (Bintang jatuh di tanah, berada di ATAS fog)
            Image.asset(
              'assets/images/vg_ground_stars.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),

            // 8. Layer Character (Paling atas layer)
            Image.asset(
              'assets/images/vg_character.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ],
        ),
      ),
    );
  }

  /// Membuat efek gambar `fallenstar_light.png` bergelombang secara halus (wavy ripple)
  /// sekaligus berkilau mengalir sepanjang bintang-bintang di tanah.
  Widget _buildWavyFallenStarLight(double screenWidth) {
    const int sliceCount = 10;
    final double bgHeight = widget.topBgHeight;

    return AnimatedBuilder(
      animation: _fallenLightWaveController,
      builder: (context, lightImageChild) {
        final phase = _fallenLightWaveController.value * 2 * math.pi;

        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) {
            final waveShift = math.sin(phase) * 0.6;
            return LinearGradient(
              begin: Alignment(-1.2 + waveShift, 0),
              end: Alignment(1.2 + waveShift, 0),
              tileMode: TileMode.mirror,
              colors: [
                Colors.white.withValues(alpha: 0.45),
                Colors.white,
                Colors.white.withValues(alpha: 0.55),
                Colors.white,
              ],
              stops: const [0.0, 0.35, 0.7, 1.0],
            ).createShader(rect);
          },
          child: Stack(
            fit: StackFit.expand,
            children: List.generate(sliceCount, (i) {
              // Setiap pita horizontal digeser kiri-kanan & atas-bawah membentuk gelombang sinus
              final topFraction = i / sliceCount;
              final bottomFraction = (i + 1) / sliceCount;
              final waveDx = math.sin(phase + (i * 0.75)) * 3.8;
              final waveDy = math.cos(phase + (i * 0.60)) * 1.6;

              return ClipRect(
                clipper: _HorizontalBandClipper(
                  topFactor: topFraction,
                  bottomFactor: bottomFraction,
                ),
                child: Transform.translate(
                  offset: Offset(waveDx, waveDy),
                  child: SizedBox(
                    width: screenWidth,
                    height: bgHeight,
                    child: lightImageChild,
                  ),
                ),
              );
            }),
          ),
        );
      },
      child: Image.asset(
        'assets/images/fallenstar_light.png',
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
      ),
    );
  }
}

class _HorizontalBandClipper extends CustomClipper<Rect> {
  final double topFactor;
  final double bottomFactor;

  const _HorizontalBandClipper({
    required this.topFactor,
    required this.bottomFactor,
  });

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      0,
      size.height * topFactor,
      size.width,
      size.height * bottomFactor,
    );
  }

  @override
  bool shouldReclip(covariant _HorizontalBandClipper oldClipper) {
    return oldClipper.topFactor != topFactor ||
        oldClipper.bottomFactor != bottomFactor;
  }
}
