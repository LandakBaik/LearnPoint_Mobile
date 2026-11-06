import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/materi_page.dart';
import 'api_config.dart';
import 'storage_service.dart';

class MateriService {
  /// Memuat custom base URL jika pernah diatur oleh pengguna
  static Future<void> _ensureBaseUrlLoaded() async {
    final savedBaseUrl = await StorageService.getCustomBaseUrl();
    if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
      ApiConfig.customBaseUrl = savedBaseUrl;
    }
  }

  /// Mengambil daftar mata pelajaran siswa dari GET /api/siswa/materi
  /// Jika gagal atau offline, mengembalikan list dummy `subjek` sebagai fallback.
  static Future<List<MateriModel>> fetchDaftarMapelSiswa() async {
    await _ensureBaseUrlLoaded();
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      return subjek;
    }

    try {
      final url = Uri.parse(ApiConfig.siswaMateriEndpoint);
      final response = await http
          .get(url, headers: ApiConfig.defaultHeaders(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;

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
  /// GET /api/siswa/materi/{mapelId}
  static Future<List<MateriItemModel>> fetchMateriPerMapel(int mapelId) async {
    await _ensureBaseUrlLoaded();
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      return [];
    }

    try {
      final url = Uri.parse(ApiConfig.siswaMateriByMapelEndpoint(mapelId));
      final response = await http
          .get(url, headers: ApiConfig.defaultHeaders(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;

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
}
