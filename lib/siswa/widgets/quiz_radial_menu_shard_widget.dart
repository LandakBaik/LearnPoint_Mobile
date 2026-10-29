import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../models/quiz_per_mapel.dart';
import 'quiz_shard_placeholder_painter.dart';

/// Widget Bilah Menu berbentuk pedang/corong yang mengelilingi planet.
/// Mengarah ke kanan secara default (pangkal ujung pedang di kiri dekat planet, gagang di kanan).
class QuizRadialMenuShardWidget extends StatelessWidget {
  final QuizPerMapelM item;
  final int variantIndex;
  final bool isTextFlipped;

  const QuizRadialMenuShardWidget({
    super.key,
    required this.item,
    required this.variantIndex,
    required this.isTextFlipped,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: item.menuImageAsset == null
          ? QuizShardPlaceholderPainter(
              variantIndex: variantIndex,
              baseColor: const Color(0xFF0D9488),
            )
          : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (item.menuImageAsset != null)
            Positioned.fill(
              child: Image.asset(
                item.menuImageAsset!,
                fit: BoxFit.contain,
              ),
            ),

          // Teks nama tema ditempatkan tepat di sepanjang bilah pedang (sebelah kiri gagang),
          // dan menggunakan FittedBox agar tidak keluar dari bilah pedang.
          Padding(
            padding: item.menuImageAsset != null
                ? const EdgeInsets.only(
                    left: 16.0,
                    right: 38.0,
                    top: 14.0,
                    bottom: 14.0,
                  )
                : const EdgeInsets.only(
                    left: 34.0,
                    right: 12.0,
                    top: 12.0,
                    bottom: 12.0,
                  ),
            child: Align(
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: isTextFlipped ? math.pi : 0.0,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.title,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFE0F2FE),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      shadows: [
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
