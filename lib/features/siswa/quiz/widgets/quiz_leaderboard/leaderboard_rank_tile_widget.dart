import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/models/item_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/leaderboard_entry_model.dart';

class LeaderboardRankTileWidget extends StatelessWidget {
  final LeaderboardEntryModel entry;

  const LeaderboardRankTileWidget({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = entry.isMe;
    final hasBanner = entry.hasCustomBanner;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isMe
            ? const Color(0xFF38BDF8).withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe
              ? const Color(0xFF38BDF8).withValues(alpha: 0.75)
              : Colors.white.withValues(alpha: 0.12),
          width: isMe ? 1.5 : 1.0,
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
                    banner: entry.activeBanner,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    '#${entry.rank}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: entry.avatarColor,
                  child: Text(
                    entry.initials,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              entry.nama,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF38BDF8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Kamu',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF0F172A),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kelas ${entry.kelas} • ${entry.totalKuis} Kuis selesai',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    '${entry.skorFormatted} XP',
                    style: GoogleFonts.poppins(
                      color: Colors.amber.shade300,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
