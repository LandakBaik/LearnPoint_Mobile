import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_play_colors.dart';

class QuizProgressIndicatorsWidget extends StatelessWidget {
  final int totalQuestions;
  final int currentIndex;

  const QuizProgressIndicatorsWidget({
    super.key,
    required this.totalQuestions,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(totalQuestions, (i) {
        final bool isDone = i < currentIndex;
        final bool isCurrent = i == currentIndex;

        if (isCurrent) {
          // Lingkaran konsentris aktif (pinggiran krem, tengah terracotta)
          return Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: QuizPlayColors.creamGold, width: 2),
            ),
            child: Center(
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: QuizPlayColors.terracotta,
                ),
              ),
            ),
          );
        }

        if (isDone) {
          // Titik penuh krem/emas untuk soal yang sudah lewat
          return Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE5CB86),
            ),
          );
        }

        // Soal yang belum dikerjakan
        if (i == totalQuestions - 1) {
          return Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.32),
                width: 1.4,
              ),
            ),
            child: Center(
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ),
          );
        }

        return Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.4,
            ),
          ),
        );
      }),
    );
  }
}
