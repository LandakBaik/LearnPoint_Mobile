import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_play_colors.dart';

class QuizStatItemWidget extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const QuizStatItemWidget({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: QuizPlayColors.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: QuizPlayColors.darkText.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
