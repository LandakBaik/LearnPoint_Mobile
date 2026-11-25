import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_play_colors.dart';

class QuizQuestionCardWidget extends StatelessWidget {
  final int questionIndex;
  final String questionText;

  const QuizQuestionCardWidget({
    super.key,
    required this.questionIndex,
    required this.questionText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Kartu Krem Utama
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 15),
          padding: const EdgeInsets.fromLTRB(22, 30, 22, 24),
          decoration: BoxDecoration(
            color: QuizPlayColors.parchmentBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: QuizPlayColors.inkOutline, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF0A0E17),
                offset: Offset(0, 6),
                blurRadius: 0,
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Text(
              questionText,
              key: ValueKey<int>(questionIndex),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: QuizPlayColors.darkText,
                height: 1.38,
              ),
            ),
          ),
        ),

        // Pill Badge "SOAL" di Tengah Atas Kartu
        Positioned(
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            decoration: BoxDecoration(
              color: QuizPlayColors.terracotta,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: QuizPlayColors.inkOutline,
                width: 2.2,
              ),
            ),
            child: const Text(
              'SOAL',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: QuizPlayColors.darkText,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
