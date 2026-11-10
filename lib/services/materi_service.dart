import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

import '../models/materi_page.dart';
import 'api_config.dart';
import 'storage_service.dart';

class MateriService {
  /// Mengambil daftar mata pelajaran siswa dari GET /api/siswa/materi menggunakan Dio.
  /// Jika gagal atau offline, mengembalikan list dummy `subjek` sebagai fallback.
  static Future<List<MateriModel>> fetchDaftarMapelSiswa() async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      return subjek;
    }

    try {
      final response = await ApiConfig.dio.get(
        '/siswa/materi',
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = _normalizeData(response.data);

        if (body['success'] == true && body['data'] is List) {
          final List<dynamic> rawList = body['data'] as List<dynamic>;
          if (rawList.isNotEmpty) {
            return rawList
                .whereType<Map<String, dynamic>>()
                .map(MateriModel.fromJson)
                .toList();
          }
        }
      }
    } catch (_) {
      // Fallback ke data lokal jika server offline
    }

    return subjek;
  }

  /// Mengambil daftar materi di dalam suatu mata pelajaran dari
  /// GET /api/siswa/materi/{mapelId} menggunakan Dio.
  static Future<List<MateriItemModel>> fetchMateriPerMapel(int mapelId) async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      return [];
    }

    try {
      final response = await ApiConfig.dio.get(
        '/siswa/materi/$mapelId',
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = _normalizeData(response.data);

        if (body['success'] == true &&
            body['data'] is Map<String, dynamic> &&
            body['data']['materis'] is List) {
          final List<dynamic> rawMateris =
              body['data']['materis'] as List<dynamic>;
          return rawMateris
              .whereType<Map<String, dynamic>>()
              .map(MateriItemModel.fromJson)
              .toList();
        }
      }
    } catch (_) {
      // Kembalikan list kosong agar UI bisa menampilkan fallback/empty state
    }

    return [];
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
