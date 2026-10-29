import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

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
  late AnimationController _controller;
  late AnimationController _opacityController;
late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 40),
        )..repeat();

    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _opacityAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(_opacityController);
  }

  @override
  void dispose() {
    _controller.dispose();
    _opacityController.dispose();
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
            Image.asset(
              'assets/images/spacebg1.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            ValueListenableBuilder<double>(
              valueListenable: widget.scrollOffset,
              builder: (context, offset, child) {
                return ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    minWidth: 0,
                    maxWidth: double.infinity,
                    minHeight: 0,
                    maxHeight: double.infinity,
                    child: Transform.rotate(
                      angle: offset * 0.001,
                      alignment: Alignment.center,
                      child: child,
                    ),
                  ),
                );
              },
              child: SizedBox(
 width: 600,
 height:  600,
 child: RotationTransition(
 turns: _controller,
 child: Image.asset(
 'assets/images/glxy.png',
 fit: BoxFit.cover,
 alignment: Alignment.topCenter,
 ),
 ),
 ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: widget.scrollOffset,
              builder: (context, offset, child) {
                return ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    minWidth: 0,
                    maxWidth: double.infinity,
                    minHeight: 0,
                    maxHeight: double.infinity,
                    child: Transform.rotate(
                      angle: offset * 0.001,
                      alignment: Alignment.center,
                      child: child,
                    ),
                  ),
                );
              },
              child: SizedBox(
 width: screenWidth,
 height: screenWidth,
 child: RotationTransition(
 turns: _controller,
 child: AnimatedBuilder(
  animation: _opacityAnimation,
  child: Image.asset(
    'assets/images/stars1.png',
    fit: BoxFit.cover,
    alignment: Alignment.topCenter,
  ),
  builder: (context, child) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment(_opacityAnimation.value - 1.0, 0),
          end: Alignment(_opacityAnimation.value + 1.0, 0),
          tileMode: TileMode.mirror,
          colors: [
            Colors.white.withValues(alpha: 0.20),
            Colors.white,
            Colors.white.withValues(alpha: 0.20),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect);
      },
      child: child,
    );
  },
),
 ),
 ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                // Dikali 8 agar gelombang bergerak lebih hidup karena durasi controller 40 detik
                final phase = _controller.value * 2 * math.pi * 10;

                return CustomPaint(
                  size: Size(screenWidth, widget.topBgHeight),
                  painter: _WavyUpwardLightPainter(phase: phase),
                );
              },
            ),
            ValueListenableBuilder<double>(
              valueListenable: widget.scrollOffset,
              builder: (context, offset, child) {
                final boundedOffset = offset.clamp(0.0, 100.0);

                return Transform.translate(
                  // Gerak ke kanan (dx positif) dan sedikit ke bawah (dy positif kecil)
                  offset: Offset(boundedOffset * 0, boundedOffset * -0.4),
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/lands.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            // Image.asset(
            //   'assets/images/lands.png',
            //   fit: BoxFit.cover,
            //   alignment: Alignment.center,
            // ),
          ],
        ),
      ),
    );
  }
}

class _WavyUpwardLightPainter extends CustomPainter {
  final double phase;

  const _WavyUpwardLightPainter({required this.phase});

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
    final rect = Rect.fromLTWH(0, baseGlowTop - 40, size.width, size.height - baseGlowTop + 40);
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
  bool shouldRepaint(covariant _WavyUpwardLightPainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
