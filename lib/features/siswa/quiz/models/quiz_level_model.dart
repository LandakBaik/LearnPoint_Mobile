import 'dart:math';

final Random _random = Random();

double _randomXFactor() => 0.15 + (0.70 / 99) * _random.nextInt(100);

class QuizLevelNodeModel {
  /// Nomor level di dalam Arc / Difficulty saat ini (1 s/d 5)
  final int levelNumber;
  /// Nomor step global dari backend (jika ada)
  final int? step;
  ///Nomor level di dalam Arc (1..5)
  final int arcLevelNum;
  /// Nama Arc / Difficulty ('Mudah', 'Sedang', 'Sulit')
  final String? arc;
  final String title;
  final double xFactor;
  final bool isUnlocked;
  final bool isCompleted;
  /// True jika guru sudah menginput soal untuk level & difficulty ini (`totalSoal > 0`)
  final bool hasQuestions;
  /// Status asli dari backend: 'aktif', 'selesai', 'terkunci', atau 'kosong' (belum diinput guru)
  final String status;
  final int totalSoal;
  final int answeredCount;
  final int correctCount;
  final int skorLevel;
  final int bintang;
  final String? keterangan;

  QuizLevelNodeModel({
    required this.levelNumber,
    this.step,
    int? arcLevelNum,
    this.arc,
    required this.title,
    double? xFactor,
    this.isUnlocked = true,
    this.isCompleted = false,
    this.hasQuestions = true,
    String? status,
    this.totalSoal = 0,
    this.answeredCount = 0,
    this.correctCount = 0,
    this.skorLevel = 0,
    this.bintang = 0,
    this.keterangan,
  }) : arcLevelNum = arcLevelNum ?? levelNumber,
       xFactor = xFactor ?? _randomXFactor(),
       status = status ??
           (!hasQuestions
               ? 'kosong'
               : (isCompleted ? 'selesai' : (isUnlocked ? 'aktif' : 'terkunci')));

  /// Membuat node level yang belum diinput soal oleh guru (terkunci)
  factory QuizLevelNodeModel.lockedEmpty({
    required String arc,
    required int levelNum,
  }) {
    return QuizLevelNodeModel(
      levelNumber: levelNum,
      arcLevelNum: levelNum,
      arc: arc,
      title: 'Level $levelNum',
      isUnlocked: false,
      isCompleted: false,
      hasQuestions: false,
      status: 'kosong',
      totalSoal: 0,
      keterangan:
          'Level $levelNum ($arc) belum memiliki soal yang diinput oleh guru.',
    );
  }

  /// Factory untuk mengubah item `adventure.levels` dari `GET /api/siswa/kuis/{quiz}`
  factory QuizLevelNodeModel.fromAdventureJson(Map<String, dynamic> json) {
    final step = int.tryParse((json['step'] ?? json['id'] ?? 1).toString()) ?? 1;
    final lvlNum = (int.tryParse((json['level_num'] ?? step).toString()) ?? step)
        .clamp(1, 5);
    final arc = json['arc']?.toString();
    final rawStatus = (json['status'] ?? 'terkunci').toString().toLowerCase();
    final totalSoal = int.tryParse((json['jumlah_soal'] ?? 0).toString()) ?? 0;
    final hasQuestions = totalSoal > 0;
    final isCompleted = hasQuestions && rawStatus == 'selesai';
    final isUnlocked =
        hasQuestions && (rawStatus == 'aktif' || rawStatus == 'selesai');

    return QuizLevelNodeModel(
      levelNumber: lvlNum,
      step: step,
      arcLevelNum: lvlNum,
      arc: arc,
      title: 'Level $lvlNum',
      isUnlocked: isUnlocked,
      isCompleted: isCompleted,
      hasQuestions: hasQuestions,
      status: hasQuestions ? rawStatus : 'kosong',
      totalSoal: totalSoal,
      answeredCount:
          int.tryParse((json['answered_count'] ?? 0).toString()) ?? 0,
      correctCount: int.tryParse((json['correct_count'] ?? 0).toString()) ?? 0,
      skorLevel: int.tryParse((json['skor_level'] ?? 0).toString()) ?? 0,
      bintang: int.tryParse((json['bintang'] ?? 0).toString()) ?? 0,
      keterangan: json['keterangan']?.toString(),
    );
  }

  /// Factory fallback untuk array `levels` standar dari `GET /api/siswa/kuis/{quiz}`
  factory QuizLevelNodeModel.fromSimpleLevelJson(
    Map<String, dynamic> json, {
    String arc = 'Mudah',
  }) {
    final levelNum =
        (int.tryParse((json['level_number'] ?? 1).toString()) ?? 1).clamp(1, 5);
    final totalSoal = int.tryParse((json['total_soal'] ?? 0).toString()) ?? 0;
    final hasQuestions = totalSoal > 0;
    final isCompleted =
        hasQuestions && (json['is_completed'] == true || json['is_completed'] == 1);
    final isUnlocked =
        hasQuestions && (json['is_unlocked'] == true || json['is_unlocked'] == 1);

    return QuizLevelNodeModel(
      levelNumber: levelNum,
      arcLevelNum: levelNum,
      arc: arc,
      title: 'Level $levelNum',
      isUnlocked: isUnlocked,
      isCompleted: isCompleted,
      hasQuestions: hasQuestions,
      status: !hasQuestions
          ? 'kosong'
          : (isCompleted ? 'selesai' : (isUnlocked ? 'aktif' : 'terkunci')),
      totalSoal: totalSoal,
      answeredCount:
          int.tryParse((json['answered_soal'] ?? 0).toString()) ?? 0,
    );
  }
}

/// Data peta level lengkap untuk 1 kuis, dikelompokkan per tingkat kesulitan (Mudah, Sedang, Sulit),
/// masing-masing tepat 5 level (Level 1 s/d Level 5).
class QuizAdventureMapData {
  static const List<String> allDifficulties = ['Mudah', 'Sedang', 'Sulit'];

  final List<String> activeDifficulties;
  final String currentDifficulty;
  final Map<String, List<QuizLevelNodeModel>> levelsByDifficulty;

  const QuizAdventureMapData({
    required this.activeDifficulties,
    required this.currentDifficulty,
    required this.levelsByDifficulty,
  });

  /// Mengambil daftar 5 level (Level 1..5) untuk difficulty tertentu.
  /// Level yang belum diinput guru otomatis dikembalikan dalam kondisi terkunci (`hasQuestions: false`).
  List<QuizLevelNodeModel> levelsFor(String difficulty) {
    final normalized = _normalizeArcName(difficulty);
    return levelsByDifficulty[normalized] ??
        List.generate(
          5,
          (i) => QuizLevelNodeModel.lockedEmpty(
            arc: normalized,
            levelNum: i + 1,
          ),
        );
  }

  /// Apakah semua level yang diinput guru pada [difficulty] ini sudah selesai dikerjakan?
  bool isDifficultyCompleted(String difficulty) {
    final levels = levelsFor(difficulty);
    final withQuestions = levels.where((l) => l.hasQuestions).toList();
    if (withQuestions.isEmpty) return false;
    return withQuestions.every((l) => l.isCompleted);
  }

  /// Apakah [difficulty] ini sudah terbuka untuk dimainkan?
  /// Difficulty pertama selalu terbuka; difficulty berikutnya terbuka jika ada minimal 1 level yang `isUnlocked`
  /// atau difficulty aktif sebelumnya sudah selesai.
  bool isDifficultyUnlocked(String difficulty) {
    final normalized = _normalizeArcName(difficulty);
    final levels = levelsFor(normalized);
    if (levels.any((l) => l.isUnlocked || l.isCompleted)) {
      return true;
    }
    final idx = activeDifficulties.indexWhere(
      (d) => _normalizeArcName(d) == normalized,
    );
    if (idx <= 0) return idx == 0;
    final prevDiff = activeDifficulties[idx - 1];
    return isDifficultyCompleted(prevDiff);
  }

  /// Mengambil nama difficulty lanjutan berikutnya (misal Mudah -> Sedang, Sedang -> Sulit).
  String? nextDifficultyAfter(String difficulty) {
    final normalized = _normalizeArcName(difficulty);
    final list = activeDifficulties.isNotEmpty
        ? activeDifficulties
        : allDifficulties;
    final idx = list.indexWhere((d) => _normalizeArcName(d) == normalized);
    if (idx >= 0 && idx < list.length - 1) {
      return _normalizeArcName(list[idx + 1]);
    }
    return null;
  }

  static String _normalizeArcName(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower == 'sedang') return 'Sedang';
    if (lower == 'sulit') return 'Sulit';
    return 'Mudah';
  }

  factory QuizAdventureMapData.defaultFallback() {
    final map = <String, List<QuizLevelNodeModel>>{};
    for (final diff in allDifficulties) {
      map[diff] = List.generate(
        5,
        (index) => QuizLevelNodeModel(
          levelNumber: index + 1,
          arcLevelNum: index + 1,
          arc: diff,
          title: 'Level ${index + 1}',
          isUnlocked: diff == 'Mudah' && index < 3,
          hasQuestions: diff == 'Mudah' && index < 4,
        ),
      );
    }
    return QuizAdventureMapData(
      activeDifficulties: allDifficulties,
      currentDifficulty: 'Mudah',
      levelsByDifficulty: map,
    );
  }
}

/// Default 5 level untuk 1 difficulty (Level 1 s/d Level 5)
final List<QuizLevelNodeModel> quizLevels = List.generate(
  5,
  (index) => QuizLevelNodeModel(
    levelNumber: index + 1,
    arcLevelNum: index + 1,
    arc: 'Mudah',
    title: 'Level ${index + 1}',
    isUnlocked: index < 3,
    hasQuestions: index < 4,
  ),
);
