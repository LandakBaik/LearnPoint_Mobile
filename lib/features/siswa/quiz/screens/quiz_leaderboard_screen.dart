import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:learnpoint_mobile/features/siswa/profile/providers/profile_provider.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/leaderboard_entry_model.dart';

class QuizLeaderboardScreen extends StatefulWidget {
  const QuizLeaderboardScreen({super.key});

  @override
  State<QuizLeaderboardScreen> createState() => _QuizLeaderboardScreenState();
}

class _QuizLeaderboardScreenState extends State<QuizLeaderboardScreen> {
  LeaderboardPeriod _selectedPeriod = LeaderboardPeriod.weekly;
  String _selectedSubject = QuizLeaderboardDummyData.subjects.first;

  String _formatXp(int xp) {
    final str = xp.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final reverseIndex = str.length - i;
      buffer.write(str[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return '$buffer XP';
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().currentProfile;
    final entries = QuizLeaderboardDummyData.getEntries(
      period: _selectedPeriod,
      subject: _selectedSubject,
      currentUserName: profile.nama,
      currentUserClass: profile.kelas,
    );

    final topThree = entries.take(3).toList();
    final restEntries = entries.skip(3).toList();
    final currentUserEntry = entries.firstWhere(
      (e) => e.isCurrentUser,
      orElse: () => entries.last,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B1026),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1026), Color(0xFF151C42), Color(0xFF1A2250)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildPeriodTabs(),
              const SizedBox(height: 10),
              _buildSubjectFilterChips(),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  children: [
                    if (topThree.length == 3) _buildPodium(topThree),
                    const SizedBox(height: 18),
                    ...restEntries.map(_buildRankTile),
                  ],
                ),
              ),
              _buildCurrentUserStickyBar(currentUserEntry),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leaderboard Kuis',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Peringkat skor kuis siswa',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.45)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.amber,
                  size: 15,
                ),
                const SizedBox(width: 4),
                Text(
                  'Musim 1',
                  style: GoogleFonts.poppins(
                    color: Colors.amber.shade200,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: LeaderboardPeriod.values.map((period) {
          final isSelected = period == _selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedPeriod == period) return;
                setState(() => _selectedPeriod = period);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  period.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubjectFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: QuizLeaderboardDummyData.subjects.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final subject = QuizLeaderboardDummyData.subjects[index];
          final isSelected = subject == _selectedSubject;
          return GestureDetector(
            onTap: () {
              if (_selectedSubject == subject) return;
              setState(() => _selectedSubject = subject);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF38BDF8).withValues(alpha: 0.22)
                    : Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF38BDF8)
                      : Colors.white.withValues(alpha: 0.14),
                ),
              ),
              child: Text(
                subject,
                style: GoogleFonts.poppins(
                  color: isSelected ? const Color(0xFFBAE6FD) : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntryModel> topThree) {
    final first = topThree[0];
    final second = topThree[1];
    final third = topThree[2];

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
            child: _buildPodiumItem(
              entry: second,
              medalColor: const Color(0xFFE2E8F0),
              podiumHeight: 74,
              avatarRadius: 26,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPodiumItem(
              entry: first,
              medalColor: const Color(0xFFFBBF24),
              podiumHeight: 96,
              avatarRadius: 32,
              showCrown: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPodiumItem(
              entry: third,
              medalColor: const Color(0xFFFB923C),
              podiumHeight: 62,
              avatarRadius: 25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem({
    required LeaderboardEntryModel entry,
    required Color medalColor,
    required double podiumHeight,
    required double avatarRadius,
    bool showCrown = false,
  }) {
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
        Text(
          entry.name.split(' ').first,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          entry.kelas,
          style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10.5),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: podiumHeight,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                medalColor.withValues(alpha: 0.28),
                medalColor.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            border: Border.all(color: medalColor.withValues(alpha: 0.35)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatXp(entry.xp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: medalColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${entry.accuracyPercent}% akurat',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankTile(LeaderboardEntryModel entry) {
    final isMe = entry.isCurrentUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? const Color(0xFF38BDF8).withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe
              ? const Color(0xFF38BDF8).withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Text(
                  '${entry.rank}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                _buildTrendIcon(entry.trend),
              ],
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
                        entry.name,
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
                  '${entry.kelas} • ${entry.quizzesCompleted} Kuis • ${entry.accuracyPercent}% Akurat',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatXp(entry.xp),
            style: GoogleFonts.poppins(
              color: const Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIcon(RankTrend trend) {
    return switch (trend) {
      RankTrend.up => const Icon(
        Icons.arrow_drop_up_rounded,
        color: Color(0xFF34D399),
        size: 16,
      ),
      RankTrend.down => const Icon(
        Icons.arrow_drop_down_rounded,
        color: Color(0xFFF87171),
        size: 16,
      ),
      RankTrend.steady => const Icon(
        Icons.remove_rounded,
        color: Colors.white38,
        size: 12,
      ),
    };
  }

  Widget _buildCurrentUserStickyBar(LeaderboardEntryModel entry) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF101738),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(10),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Peringkat Kamu (${entry.name})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${entry.quizzesCompleted} Kuis selesai • Akurasi ${entry.accuracyPercent}%',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatXp(entry.xp),
            style: GoogleFonts.poppins(
              color: Colors.amber.shade300,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
