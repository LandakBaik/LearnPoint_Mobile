import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'wavy_upward_light_painter.dart';

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

  double _lastScrollOffset = 0.0;
  double _scrollVelocity = 0.0;

  void _onScrollChanged() {
    final current = widget.scrollOffset.value;
    final delta = current - _lastScrollOffset;
    _lastScrollOffset = current;
    _scrollVelocity = (_scrollVelocity + delta * 0.0025).clamp(-0.08, 0.08);
  }

  void _decayTrail() {
    if (_scrollVelocity.abs() > 0.0002) {
      _scrollVelocity *= 0.86;
      if (_scrollVelocity.abs() <= 0.0002) {
        _scrollVelocity = 0.0;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _lastScrollOffset = widget.scrollOffset.value;
    widget.scrollOffset.addListener(_onScrollChanged);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )
      ..addListener(_decayTrail)
      ..repeat();

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
    widget.scrollOffset.removeListener(_onScrollChanged);
    _controller.dispose();
    _opacityController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeigh = MediaQuery.sizeOf(context).height;

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
                    animation: Listenable.merge([
                      _opacityAnimation,
                      _controller,
                    ]),
                    child: Image.asset(
                      'assets/images/stars1.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                    builder: (context, mainStarChild) {
                      final isScrolling = _scrollVelocity.abs() > 0.0005;

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
                        child: isScrolling
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Trail 2 (Ekor paling belakang, hanya aktif saat scroll)
                                  Transform.rotate(
                                    angle: -_scrollVelocity * 1.1,
                                    child: Image.asset(
                                      'assets/images/stars1.png',
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topCenter,
                                      opacity: const AlwaysStoppedAnimation(
                                        0.22,
                                      ),
                                    ),
                                  ),
                                  // Trail 1 (Ekor tengah, hanya aktif saat scroll)
                                  Transform.rotate(
                                    angle: -_scrollVelocity * 0.55,
                                    child: Image.asset(
                                      'assets/images/stars1.png',
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topCenter,
                                      opacity: const AlwaysStoppedAnimation(
                                        0.45,
                                      ),
                                    ),
                                  ),
                                  // Bintang Utama
                                  mainStarChild!,
                                ],
                              )
                            : mainStarChild,
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
                  painter: WavyUpwardLightPainter(phase: phase),
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
