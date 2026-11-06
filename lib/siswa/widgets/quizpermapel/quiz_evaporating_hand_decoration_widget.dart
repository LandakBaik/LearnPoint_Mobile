import 'package:flutter/material.dart';

/// Widget hiasan untuk menampilkan hand1.png sebagai gambar statis biasa
/// tanpa efek animasi menguap.
class QuizEvaporatingHandDecorationWidget extends StatelessWidget {
  final String imageAsset;
  final double widthFactor;

  const QuizEvaporatingHandDecorationWidget({
    super.key,
    this.imageAsset = 'assets/images/hand1.png',
    this.widthFactor = 0.76,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final handWidth =
              (constraints.maxWidth * widthFactor).clamp(240.0, 340.0);
          final handHeight =
              (constraints.maxHeight * 0.78).clamp(420.0, 660.0);

          return Align(
            alignment: const Alignment(0.0, 0.08),
            child: SizedBox(
              width: handWidth,
              height: handHeight,
              child: Image.asset(
                imageAsset,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
