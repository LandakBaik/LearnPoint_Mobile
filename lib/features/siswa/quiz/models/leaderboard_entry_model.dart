import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/models/item_model.dart';

class LeaderboardMapelOptionModel {
  final int id;
  final String namaMapel;

  const LeaderboardMapelOptionModel({
    required this.id,
    required this.namaMapel,
  });

  factory LeaderboardMapelOptionModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardMapelOptionModel(
      id: int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      namaMapel: (json['nama_mapel'] ?? json['nama'] ?? 'Mata Pelajaran')
          .toString(),
    );
  }
}

class LeaderboardEntryModel {
  final int rank;
  final int siswaId;
  final String nama;
  final String initials;
  final String kelas;
  final int totalSkor;
  final String skorFormatted;
  final int totalKuis;
  final int totalDurasi;
  final bool isMe;
  final BannerItemModel activeBanner;
  final Color avatarColor;

  const LeaderboardEntryModel({
    required this.rank,
    required this.siswaId,
    required this.nama,
    required this.initials,
    required this.kelas,
    required this.totalSkor,
    required this.skorFormatted,
    required this.totalKuis,
    required this.totalDurasi,
    required this.isMe,
    required this.activeBanner,
    required this.avatarColor,
  });

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

  bool get hasCustomBanner =>
      activeBanner.localAssetPath != null ||
      (!activeBanner.isDefault && activeBanner.fullGifUrl.isNotEmpty);

  String get durasiFormatted {
    if (totalDurasi <= 0) return '-';
    final minutes = totalDurasi ~/ 60;
    final seconds = totalDurasi % 60;
    if (minutes <= 0) return '${seconds}d';
    return '${minutes}m ${seconds}d';
  }

  factory LeaderboardEntryModel.fromJson(
    Map<String, dynamic> json, {
    int fallbackRank = 1,
  }) {
    final rank =
        int.tryParse((json['rank'] ?? fallbackRank).toString()) ?? fallbackRank;
    final siswaId = int.tryParse((json['siswa_id'] ?? json['id'] ?? 0).toString()) ?? 0;
    final nama = (json['nama'] ?? json['name'] ?? 'Siswa').toString().trim();
    final rawInitials = (json['initials'] ?? '').toString().trim();
    final initials = rawInitials.isNotEmpty
        ? rawInitials.toUpperCase()
        : _computeInitials(nama);
    final kelas = (json['kelas'] ?? '-').toString();
    final totalSkor =
        int.tryParse((json['total_skor'] ?? json['xp'] ?? 0).toString()) ?? 0;
    final rawFormatted = (json['skor_formatted'] ?? '').toString().trim();
    final skorFormatted = rawFormatted.isNotEmpty
        ? rawFormatted
        : formatNumberDot(totalSkor);
    final totalKuis =
        int.tryParse((json['total_kuis'] ?? json['quizzes_completed'] ?? 0).toString()) ?? 0;
    final totalDurasi =
        int.tryParse((json['total_durasi'] ?? 0).toString()) ?? 0;
    final isMe = json['is_me'] == true ||
        json['is_me'] == 1 ||
        json['is_current_user'] == true;

    BannerItemModel banner = const BannerItemModel(
      kode: 'default',
      nama: 'Tema Bawaan',
    );
    if (json['active_banner'] is Map<String, dynamic>) {
      final bannerMap = json['active_banner'] as Map<String, dynamic>;
      final gifRaw = (bannerMap['gif_url'] ?? bannerMap['full_url'])?.toString();
      banner = BannerItemModel.fromJson({
        ...bannerMap,
        'gif_url': ?gifRaw,
      });
    }

    final colorIndex = (siswaId > 0 ? siswaId : rank) % _palette.length;

    return LeaderboardEntryModel(
      rank: rank,
      siswaId: siswaId,
      nama: nama,
      initials: initials,
      kelas: kelas,
      totalSkor: totalSkor,
      skorFormatted: skorFormatted,
      totalKuis: totalKuis,
      totalDurasi: totalDurasi,
      isMe: isMe,
      activeBanner: banner,
      avatarColor: _palette[colorIndex],
    );
  }

  static String _computeInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'S';
    if (parts.length == 1) {
      final first = parts.first;
      return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  static String formatNumberDot(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final reverseIndex = str.length - i;
      buffer.write(str[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }
}

class QuizLeaderboardResponseModel {
  final String? tingkatan;
  final String periodeLabel;
  final LeaderboardMapelOptionModel? selectedMapel;
  final List<LeaderboardMapelOptionModel> filterMapels;
  final LeaderboardEntryModel? myRank;
  final List<LeaderboardEntryModel> topThree;
  final List<LeaderboardEntryModel> leaderboard;

  const QuizLeaderboardResponseModel({
    this.tingkatan,
    required this.periodeLabel,
    this.selectedMapel,
    required this.filterMapels,
    this.myRank,
    required this.topThree,
    required this.leaderboard,
  });

  List<LeaderboardEntryModel> get restRankings =>
      leaderboard.length > 3 ? leaderboard.skip(3).toList() : const [];

  factory QuizLeaderboardResponseModel.fromJson(Map<String, dynamic> json) {
    final tingkatanRaw = json['tingkatan']?.toString().trim();
    final tingkatan =
        (tingkatanRaw == null || tingkatanRaw.isEmpty || tingkatanRaw == 'null')
            ? null
            : tingkatanRaw;

    final periodeLabel =
        (json['periode_label'] ?? 'Periode Aktif').toString().trim();

    LeaderboardMapelOptionModel? selectedMapel;
    if (json['selected_mapel'] is Map<String, dynamic>) {
      selectedMapel = LeaderboardMapelOptionModel.fromJson(
        json['selected_mapel'] as Map<String, dynamic>,
      );
    }

    final rawFilterMapels = json['filter_mapels'] is List
        ? json['filter_mapels'] as List
        : (json['mapels'] is List ? json['mapels'] as List : const []);
    final filterMapels = rawFilterMapels
        .whereType<Map<String, dynamic>>()
        .map(LeaderboardMapelOptionModel.fromJson)
        .where((m) => m.id > 0)
        .toList();

    final rawLeaderboard =
        json['leaderboard'] is List ? json['leaderboard'] as List : const [];
    final leaderboard = <LeaderboardEntryModel>[];
    for (int i = 0; i < rawLeaderboard.length; i++) {
      final item = rawLeaderboard[i];
      if (item is Map<String, dynamic>) {
        leaderboard.add(
          LeaderboardEntryModel.fromJson(item, fallbackRank: i + 1),
        );
      }
    }

    final rawTopThree =
        json['top_three'] is List ? json['top_three'] as List : const [];
    final topThree = rawTopThree.isNotEmpty
        ? [
            for (int i = 0; i < rawTopThree.length; i++)
              if (rawTopThree[i] is Map<String, dynamic>)
                LeaderboardEntryModel.fromJson(
                  rawTopThree[i] as Map<String, dynamic>,
                  fallbackRank: i + 1,
                ),
          ]
        : leaderboard.take(3).toList();

    LeaderboardEntryModel? myRank;
    if (json['my_rank'] is Map<String, dynamic>) {
      myRank = LeaderboardEntryModel.fromJson(
        json['my_rank'] as Map<String, dynamic>,
      );
    } else {
      for (final entry in leaderboard) {
        if (entry.isMe) {
          myRank = entry;
          break;
        }
      }
    }

    return QuizLeaderboardResponseModel(
      tingkatan: tingkatan,
      periodeLabel: periodeLabel.isEmpty ? 'Periode Aktif' : periodeLabel,
      selectedMapel: selectedMapel,
      filterMapels: filterMapels,
      myRank: myRank,
      topThree: topThree,
      leaderboard: leaderboard,
    );
  }
}
