import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_play_colors.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_stat_item_widget.dart';

class QuizResultDialogWidget extends StatelessWidget {
  final int levelNumber;
  final int correctCount;
  final int totalQuestions;
  final int gemsScore;
  final VoidCallback onRetry;
  final VoidCallback onFinish;

  const QuizResultDialogWidget({
    super.key,
    required this.levelNumber,
    required this.correctCount,
    required this.totalQuestions,
    required this.gemsScore,
    required this.onRetry,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = (correctCount / totalQuestions * 100).round();
    final stars = accuracy >= 80
        ? 3
        : accuracy >= 50
            ? 2
            : 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: QuizPlayColors.parchmentBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: QuizPlayColors.inkOutline, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF0A0E17),
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active = i < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.star_rounded,
                    size: i == 1 ? 54 : 42,
                    color: active
                        ? const Color(0xFFEAB308)
                        : const Color(0xFFCBD5E1),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              'Level $levelNumber Selesai!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: QuizPlayColors.darkText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Kamu menjawab $correctCount dari $totalQuestions soal dengan benar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: QuizPlayColors.darkText.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE3D5B3),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: QuizPlayColors.inkOutline,
                  width: 1.8,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  QuizStatItemWidget(
                    icon: Icons.monetization_on_rounded,
                    iconColor: const Color(0xFFD97706),
                    label: 'Total Poin',
                    value: '$gemsScore',
                  ),
                  Container(
                    width: 1.5,
                    height: 36,
                    color: QuizPlayColors.inkOutline.withValues(alpha: 0.25),
                  ),
                  QuizStatItemWidget(
                    icon: Icons.check_circle_rounded,
                    iconColor: const Color(0xFF16A34A),
                    label: 'Akurasi',
                    value: '$accuracy%',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(
                        color: QuizPlayColors.inkOutline,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Ulangi',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: QuizPlayColors.darkText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onFinish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: QuizPlayColors.terracotta,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                      side: const BorderSide(
                        color: QuizPlayColors.inkOutline,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
