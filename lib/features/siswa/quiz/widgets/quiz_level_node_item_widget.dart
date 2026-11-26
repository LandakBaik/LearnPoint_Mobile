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
    final bool unlocked = node.isUnlocked && node.hasQuestions;
    final bool completed = node.isCompleted && node.hasQuestions;

    final Color bgColor = completed
        ? const Color(0xFF064E3B).withValues(alpha: 0.85)
        : (unlocked
              ? const Color(0xFF062530).withValues(alpha: 0.78)
              : const Color(0xFF0F172A).withValues(alpha: 0.62));

    final Color borderColor = completed
        ? const Color(0xFF34D399).withValues(alpha: 0.90)
        : (unlocked
              ? const Color(0xFF67E8F9).withValues(alpha: 0.88)
              : Colors.white.withValues(alpha: 0.25));

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: completed
                  ? const Color(0xFF10B981).withValues(alpha: 0.35)
                  : (unlocked
                        ? const Color(0xFF22D3EE).withValues(alpha: 0.30)
                        : Colors.black.withValues(alpha: 0.25)),
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
            ] else if (completed) ...[
              const Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: Color(0xFF34D399),
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
                    : Colors.white.withValues(alpha: 0.62),
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
