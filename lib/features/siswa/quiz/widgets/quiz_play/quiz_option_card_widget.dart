import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_play_colors.dart';

class QuizOptionCardWidget extends StatelessWidget {
  final int index;
  final String text;
  final int correctIndex;
  final int? selectedOptionIndex;
  final bool isAnswerLocked;
  final bool isEliminated;
  final VoidCallback onTap;

  const QuizOptionCardWidget({
    super.key,
    required this.index,
    required this.text,
    required this.correctIndex,
    required this.selectedOptionIndex,
    required this.isAnswerLocked,
    required this.isEliminated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedOptionIndex == index;
    final bool isCorrectOption = index == correctIndex;

    Color cardBg = QuizPlayColors.optionCardBg;
    Color borderColor = QuizPlayColors.inkOutline;
    Widget? trailingStatus;

    if (isAnswerLocked) {
      if (isCorrectOption) {
        cardBg = const Color(0xFF1F4B38);
        borderColor = const Color(0xFF4ADE80);
        trailingStatus = const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF4ADE80),
          size: 22,
        );
      } else if (isSelected && !isCorrectOption) {
        cardBg = const Color(0xFF4C1F2A);
        borderColor = const Color(0xFFF87171);
        trailingStatus = const Icon(
          Icons.cancel_rounded,
          color: Color(0xFFF87171),
          size: 22,
        );
      }
    }

    final letter = String.fromCharCode(65 + index); // A, B, C, D
    final badgeColor =
        QuizPlayColors.badgeColors[index % QuizPlayColors.badgeColors.length];

    return GestureDetector(
      onTap: isEliminated ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: isEliminated ? 0.3 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF0A0E17),
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              // Badge Huruf Bulat (A, B, C, D)
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badgeColor,
                  border: Border.all(
                    color: QuizPlayColors.inkOutline,
                    width: 1.8,
                  ),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: QuizPlayColors.darkText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Teks Opsi Jawaban
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF1F5F9),
                    height: 1.25,
                    decoration:
                        isEliminated ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (trailingStatus != null) ...[
                const SizedBox(width: 10),
                trailingStatus,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
