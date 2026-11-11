import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/core/config/api_config.dart';
import 'package:learnpoint_mobile/core/services/storage_service.dart';

/// Error yang terjadi saat mengambil data materi dari API Laravel.
/// [message] sudah dalam bahasa yang ramah untuk ditampilkan ke siswa.
class MateriException implements Exception {
  final String message;
  final int? statusCode;

  /// true jika token tidak valid / kadaluarsa (HTTP 401) sehingga perlu login ulang.
  bool get isUnauthorized => statusCode == 401;

  const MateriException(this.message, {this.statusCode});

  @override
  String toString() => 'MateriException($statusCode): $message';
}

class MateriService {
  /// Mengambil daftar mata pelajaran siswa dari GET /api/siswa/materi.
  /// Melempar [MateriException] jika gagal (tidak ada lagi fallback data dummy).
  static Future<List<MateriModel>> fetchDaftarMapelSiswa() async {
    final body = await _get('/siswa/materi');
    final data = body['data'];

    if (data is! List) {
      throw const MateriException(
        'Format data mata pelajaran dari server tidak valid.',
      );
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(MateriModel.fromJson)
        .toList();
  }

  /// Mengambil identitas mapel (nama_mapel, nama_kelas, semester, tahun_ajaran)
  /// beserta daftar materi dari GET /api/siswa/materi/{mapelId}.
  /// Melempar [MateriException] jika gagal.
  static Future<MapelDetailModel> fetchDetailMapelSiswa(int mapelId) async {
    final body = await _get('/siswa/materi/$mapelId');
    final data = body['data'];

    if (data is! Map<String, dynamic> || data['materis'] is! List) {
      throw const MateriException(
        'Format data materi dari server tidak valid.',
      );
    }

    return MapelDetailModel.fromJson(data);
  }

  /// Mengambil daftar materi di dalam suatu mata pelajaran dari
  /// GET /api/siswa/materi/{mapelId}.
  static Future<List<MateriItemModel>> fetchMateriPerMapel(int mapelId) async {
    final detail = await fetchDetailMapelSiswa(mapelId);
    return detail.materis;
  }

  /// GET terpusat: validasi token, panggil API, cek `success`, dan
  /// terjemahkan semua kegagalan menjadi [MateriException].
  static Future<Map<String, dynamic>> _get(String path) async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      throw const MateriException(
        'Sesi login tidak ditemukan. Silakan login kembali.',
        statusCode: 401,
      );
    }

    try {
      final response = await ApiConfig.dio.get(
        path,
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );

      final body = _normalizeData(response.data);
      if (body['success'] != true) {
        throw MateriException(
          (body['message'] ?? 'Gagal memuat data materi.').toString(),
          statusCode: response.statusCode,
        );
      }
      return body;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  static MateriException _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final serverMessage = _normalizeData(
      e.response?.data,
    )['message']?.toString();

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const MateriException(
          'Server tidak merespons. Periksa koneksi internet / server Laravel.',
        );
      case DioExceptionType.connectionError:
        return MateriException(
          'Tidak dapat terhubung ke server (${ApiConfig.baseUrl}). '
          'Pastikan server Laravel berjalan dan alamat IP sudah benar.',
        );
      case DioExceptionType.badResponse:
        if (statusCode == 401) {
          return const MateriException(
            'Sesi login telah berakhir. Silakan login kembali.',
            statusCode: 401,
          );
        }
        if (statusCode == 403) {
          return MateriException(
            serverMessage ?? 'Akun Anda tidak memiliki akses ke materi siswa.',
            statusCode: 403,
          );
        }
        if (statusCode == 404) {
          return MateriException(
            serverMessage ?? 'Data materi tidak ditemukan.',
            statusCode: 404,
          );
        }
        return MateriException(
          serverMessage ?? 'Terjadi kesalahan pada server ($statusCode).',
          statusCode: statusCode,
        );
      default:
        return MateriException(
          serverMessage ?? 'Gagal memuat data materi. Silakan coba lagi.',
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
