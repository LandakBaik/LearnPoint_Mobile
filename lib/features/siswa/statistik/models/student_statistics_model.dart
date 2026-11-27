class AcademicPeriodModel {
  const AcademicPeriodModel({
    required this.id,
    required this.tahunAjaran,
    required this.semester,
  });

  final int id;
  final String tahunAjaran;
  final String semester;

  String get label => '$semester $tahunAjaran';

  factory AcademicPeriodModel.fromJson(Map<String, dynamic> json) {
    return AcademicPeriodModel(
      id: _asInt(json['id']),
      tahunAjaran: (json['tahun_ajaran'] ?? '-').toString(),
      semester: (json['semester'] ?? '-').toString(),
    );
  }
}

class SubjectScoreModel {
  const SubjectScoreModel({
    required this.name,
    required this.kkm,
    this.score,
    this.isCompleted,
  });

  final String name;
  final double kkm;
  final double? score;
  final bool? isCompleted;

  factory SubjectScoreModel.fromJson(Map<String, dynamic> json) {
    return SubjectScoreModel(
      name: (json['nama_mapel'] ?? json['nama'] ?? 'Mata Pelajaran').toString(),
      kkm: _asDouble(json['kkm']),
      score: _asNullableDouble(json['nilai']),
      isCompleted: json['tuntas'] is bool ? json['tuntas'] as bool : null,
    );
  }
}

class MonthlyScoreModel {
  const MonthlyScoreModel({
    required this.label,
    this.tugas,
    this.kuis,
    this.ujian,
  });

  final String label;
  final double? tugas;
  final double? kuis;
  final double? ujian;

  factory MonthlyScoreModel.fromJson(Map<String, dynamic> json) {
    return MonthlyScoreModel(
      label: (json['label'] ?? '').toString(),
      tugas: _asNullableDouble(json['tugas']),
      kuis: _asNullableDouble(json['kuis']),
      ujian: _asNullableDouble(json['ujian']),
    );
  }
}

class StudentStatisticsModel {
  const StudentStatisticsModel({
    required this.hasRealData,
    required this.average,
    required this.category,
    required this.tugasAverage,
    required this.kuisAverage,
    required this.ujianAverage,
    required this.tugasGraded,
    required this.tugasTotal,
    required this.kuisGraded,
    required this.kuisTotal,
    required this.ujianGraded,
    required this.ujianTotal,
    required this.subjects,
    required this.monthlyScores,
  });

  final bool hasRealData;
  final double average;
  final String category;
  final double tugasAverage;
  final double kuisAverage;
  final double ujianAverage;
  final int tugasGraded;
  final int tugasTotal;
  final int kuisGraded;
  final int kuisTotal;
  final int ujianGraded;
  final int ujianTotal;
  final List<SubjectScoreModel> subjects;
  final List<MonthlyScoreModel> monthlyScores;

  factory StudentStatisticsModel.fromJson(Map<String, dynamic> json) {
    final rawProgress = json['perkembangan_nilai'];
    final progress = rawProgress is Map<String, dynamic>
        ? rawProgress
        : rawProgress is Map
        ? Map<String, dynamic>.from(rawProgress)
        : <String, dynamic>{};
    return StudentStatisticsModel(
      hasRealData: json['has_real_data'] == true,
      average: _asDouble(json['rata_rata_semua']),
      category: (json['kategori_nilai'] ?? 'Belum Ada Data').toString(),
      tugasAverage: _asDouble(json['rata_rata_tugas']),
      kuisAverage: _asDouble(json['rata_rata_quiz']),
      ujianAverage: _asDouble(json['rata_rata_ujian']),
      tugasGraded: _asInt(json['tugas_dinilai']),
      tugasTotal: _asInt(json['tugas_total']),
      kuisGraded: _asInt(json['kuis_dinilai']),
      kuisTotal: _asInt(json['kuis_total']),
      ujianGraded: _asInt(json['ujian_dinilai']),
      ujianTotal: _asInt(json['ujian_total']),
      subjects: _asList(json['nilai_mapel'])
          .map(SubjectScoreModel.fromJson)
          .toList(),
      monthlyScores: _asList(progress['monthly_summary'])
          .map(MonthlyScoreModel.fromJson)
          .toList(),
    );
  }
}

class StudentStatisticsResponse {
  const StudentStatisticsResponse({
    required this.statistics,
    required this.periods,
    this.selectedPeriod,
  });

  final StudentStatisticsModel statistics;
  final List<AcademicPeriodModel> periods;
  final AcademicPeriodModel? selectedPeriod;

  factory StudentStatisticsResponse.fromJson(Map<String, dynamic> json) {
    final selected = json['academic_period'];
    return StudentStatisticsResponse(
      statistics: StudentStatisticsModel.fromJson(
        Map<String, dynamic>.from(json['evaluasi'] as Map? ?? const {}),
      ),
      periods: _asList(json['available_periods'])
          .map(AcademicPeriodModel.fromJson)
          .toList(),
      selectedPeriod: selected is Map
          ? AcademicPeriodModel.fromJson(Map<String, dynamic>.from(selected))
          : null,
    );
  }
}

List<Map<String, dynamic>> _asList(dynamic value) => value is List
    ? value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
    : const [];

int _asInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
double _asDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
double? _asNullableDouble(dynamic value) =>
    value == null ? null : _asDouble(value);
