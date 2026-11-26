import 'dart:convert';
import 'package:dio/dio.dart';

import 'package:learnpoint_mobile/core/config/api_config.dart';
import 'package:learnpoint_mobile/core/services/storage_service.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/quiz_level_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/quiz_per_mapel_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/quiz_question_model.dart';

class QuizApiException implements Exception {
  final String message;
  final int? statusCode;

  const QuizApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class QuizSubmitResult {
  final bool isQuizCompleted;
  final double nilai;
  final int bintang;
  final int totalSoal;
  final int jumlahBenar;
  final int jumlahSalah;
  final int durasiDetik;
  final int koinDidapat;
  final int totalKoinSiswa;
  final String message;

  const QuizSubmitResult({
    required this.isQuizCompleted,
    required this.nilai,
    required this.bintang,
    required this.totalSoal,
    required this.jumlahBenar,
    required this.jumlahSalah,
    required this.durasiDetik,
    required this.koinDidapat,
    required this.totalKoinSiswa,
    required this.message,
  });

  factory QuizSubmitResult.fromJson(
    Map<String, dynamic> data, {
    String message = 'Kuis berhasil diselesaikan!',
  }) {
    return QuizSubmitResult(
      isQuizCompleted:
          data['is_quiz_completed'] == true || data['is_quiz_completed'] == 1,
      nilai: double.tryParse((data['nilai'] ?? 0).toString()) ?? 0.0,
      bintang: int.tryParse((data['bintang'] ?? 1).toString()) ?? 1,
      totalSoal: int.tryParse((data['total_soal'] ?? 0).toString()) ?? 0,
      jumlahBenar: int.tryParse((data['jumlah_benar'] ?? 0).toString()) ?? 0,
      jumlahSalah: int.tryParse((data['jumlah_salah'] ?? 0).toString()) ?? 0,
      durasiDetik: int.tryParse((data['durasi_detik'] ?? 0).toString()) ?? 0,
      koinDidapat: int.tryParse((data['koin_didapat'] ?? 0).toString()) ?? 0,
      totalKoinSiswa:
          int.tryParse((data['total_koin_siswa'] ?? 0).toString()) ?? 0,
      message: message,
    );
  }
}

class QuizPowerItemModel {
  final int id;
  final String kode;
  final String nama;
  final String deskripsi;
  final String detailEfek;
  final String tipeEfek;
  final bool isActive;
  final int jumlah;

  const QuizPowerItemModel({
    required this.id,
    required this.kode,
    required this.nama,
    required this.deskripsi,
    required this.detailEfek,
    required this.tipeEfek,
    required this.isActive,
    required this.jumlah,
  });

  factory QuizPowerItemModel.fromJson(Map<String, dynamic> json) {
    return QuizPowerItemModel(
      id: int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      kode: (json['kode'] ?? json['code'] ?? '').toString(),
      nama: (json['nama'] ?? json['name'] ?? 'Power').toString(),
      deskripsi: (json['deskripsi'] ?? json['description'] ?? '').toString(),
      detailEfek: (json['detail_efek'] ?? json['effectDetail'] ?? '').toString(),
      tipeEfek: (json['tipe_efek'] ?? json['type'] ?? '').toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      jumlah: int.tryParse((json['jumlah'] ?? json['qty'] ?? 0).toString()) ?? 0,
    );
  }
}

class QuizApiService {
  const QuizApiService._();

  /// GET /api/siswa/kuis?mapel_id={mapelId}
  /// Mengambil daftar kuis terpublikasi untuk kelas siswa (opsional filter per mapel).
  static Future<List<QuizPerMapelM>> fetchQuizzes({int? mapelId}) async {
    final queryParams = <String, dynamic>{};
    if (mapelId != null) {
      queryParams['mapel_id'] = mapelId;
    }

    final body = await _get('/siswa/kuis', queryParameters: queryParams);
    final rawData = body['data'];

    List<dynamic> list = const [];
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map<String, dynamic> && rawData['quizzes'] is List) {
      list = rawData['quizzes'] as List;
    }

    final results = <QuizPerMapelM>[];
    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      if (item is Map<String, dynamic>) {
        results.add(QuizPerMapelM.fromJson(item, fallbackIndex: i));
      }
    }
    return results;
  }

  /// GET /api/siswa/kuis/{quizId}
  /// Mengambil data peta level untuk setiap tingkat kesulitan (Mudah, Sedang, Sulit),
  /// di mana setiap tingkat kesulitan dipastikan berisi 5 level (Level 1 s/d Level 5).
  /// Level yang belum diinput soal oleh guru otomatis diisi dengan `QuizLevelNodeModel.lockedEmpty` (terkunci).
  static Future<QuizAdventureMapData> fetchQuizAdventureMap(int quizId) async {
    final body = await _get('/siswa/kuis/$quizId');
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const QuizApiException('Format detail kuis tidak valid.');
    }

    final rawActiveDiffs = data['kesulitan_aktif'];
    final activeDifficulties = <String>[];
    if (rawActiveDiffs is List) {
      for (final d in rawActiveDiffs) {
        final norm = _normalizeDifficulty(d.toString());
        if (!activeDifficulties.contains(norm)) {
          activeDifficulties.add(norm);
        }
      }
    }
    if (activeDifficulties.isEmpty) {
      activeDifficulties.addAll(QuizAdventureMapData.allDifficulties);
    }

    final adventure = data['adventure'] is Map<String, dynamic>
        ? data['adventure'] as Map<String, dynamic>
        : null;

    final currentArc = _normalizeDifficulty(
      (adventure?['current_arc'] ?? activeDifficulties.first).toString(),
    );

    // Kumpulkan semua level yang sudah dibuat guru dari `adventure.levels`
    final parsedNodes = <QuizLevelNodeModel>[];
    if (adventure != null && adventure['levels'] is List) {
      final rawLevels = adventure['levels'] as List;
      parsedNodes.addAll(
        rawLevels
            .whereType<Map<String, dynamic>>()
            .map(QuizLevelNodeModel.fromAdventureJson),
      );
    } else if (data['levels'] is List) {
      final rawLevels = data['levels'] as List;
      parsedNodes.addAll(
        rawLevels
            .whereType<Map<String, dynamic>>()
            .map((e) => QuizLevelNodeModel.fromSimpleLevelJson(e, arc: currentArc)),
      );
    }

    // Untuk setiap difficulty (Mudah, Sedang, Sulit), susun tepat 5 level (Level 1..5).
    // Jika suatu nomor level (1..5) pada difficulty tersebut tidak ada di `parsedNodes` (belum diinput guru),
    // buat node terkunci (`QuizLevelNodeModel.lockedEmpty`).
    final levelsByDiff = <String, List<QuizLevelNodeModel>>{};
    for (final diff in QuizAdventureMapData.allDifficulties) {
      final list5 = <QuizLevelNodeModel>[];
      for (int lvl = 1; lvl <= 5; lvl++) {
        QuizLevelNodeModel? existing;
        for (final node in parsedNodes) {
          final nodeArc = _normalizeDifficulty(node.arc ?? 'Mudah');
          if (nodeArc == diff && node.arcLevelNum == lvl) {
            existing = node;
            break;
          }
        }
        list5.add(
          existing ??
              QuizLevelNodeModel.lockedEmpty(
                arc: diff,
                levelNum: lvl,
              ),
        );
      }
      levelsByDiff[diff] = list5;
    }

    return QuizAdventureMapData(
      activeDifficulties: activeDifficulties,
      currentDifficulty: activeDifficulties.contains(currentArc)
          ? currentArc
          : activeDifficulties.first,
      levelsByDifficulty: levelsByDiff,
    );
  }

  static String _normalizeDifficulty(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower == 'sedang') return 'Sedang';
    if (lower == 'sulit') return 'Sulit';
    return 'Mudah';
  }

  /// GET /api/siswa/kuis/{quizId}/kerjakan
  /// Mengambil daftar butir soal untuk level & arc yang sedang dikerjakan.
  static Future<List<QuizPlayQuestionModel>> fetchQuestionsForLevel({
    required int quizId,
    String? arc,
    int? levelNum,
    int? step,
  }) async {
    final queryParams = <String, dynamic>{};
    if (arc != null && arc.isNotEmpty) queryParams['arc'] = arc;
    if (levelNum != null && levelNum > 0) queryParams['level'] = levelNum;
    if (step != null && step > 0) queryParams['step'] = step;

    final body = await _get(
      '/siswa/kuis/$quizId/kerjakan',
      queryParameters: queryParams,
    );
    final data = body['data'];
    if (data is! Map<String, dynamic> || data['soals'] is! List) {
      throw const QuizApiException('Format daftar soal kuis tidak valid.');
    }

    final rawSoals = data['soals'] as List;
    final questions = <QuizPlayQuestionModel>[];
    for (int i = 0; i < rawSoals.length; i++) {
      final item = rawSoals[i];
      if (item is Map<String, dynamic>) {
        questions.add(QuizPlayQuestionModel.fromApiJson(item, index: i));
      }
    }
    return questions;
  }

  /// POST /api/siswa/kuis/{quizId}/simpan-draft
  /// Menyimpan progres jawaban sementara ke tabel `menjawabs`.
  static Future<void> saveDraft({
    required int quizId,
    required Map<String, String> jawaban,
  }) async {
    await _post(
      '/siswa/kuis/$quizId/simpan-draft',
      data: {'jawaban': jawaban},
    );
  }

  /// POST /api/siswa/kuis/{quizId}/submit
  /// Mengumpulkan jawaban level / kuis dan mendapatkan hasil koreksi, bintang, & koin.
  static Future<QuizSubmitResult> submitQuizLevel({
    required int quizId,
    required Map<String, String> jawaban,
    required int durasiDetik,
    String? arc,
    int? levelNum,
    int? step,
  }) async {
    final payload = <String, dynamic>{
      'jawaban': jawaban,
      'durasi': durasiDetik,
      if (arc != null && arc.isNotEmpty) 'arc': arc,
      if (levelNum != null && levelNum > 0) 'level': levelNum,
      if (step != null && step > 0) 'step': step,
    };

    final body = await _post('/siswa/kuis/$quizId/submit', data: payload);
    final data = body['data'];
    final msg = (body['message'] ?? 'Level berhasil diselesaikan!').toString();

    if (data is Map<String, dynamic>) {
      return QuizSubmitResult.fromJson(data, message: msg);
    }
    throw QuizApiException(msg);
  }

  /// GET /api/siswa/kuis/{quizId}/powers
  /// Mengambil inventori Power siswa untuk kuis ini beserta status efek per soal.
  static Future<({
    List<QuizPowerItemModel> powers,
    Map<int, Map<String, dynamic>> questionStates,
  })> fetchQuizPowers(int quizId) async {
    final body = await _get('/siswa/kuis/$quizId/powers');
    final data = body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : body;

    final rawPowers = data['powers'] is List ? data['powers'] as List : const [];
    final powers = rawPowers
        .whereType<Map<String, dynamic>>()
        .map(QuizPowerItemModel.fromJson)
        .toList();

    final states = <int, Map<String, dynamic>>{};
    final rawStates = data['question_states'];
    if (rawStates is Map) {
      for (final entry in rawStates.entries) {
        final soalId = int.tryParse(entry.key.toString());
        if (soalId != null && entry.value is Map) {
          states[soalId] = Map<String, dynamic>.from(entry.value as Map);
        }
      }
    }

    return (powers: powers, questionStates: states);
  }

  /// POST /api/siswa/kuis/{quizId}/powers/use
  /// Mengaktifkan 1 Power pada 1 butir soal (`soal_id`, `kode`).
  static Future<Map<String, dynamic>> usePower({
    required int quizId,
    required int soalId,
    required String powerKode,
  }) async {
    final body = await _post(
      '/siswa/kuis/$quizId/powers/use',
      data: {
        'soal_id': soalId,
        'kode': powerKode,
      },
    );
    if (body['effect'] is Map<String, dynamic>) {
      return body['effect'] as Map<String, dynamic>;
    }
    final data = body['data'];
    if (data is Map<String, dynamic> && data['effect'] is Map<String, dynamic>) {
      return data['effect'] as Map<String, dynamic>;
    }
    return body;
  }

  static Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    await _ensureToken();
    try {
      final response = await ApiConfig.dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(receiveTimeout: const Duration(seconds: 12)),
      );
      final body = _normalizeData(response.data);
      if (body['success'] != true) {
        throw QuizApiException(
          (body['message'] ?? 'Gagal memuat data kuis.').toString(),
          statusCode: response.statusCode,
        );
      }
      return body;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  static Future<Map<String, dynamic>> _post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    await _ensureToken();
    try {
      final response = await ApiConfig.dio.post(
        path,
        data: data,
        options: Options(receiveTimeout: const Duration(seconds: 15)),
      );
      final body = _normalizeData(response.data);
      if (body['success'] != true) {
        throw QuizApiException(
          (body['message'] ?? 'Gagal memproses permintaan kuis.').toString(),
          statusCode: response.statusCode,
        );
      }
      return body;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  static Future<void> _ensureToken() async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      throw const QuizApiException(
        'Sesi login tidak ditemukan. Silakan login kembali.',
        statusCode: 401,
      );
    }
  }

  static QuizApiException _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final body = _normalizeData(e.response?.data);
    final serverMessage = body['message']?.toString();

    if (serverMessage != null && serverMessage.isNotEmpty) {
      return QuizApiException(serverMessage, statusCode: statusCode);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const QuizApiException(
          'Server tidak merespons. Periksa koneksi internet Anda.',
        );
      case DioExceptionType.connectionError:
        return QuizApiException(
          'Tidak dapat terhubung ke server (${ApiConfig.baseUrl}).',
        );
      default:
        return QuizApiException(
          'Terjadi kesalahan saat menghubungi server ($statusCode).',
          statusCode: statusCode,
        );
    }
  }

  static Map<String, dynamic> _normalizeData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {
        return {};
      }
    }
    return {};
  }
}
