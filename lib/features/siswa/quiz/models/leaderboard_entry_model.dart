import 'package:flutter/material.dart';

enum LeaderboardPeriod {
  weekly('Mingguan'),
  monthly('Bulanan'),
  allTime('Semua');

  final String label;
  const LeaderboardPeriod(this.label);
}

enum RankTrend { up, down, steady }

class LeaderboardEntryModel {
  final String id;
  final int rank;
  final String name;
  final String kelas;
  final int xp;
  final int quizzesCompleted;
  final int accuracyPercent;
  final Color avatarColor;
  final RankTrend trend;
  final bool isCurrentUser;

  const LeaderboardEntryModel({
    required this.id,
    required this.rank,
    required this.name,
    required this.kelas,
    required this.xp,
    required this.quizzesCompleted,
    required this.accuracyPercent,
    required this.avatarColor,
    this.trend = RankTrend.steady,
    this.isCurrentUser = false,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
}

class QuizLeaderboardDummyData {
  static const List<String> subjects = [
    'Semua Mapel',
    'Matematika',
    'IPA',
    'Bahasa Indonesia',
    'Bahasa Inggris',
    'IPS',
  ];

  static const List<Color> _palette = [
    Color(0xFF6366F1),
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
  ];

  static List<LeaderboardEntryModel> getEntries({
    required LeaderboardPeriod period,
    required String subject,
    required String currentUserName,
    required String currentUserClass,
  }) {
    final double periodMultiplier = switch (period) {
      LeaderboardPeriod.weekly => 1.0,
      LeaderboardPeriod.monthly => 3.4,
      LeaderboardPeriod.allTime => 9.2,
    };

    final int subjectIndex = subjects
        .indexOf(subject)
        .clamp(0, subjects.length - 1);
    final double subjectFactor = subjectIndex == 0
        ? 1.0
        : (0.88 - subjectIndex * 0.05);

    final baseStudents =
        <
          ({
            String id,
            String name,
            String kelas,
            int baseXp,
            int quizzes,
            int accuracy,
            RankTrend trend,
          })
        >[
          (
            id: 's1',
            name: 'Alya Putri Ramadhani',
            kelas: 'VIII-A',
            baseXp: 2480,
            quizzes: 24,
            accuracy: 96,
            trend: RankTrend.steady,
          ),
          (
            id: 's2',
            name: 'Rafi Pratama Putra',
            kelas: 'VIII-B',
            baseXp: 2310,
            quizzes: 22,
            accuracy: 93,
            trend: RankTrend.up,
          ),
          (
            id: 's3',
            name: 'Nadia Kusuma Wardani',
            kelas: 'VIII-A',
            baseXp: 2190,
            quizzes: 21,
            accuracy: 91,
            trend: RankTrend.down,
          ),
          (
            id: 's4',
            name: 'Dimas Arya Saputra',
            kelas: 'VIII-C',
            baseXp: 1980,
            quizzes: 19,
            accuracy: 89,
            trend: RankTrend.up,
          ),
          (
            id: 's5',
            name: 'Siti Nurhaliza',
            kelas: 'VIII-B',
            baseXp: 1845,
            quizzes: 18,
            accuracy: 88,
            trend: RankTrend.steady,
          ),
          (
            id: 's6',
            name: currentUserName.trim().isEmpty
                ? 'Kamu'
                : currentUserName.trim(),
            kelas: currentUserClass.trim().isEmpty
                ? 'VIII-A'
                : currentUserClass.trim(),
            baseXp: 1720,
            quizzes: 16,
            accuracy: 87,
            trend: RankTrend.up,
          ),
          (
            id: 's7',
            name: 'Fajar Nugroho',
            kelas: 'VIII-C',
            baseXp: 1610,
            quizzes: 15,
            accuracy: 84,
            trend: RankTrend.down,
          ),
          (
            id: 's8',
            name: 'Kirana Dewi Lestari',
            kelas: 'VIII-A',
            baseXp: 1490,
            quizzes: 14,
            accuracy: 82,
            trend: RankTrend.up,
          ),
          (
            id: 's9',
            name: 'Bagas Mahendra',
            kelas: 'VIII-B',
            baseXp: 1360,
            quizzes: 13,
            accuracy: 80,
            trend: RankTrend.steady,
          ),
          (
            id: 's10',
            name: 'Zahra Aulia',
            kelas: 'VIII-C',
            baseXp: 1240,
            quizzes: 12,
            accuracy: 78,
            trend: RankTrend.down,
          ),
        ];

    // Sedikit variasi urutan per filter agar terasa dinamis saat diganti
    final computed = List.generate(baseStudents.length, (i) {
      final item = baseStudents[i];
      final int jitter = ((i + subjectIndex * 3 + period.index * 2) % 4) * 35;
      final int xp = ((item.baseXp + jitter) * periodMultiplier * subjectFactor)
          .round();
      final int quizzes = (item.quizzes * periodMultiplier * subjectFactor)
          .round()
          .clamp(1, 999);

      return (
        item: item,
        xp: xp,
        quizzes: quizzes,
        color: _palette[i % _palette.length],
      );
    });

    computed.sort((a, b) => b.xp.compareTo(a.xp));

    return List.generate(computed.length, (index) {
      final entry = computed[index];
      return LeaderboardEntryModel(
        id: entry.item.id,
        rank: index + 1,
        name: entry.item.name,
        kelas: entry.item.kelas,
        xp: entry.xp,
        quizzesCompleted: entry.quizzes,
        accuracyPercent: entry.item.accuracy,
        avatarColor: entry.color,
        trend: entry.item.trend,
        isCurrentUser: entry.item.id == 's6',
      );
    });
  }
}
