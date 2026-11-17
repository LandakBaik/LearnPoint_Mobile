import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/quiz_level_model.dart';

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
    final bool unlocked = node.isUnlocked;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: unlocked
              ? const Color(0xFF062530).withValues(alpha: 0.72)
              : const Color(0xFF0F172A).withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: unlocked
                ? const Color(0xFF67E8F9).withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.25),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: unlocked
                  ? const Color(0xFF22D3EE).withValues(alpha: 0.30)
                  : Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!unlocked) ...[
              Icon(
                Icons.lock_rounded,
                size: 13,
                color: Colors.white.withValues(alpha: 0.65),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              node.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: unlocked
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.65),
                shadows: [
                  Shadow(
                    color: unlocked
                        ? const Color(0xFF06B6D4).withValues(alpha: 0.80)
                        : Colors.black.withValues(alpha: 0.60),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
