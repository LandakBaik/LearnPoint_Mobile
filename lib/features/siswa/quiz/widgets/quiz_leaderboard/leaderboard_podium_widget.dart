import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/models/item_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/leaderboard_entry_model.dart';

class LeaderboardPodiumWidget extends StatelessWidget {
  final List<LeaderboardEntryModel> topThree;

  const LeaderboardPodiumWidget({
    super.key,
    required this.topThree,
  });

  @override
  Widget build(BuildContext context) {
    final first = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: second != null
                ? _PodiumColumnItem(
                    entry: second,
                    medalColor: const Color(0xFFE2E8F0),
                    podiumHeight: 82,
                    avatarRadius: 26,
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: first != null
                ? _PodiumColumnItem(
                    entry: first,
                    medalColor: const Color(0xFFFBBF24),
                    podiumHeight: 104,
                    avatarRadius: 32,
                    showCrown: true,
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: third != null
                ? _PodiumColumnItem(
                    entry: third,
                    medalColor: const Color(0xFFFB923C),
                    podiumHeight: 70,
                    avatarRadius: 25,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _PodiumColumnItem extends StatelessWidget {
  final LeaderboardEntryModel entry;
  final Color medalColor;
  final double podiumHeight;
  final double avatarRadius;
  final bool showCrown;

  const _PodiumColumnItem({
    required this.entry,
    required this.medalColor,
    required this.podiumHeight,
    required this.avatarRadius,
    this.showCrown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showCrown)
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFFFBBF24),
              size: 24,
            ),
          ),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: medalColor, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: medalColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: entry.avatarColor,
                child: Text(
                  entry.initials,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: avatarRadius * 0.56,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -8,
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: medalColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF151C42), width: 2),
                ),
                child: Text(
                  '${entry.rank}',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF0F172A),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                entry.nama.split(' ').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (entry.isMe) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Kamu',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF0F172A),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        Text(
          'Kelas ${entry.kelas}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10.5),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: podiumHeight,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            border: Border.all(color: medalColor.withValues(alpha: 0.45)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (entry.hasCustomBanner) ...[
                BannerMediaView(
                  banner: entry.activeBanner,
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0B1026).withValues(alpha: 0.45),
                        const Color(0xFF0B1026).withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ] else
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        medalColor.withValues(alpha: 0.28),
                        medalColor.withValues(alpha: 0.08),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${entry.skorFormatted} XP',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: medalColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.totalKuis} Kuis',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
