import 'package:flutter/material.dart';
import '../../models/quiz_level_model.dart';

class QuizLevelNodeItemWidget extends StatelessWidget {
  final QuizLevelNodeModel node;
  final Color accentColor;
  final VoidCallback? onTap;

  const QuizLevelNodeItemWidget({
    super.key,
    required this.node,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color circleColor = node.isUnlocked
        ? const Color(0xFF4338CA)
        : const Color(0xFF94A3B8);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Judul Level di bagian atas lingkaran
        Text(
          node.title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),

        const SizedBox(height: 6),

        // 2. Lingkaran Node Level
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: node.isUnlocked
                    ? [
                        const Color(0xFF4338CA),
                        circleColor,
                      ]
                    : [
                        const Color(0xFFCBD5E1),
                        circleColor,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${node.levelNumber}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
