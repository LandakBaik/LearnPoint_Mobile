import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_play_colors.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_power_star_painter.dart';

class QuizPowerStarButtonWidget extends StatelessWidget {
  final Animation<double> floatAnimation;
  final int totalPowersRemaining;
  final bool isQuizStarted;
  final bool isAnswerLocked;
  final VoidCallback onTap;

  const QuizPowerStarButtonWidget({
    super.key,
    required this.floatAnimation,
    required this.totalPowersRemaining,
    required this.isQuizStarted,
    required this.isAnswerLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPower = totalPowersRemaining > 0;
    final bool canTap = isQuizStarted && !isAnswerLocked && hasPower;

    return GestureDetector(
      onTap: canTap
          ? onTap
          : () {
              if (!hasPower && isQuizStarted && !isAnswerLocked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua power sudah digunakan pada kuis ini.'),
                    duration: Duration(milliseconds: 1400),
                  ),
                );
              }
            },
      child: AnimatedBuilder(
        animation: floatAnimation,
        builder: (context, child) {
          final pulse = 1.0 + (0.08 * floatAnimation.value);
          return Transform.scale(
            scale: canTap ? pulse : 1.0,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Cahaya halo kuning di belakang bintang
                if (hasPower)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFF3E0A2).withValues(alpha: 0.36),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                SizedBox(
                  width: 34,
                  height: 34,
                  child: CustomPaint(
                    painter: QuizPowerStarPainter(isActive: hasPower),
                  ),
                ),
                // Badge jumlah power tersisa
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: hasPower
                          ? QuizPlayColors.terracotta
                          : const Color(0xFF475569),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: QuizPlayColors.inkOutline,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '$totalPowersRemaining',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
