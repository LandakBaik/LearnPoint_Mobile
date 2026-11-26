import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/quiz_level_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_play_colors.dart';

class QuizDifficultyLockedDialogWidget extends StatelessWidget {
  final String currentDifficulty;
  final String targetDifficulty;
  final int completedLevels;
  final int totalAvailableLevels;
  final QuizLevelNodeModel? activeLevelNode;
  final VoidCallback? onPlayActiveLevel;

  const QuizDifficultyLockedDialogWidget({
    super.key,
    required this.currentDifficulty,
    required this.targetDifficulty,
    required this.completedLevels,
    required this.totalAvailableLevels,
    this.activeLevelNode,
    this.onPlayActiveLevel,
  });

  static Future<void> show(
    BuildContext context, {
    required String currentDifficulty,
    required String targetDifficulty,
    required int completedLevels,
    required int totalAvailableLevels,
    QuizLevelNodeModel? activeLevelNode,
    VoidCallback? onPlayActiveLevel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => QuizDifficultyLockedDialogWidget(
        currentDifficulty: currentDifficulty,
        targetDifficulty: targetDifficulty,
        completedLevels: completedLevels,
        totalAvailableLevels: totalAvailableLevels,
        activeLevelNode: activeLevelNode,
        onPlayActiveLevel: onPlayActiveLevel,
      ),
    );
  }

  Color _difficultyColor(String diff) {
    switch (diff.toLowerCase()) {
      case 'sedang':
        return const Color(0xFFD97706);
      case 'sulit':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF059669);
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetColor = _difficultyColor(targetDifficulty);
    final safeTotal = totalAvailableLevels > 0 ? totalAvailableLevels : 1;
    final progress = (completedLevels / safeTotal).clamp(0.0, 1.0);
    final remaining = (totalAvailableLevels - completedLevels).clamp(0, 5);

    return Dialog(
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
            // Badge Ikon Gembok / Perisai
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: targetColor,
                    border: Border.all(
                      color: QuizPlayColors.inkOutline,
                      width: 2.4,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF0A0E17),
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: QuizPlayColors.parchmentBg,
                    size: 34,
                  ),
                ),
                Positioned(
                  bottom: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: QuizPlayColors.bgTop,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: QuizPlayColors.inkOutline,
                        width: 1.6,
                      ),
                    ),
                    child: Text(
                      targetDifficulty.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: QuizPlayColors.creamGold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Judul Modal
            Text(
              'Difficulty $targetDifficulty Terkunci!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: QuizPlayColors.darkText,
              ),
            ),
            const SizedBox(height: 8),

            // Deskripsi Syarat
            Text(
              totalAvailableLevels > 0
                  ? 'Tuntaskan $remaining level lagi pada Difficulty $currentDifficulty untuk membuka gerbang tantangan $targetDifficulty!'
                  : 'Guru belum menambahkan soal pada Difficulty $currentDifficulty.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: QuizPlayColors.darkText.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 18),

            // Box Progress Bar RPG
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE3D5B3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: QuizPlayColors.inkOutline,
                  width: 1.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shield_rounded,
                            size: 16,
                            color: _difficultyColor(currentDifficulty),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Progres $currentDifficulty',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: QuizPlayColors.darkText,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$completedLevels / $totalAvailableLevels Level',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: QuizPlayColors.terracotta,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: QuizPlayColors.bgTop.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: QuizPlayColors.inkOutline,
                        width: 1.4,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _difficultyColor(currentDifficulty),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
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
                      'Nanti Saja',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: QuizPlayColors.darkText,
                      ),
                    ),
                  ),
                ),
                if (activeLevelNode != null && onPlayActiveLevel != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onPlayActiveLevel!();
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: Text(
                        'Main ${activeLevelNode!.title}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
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
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
