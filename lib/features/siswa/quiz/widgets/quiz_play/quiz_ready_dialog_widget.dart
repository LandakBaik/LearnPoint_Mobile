import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_play_colors.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_stat_item_widget.dart';

class QuizReadyDialogWidget extends StatelessWidget {
  final String themeTitle;
  final int levelNumber;
  final int totalQuestions;
  final int maxSecondsPerQuestion;
  final VoidCallback onCancel;
  final VoidCallback onStart;

  const QuizReadyDialogWidget({
    super.key,
    required this.themeTitle,
    required this.levelNumber,
    required this.totalQuestions,
    required this.maxSecondsPerQuestion,
    required this.onCancel,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 26),
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
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: QuizPlayColors.terracotta,
                  border: Border.all(
                    color: QuizPlayColors.inkOutline,
                    width: 2.2,
                  ),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: QuizPlayColors.parchmentBg,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Siap Memulai Kuis?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: QuizPlayColors.darkText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$themeTitle • Level $levelNumber',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: QuizPlayColors.terracotta,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Kamu punya waktu $maxSecondsPerQuestion detik untuk setiap soal. Jawab dengan tepat dan kumpulkan poin sebanyak-banyaknya!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: QuizPlayColors.darkText.withValues(alpha: 0.78),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3D5B3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: QuizPlayColors.inkOutline,
                    width: 1.8,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    QuizStatItemWidget(
                      icon: Icons.quiz_rounded,
                      iconColor: QuizPlayColors.terracotta,
                      label: 'Jumlah Soal',
                      value: '$totalQuestions',
                    ),
                    Container(
                      width: 1.5,
                      height: 30,
                      color: QuizPlayColors.inkOutline.withValues(alpha: 0.25),
                    ),
                    QuizStatItemWidget(
                      icon: Icons.timer_rounded,
                      iconColor: const Color(0xFFB45309),
                      label: 'Waktu / Soal',
                      value: '${maxSecondsPerQuestion}s',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
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
                        'Batal',
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
                      onPressed: onStart,
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
                        'Mulai!',
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
      ),
    );
  }
}
