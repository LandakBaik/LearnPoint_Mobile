import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_play_colors.dart';

class QuizPlayTopHeaderWidget extends StatelessWidget {
  final int currentQuestionNumber;
  final int totalQuestions;
  final int remainingSeconds;
  final int gemsScore;
  final VoidCallback onBackTap;

  const QuizPlayTopHeaderWidget({
    super.key,
    required this.currentQuestionNumber,
    required this.totalQuestions,
    required this.remainingSeconds,
    required this.gemsScore,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLowTime = remainingSeconds <= 10;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Kiri: Tombol kembali halus + "SOAL X/Y"
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onBackTap,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.only(right: 8, top: 4, bottom: 4),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: QuizPlayColors.creamGold,
                  size: 18,
                ),
              ),
            ),
            Text(
              'SOAL $currentQuestionNumber/$totalQuestions',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: QuizPlayColors.creamGold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),

        // Kanan: Timer ringkas + Koin Skor
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isLowTime
                    ? const Color(0xFF4C1D24)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isLowTime
                      ? const Color(0xFFF87171)
                      : QuizPlayColors.creamGold.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: isLowTime
                        ? const Color(0xFFFCA5A5)
                        : QuizPlayColors.creamGold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${remainingSeconds}s',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isLowTime
                          ? const Color(0xFFFCA5A5)
                          : QuizPlayColors.creamGold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Ikon Koin Emas
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF6C85F),
                border: Border.all(
                  color: const Color(0xFFC88A1E),
                  width: 2,
                ),
              ),
              child: const Center(
                child: SizedBox(
                  width: 3,
                  height: 9,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFB47814),
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              '$gemsScore',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: QuizPlayColors.creamGold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
