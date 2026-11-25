import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_play_colors.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_play/quiz_power_star_painter.dart';

class QuizPowerUpBottomSheetWidget extends StatelessWidget {
  final int power5050Remaining;
  final int powerExtraTimeRemaining;
  final int powerDoublePointsRemaining;
  final bool is5050UsedOnQuestion;
  final bool isDoublePointsActive;
  final VoidCallback onUse5050;
  final VoidCallback onUseExtraTime;
  final VoidCallback onUseDoublePoints;

  const QuizPowerUpBottomSheetWidget({
    super.key,
    required this.power5050Remaining,
    required this.powerExtraTimeRemaining,
    required this.powerDoublePointsRemaining,
    required this.is5050UsedOnQuestion,
    required this.isDoublePointsActive,
    required this.onUse5050,
    required this.onUseExtraTime,
    required this.onUseDoublePoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
      decoration: const BoxDecoration(
        color: QuizPlayColors.bgTop,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(
          top: BorderSide(color: QuizPlayColors.inkOutline, width: 2.5),
          left: BorderSide(color: QuizPlayColors.inkOutline, width: 2.5),
          right: BorderSide(color: QuizPlayColors.inkOutline, width: 2.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(
                width: 24,
                height: 24,
                child: CustomPaint(
                  painter: QuizPowerStarPainter(isActive: true),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'GUNAKAN POWER',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: QuizPlayColors.creamGold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih kekuatan khusus untuk membantumu di soal ini',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 18),
          _buildPowerOptionTile(
            icon: Icons.auto_fix_high_rounded,
            badgeColor: const Color(0xFFF3E2B3),
            title: '50 : 50',
            subtitle: 'Hapus 2 pilihan jawaban yang salah',
            remaining: power5050Remaining,
            alreadyUsedOnQuestion: is5050UsedOnQuestion,
            onTap: onUse5050,
          ),
          const SizedBox(height: 10),
          _buildPowerOptionTile(
            icon: Icons.more_time_rounded,
            badgeColor: const Color(0xFF93BE79),
            title: '+15 Detik',
            subtitle: 'Tambah waktu pengerjaan soal ini',
            remaining: powerExtraTimeRemaining,
            alreadyUsedOnQuestion: false,
            onTap: onUseExtraTime,
          ),
          const SizedBox(height: 10),
          _buildPowerOptionTile(
            icon: Icons.bolt_rounded,
            badgeColor: const Color(0xFFC4745A),
            title: '2x Poin',
            subtitle: 'Gandakan skor jika jawabanmu benar',
            remaining: powerDoublePointsRemaining,
            alreadyUsedOnQuestion: isDoublePointsActive,
            onTap: onUseDoublePoints,
          ),
        ],
      ),
    );
  }

  Widget _buildPowerOptionTile({
    required IconData icon,
    required Color badgeColor,
    required String title,
    required String subtitle,
    required int remaining,
    required bool alreadyUsedOnQuestion,
    required VoidCallback onTap,
  }) {
    final bool canUse = remaining > 0 && !alreadyUsedOnQuestion;

    return GestureDetector(
      onTap: canUse ? onTap : null,
      child: Opacity(
        opacity: canUse ? 1.0 : 0.45,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: QuizPlayColors.optionCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: QuizPlayColors.inkOutline, width: 2.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF0A0E17),
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badgeColor,
                  border: Border.all(
                    color: QuizPlayColors.inkOutline,
                    width: 1.8,
                  ),
                ),
                child: Icon(icon, color: QuizPlayColors.darkText, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alreadyUsedOnQuestion
                          ? 'Sudah aktif di soal ini'
                          : subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: remaining > 0
                      ? QuizPlayColors.creamGold.withValues(alpha: 0.16)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: remaining > 0
                        ? QuizPlayColors.creamGold.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  '${remaining}x',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: remaining > 0
                        ? QuizPlayColors.creamGold
                        : Colors.white54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
