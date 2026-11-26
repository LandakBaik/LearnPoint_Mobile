import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:learnpoint_mobile/features/siswa/gamification/data/gacha_service.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/models/item_model.dart';
import 'package:learnpoint_mobile/features/siswa/profile/providers/profile_provider.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/leaderboard_entry_model.dart';

class LeaderboardStickyMyRankWidget extends StatelessWidget {
  final LeaderboardEntryModel? myRank;

  const LeaderboardStickyMyRankWidget({
    super.key,
    required this.myRank,
  });

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().currentProfile;
    final fallbackBanner = GachaService.activeBannerNotifier.value;
    final activeBanner = myRank?.activeBanner ?? fallbackBanner;
    final hasBanner = activeBanner != null &&
        (activeBanner.localAssetPath != null ||
            (!activeBanner.isDefault && activeBanner.fullGifUrl.isNotEmpty));

    final displayName = myRank?.nama ??
        (profile.name.trim().isNotEmpty ? profile.name.trim() : 'Kamu');
    final displayClass = myRank?.kelas ??
        (profile.gradeClass.trim().isNotEmpty
            ? profile.gradeClass.trim()
            : '-');

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF101738),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
          ),
        ),
      ),
      child: Stack(
        children: [
          if (hasBanner)
            Positioned.fill(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BannerMediaView(
                    banner: activeBanner,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: const Color(0xFF0B1026).withValues(alpha: 0.72),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    myRank != null ? '#${myRank!.rank}' : '-',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Posisi Kamu ($displayName)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (activeBanner != null &&
                              activeBanner.badge.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                activeBanner.badge,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        myRank != null
                            ? 'Kelas $displayClass • ${myRank!.totalKuis} Kuis selesai'
                            : 'Belum masuk peringkat • Selesaikan kuis untuk mengumpulkan skor!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (myRank != null) ...[
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total Skor',
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber.shade300,
                            size: 15,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${myRank!.skorFormatted} XP',
                            style: GoogleFonts.poppins(
                              color: Colors.amber.shade300,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
