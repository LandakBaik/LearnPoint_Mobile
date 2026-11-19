import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:learnpoint_mobile/core/config/api_config.dart';

class TaskApiService {
  /// Mengambil seluruh tugas milik siswa yang sedang login.
  static Future<List<Map<String, dynamic>>> getTasks() async {
    try {
      final response = await ApiConfig.dio.get('/siswa/tugas');

      final payload = _getPayload(response.data);

      dynamic listData = payload;

      if (payload is Map) {
        listData =
            payload['tugas'] ??
            payload['daftar_tugas'] ??
            payload['items'] ??
            payload['data'];
      }

      if (listData is! List) {
        throw Exception('Format daftar tugas dari server tidak sesuai.');
      }

      return listData
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Mengambil detail satu tugas berdasarkan ID.
  static Future<Map<String, dynamic>> getTaskDetail(String id) async {
    try {
      final response = await ApiConfig.dio.get('/siswa/tugas/$id');

      final payload = _getPayload(response.data);

      if (payload is Map) {
        final tugas = payload['tugas'];

        if (tugas is Map) {
          return Map<String, dynamic>.from(tugas);
        }

        return Map<String, dynamic>.from(payload);
      }

      throw Exception('Format detail tugas dari server tidak sesuai.');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Mengirim file jawaban ke Laravel.
  static Future<Map<String, dynamic>> submitTask({
    required String id,
    required PlatformFile file,
  }) async {
    try {
      // Membaca isi file.
      final fileBytes = await file.readAsBytes();

      // Membuat multipart form data.
      final formData = FormData.fromMap({
        'file_jawaban': MultipartFile.fromBytes(fileBytes, filename: file.name),
      });

      // Mengirim file ke Laravel API.
      final response = await ApiConfig.dio.post(
        '/siswa/tugas/$id/kumpulkan',
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {'Accept': 'application/json'},
        ),
      );

      final payload = _getPayload(response.data);

      if (payload is Map) {
        return Map<String, dynamic>.from(payload);
      }

      return {};
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Mengambil isi data dari response successResponse Laravel.
  static dynamic _getPayload(dynamic responseData) {
    if (responseData is Map) {
      return responseData['data'] ?? responseData;
    }

    return responseData;
  }

  /// Mengambil pesan error dari Laravel atau Dio.
  static String _getErrorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map) {
      final message = data['message'];

      if (message != null) {
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
      return 'Akun tidak memiliki akses ke tugas ini.';
    }

    return e.message ?? 'Terjadi kesalahan saat menghubungi server.';
  }

  /// Mengambil detail tugas beserta soal pilihan ganda.
  static Future<Map<String, dynamic>> getPilganDetail(String id) async {
    try {
      final response = await ApiConfig.dio.get('/siswa/tugas/$id');

      final payload = _getPayload(response.data);

      if (payload is Map) {
        final tugas = payload['tugas'];

        if (tugas is Map) {
          return Map<String, dynamic>.from(tugas);
        }

        return Map<String, dynamic>.from(payload);
      }

      throw Exception('Format detail tugas tidak sesuai.');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Mengirim jawaban pilihan ganda.
  static Future<Map<String, dynamic>> submitPilgan({
    required String id,
    required Map<String, String> answers,
  }) async {
    try {
      final response = await ApiConfig.dio.post(
        '/siswa/tugas/$id/kumpulkan',
        data: {'jawaban': answers},
        options: Options(headers: {'Accept': 'application/json'}),
      );

      final payload = _getPayload(response.data);

      if (payload is Map) {
        return Map<String, dynamic>.from(payload);
      }

      return {};
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }
}
