import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/screens/gacha_loading_screen.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/screens/inventory_screen.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/screens/quiz_leaderboard_screen.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/screens/quiz_per_mapel_loading_screen.dart';

class QuizTopDecorationWidget extends StatelessWidget {
  const QuizTopDecorationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Tinggi tetap 298px agar posisi lengkungan container list mapel di bawahnya
    // tetap pas menyentuh batas bawah gambar background (topBgHeight = 427).
    return SizedBox(
      height: 336,
      width: double.infinity,
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            top: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Menu Inventory (Bentuk Lingkaran)
              _buildCircleMenuButton(
                color: const Color(0xFF4F46E5),
                icon: Icons.inventory_2_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    quizSlideRoute<void>(const Inventory()),
                  );
                },
              ),
              const SizedBox(width: 12),

              // 2. Menu Gacha (Bentuk Lingkaran)
              _buildCircleMenuButton(
                color: Colors.amber,
                icon: Icons.auto_awesome_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    quizSlideRoute<void>(const GachaLoadingScreen()),
                  );
                },
              ),
              const SizedBox(width: 12),

              // 3. Menu Leaderboard (Bentuk Lingkaran)
              _buildCircleMenuButton(
                color: Colors.white,
                icon: Icons.emoji_events_rounded,
                iconColor: const Color(0xFF2563EB),
                onTap: () {
                  Navigator.of(context).push(
                    quizSlideRoute<void>(const QuizLeaderboardScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleMenuButton({
    required Color color,
    required IconData icon,
    Color iconColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: iconColor,
        ),
      ),
    );
  }
}
