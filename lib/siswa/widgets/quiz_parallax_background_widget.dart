import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class QuizParallaxBackgroundWidget extends StatelessWidget {
  final double topBgHeight;
  final ValueListenable<double> scrollOffset;

  const QuizParallaxBackgroundWidget({
    super.key,
    required this.topBgHeight,
    required this.scrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: topBgHeight,
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
              valueListenable: scrollOffset,
              builder: (context, offset, child) {
                return Transform.translate(
                  // Gerak ke kanan (dx positif) dan sedikit ke bawah (dy positif kecil)
                  offset: Offset(offset * 0.35, offset * 0.08),
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/stars1.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            Image.asset(
              'assets/images/lands.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ],
        ),
      ),
    );
  }
}
