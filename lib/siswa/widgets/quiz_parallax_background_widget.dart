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

    final screenWidth = MediaQuery.sizeOf(context).width;

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
                    height: 600,
                    child: Image.asset(
                    'assets/images/stars1.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    ),
                ),
                ),
            ValueListenableBuilder<double>(
              valueListenable: scrollOffset,
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
