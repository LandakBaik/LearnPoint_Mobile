import 'package:dio/dio.dart';
import 'package:learnpoint_mobile/core/config/api_config.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/models/ujian_model.dart';

typedef JsonMap = Map<String, dynamic>;

class UjianApiService {
  /// 1. Ambil daftar semua ujian siswa
  static Future<List<UjianItem>> getUjians() async {
    try {
      final response = await ApiConfig.dio.get('/siswa/ujian');
      final payload = _getPayload(response.data);

      if (payload is! List) {
        throw Exception('Format daftar ujian dari server tidak sesuai.');
      }

      return payload
          .where((item) => item is Map)
          .map((item) => UjianItem.fromJson(JsonMap.from(item as Map)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// 1b. Ambil daftar ujian siswa khusus untuk satu mata pelajaran
  static Future<List<UjianItem>> getUjiansByMapel(int mapelId) async {
    try {
      final response = await ApiConfig.dio.get('/siswa/materi/$mapelId');
      final payload = _getPayload(response.data);

      if (payload is! Map) {
        throw Exception('Format data ujian mapel tidak sesuai.');
      }

      final mapelInfo = payload['mapel'] is Map
          ? JsonMap.from(payload['mapel'] as Map)
          : <String, dynamic>{};
      final rawUjians = payload['ujians'];

      if (rawUjians is! List) {
        return [];
      }

      return rawUjians.where((item) => item is Map).map((item) {
        final data = JsonMap.from(item as Map);
        data['mapel'] ??= mapelInfo['nama_mapel'];
        data['kelas'] ??= mapelInfo['nama_kelas'];
        data['nilai_siswa'] ??= data['nilai'];
        return UjianItem.fromJson(data);
      }).toList();
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// 2. Ambil detail & kisi-kisi satu ujian
  static Future<UjianDetail> getUjianDetail(int ujianId) async {
    try {
      final response = await ApiConfig.dio.get('/siswa/ujian/$ujianId');
      final payload = _getPayload(response.data);

      if (payload is! Map) {
        throw Exception('Format detail ujian tidak sesuai.');
      }

      return UjianDetail.fromJson(JsonMap.from(payload));
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// 3. Validasi token sesi sebelum masuk ke ruang ujian
  static Future<JsonMap> validasiToken({
    required int ujianId,
    required String token,
  }) async {
    try {
      final response = await ApiConfig.dio.post(
        '/siswa/ujian/$ujianId/validasi-token',
        data: {'token': token.trim().toUpperCase()},
      );
      final payload = _getPayload(response.data);
      return payload is Map ? JsonMap.from(payload) : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// 4. Ambil soal ujian aktif, sisa waktu, dan jawaban tersimpan
  static Future<UjianKerjakanData> getLembarKerjakan(int ujianId) async {
    try {
      final response = await ApiConfig.dio.get('/siswa/ujian/$ujianId/kerjakan');
      final payload = _getPayload(response.data);

      if (payload is! Map) {
        throw Exception('Gagal memuat lembar soal ujian.');
      }

      return UjianKerjakanData.fromJson(JsonMap.from(payload));
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// 5. Auto-save jawaban satu soal (PG tunggal, PG kompleks, atau Essay)
  static Future<void> simpanJawaban({
    required int ujianId,
    required int soalId,
    required dynamic jawaban,
  }) async {
    try {
      await ApiConfig.dio.post(
        '/siswa/ujian/$ujianId/simpan-jawaban',
        data: {
          'soal_id': soalId,
          'jawaban': jawaban,
        },
      );
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// 6. Heartbeat cek status sesi (ditarik guru / selesai paksa / terkunci / timeout)
  static Future<JsonMap> cekStatusSesi(int ujianId) async {
    try {
      final response = await ApiConfig.dio.get('/siswa/ujian/$ujianId/status-sesi');
      final payload = _getPayload(response.data);
      return payload is Map ? JsonMap.from(payload) : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// 7. Catat pelanggaran (keluar aplikasi / split screen / pindah layar)
  static Future<JsonMap> catatPelanggaran({
    required int ujianId,
    String alasan = 'Keluar dari aplikasi saat ujian berlangsung',
  }) async {
    try {
      final response = await ApiConfig.dio.post(
        '/siswa/ujian/$ujianId/pelanggaran',
        data: {'alasan': alasan},
      );
      final payload = _getPayload(response.data);
      return payload is Map ? JsonMap.from(payload) : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// 8. Buka kunci sesi yang terblokir memakai Kode Buka Blokir dari pengawas
  static Future<JsonMap> bukaKunciDenganKode({
    required int ujianId,
    required String kode,
  }) async {
    try {
      final response = await ApiConfig.dio.post(
        '/siswa/ujian/$ujianId/buka-kunci-kode',
        data: {'kode': kode.trim().toUpperCase()},
      );
      final payload = _getPayload(response.data);
      return payload is Map ? JsonMap.from(payload) : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// 9. Submit final seluruh jawaban ujian
  static Future<JsonMap> submitUjian({
    required int ujianId,
    JsonMap? jawabanBatch,
  }) async {
    try {
      final response = await ApiConfig.dio.post(
        '/siswa/ujian/$ujianId/submit',
        data: jawabanBatch != null ? {'jawaban': jawabanBatch} : <String, dynamic>{},
      );
      final payload = _getPayload(response.data);
      return payload is Map ? JsonMap.from(payload) : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// 10. Ambil hasil & ringkasan nilai ujian siswa
  static Future<UjianHasilData> getHasilUjian(int ujianId) async {
    try {
      final response = await ApiConfig.dio.get('/siswa/ujian/$ujianId/hasil');
      final payload = _getPayload(response.data);

      if (payload is! Map) {
        throw Exception('Format hasil ujian tidak sesuai.');
      }

      return UjianHasilData.fromJson(JsonMap.from(payload));
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  static dynamic _getPayload(dynamic responseData) {
    if (responseData is Map) {
      return responseData['data'] ?? responseData;
    }
    return responseData;
  }

  static String _getErrorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map) {
      final message = data['message'];
      if (message != null && message.toString().isNotEmpty) {
        return message.toString();
      }
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }
    }

    if (e.response?.statusCode == 401) {
      return 'Sesi login berakhir. Silakan login kembali.';
    }
    if (e.response?.statusCode == 403) {
      return 'Anda tidak memiliki akses ke ujian ini.';
    }

    return e.message ?? 'Terjadi kesalahan saat menghubungi server.';
  }
}