import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:learnpoint_mobile/core/services/storage_service.dart';

class ApiConfig {
  /// Default base URL berdasarkan platform:
  /// - Android Emulator: 10.0.2.2 merujuk ke localhost pada mesin host
  /// - iOS Simulator / Desktop / Web: 127.0.0.1 atau localhost
  /// Catatan: Jika menggunakan Device Fisik (HP asli), ubah ke IP Laptop/PC Anda
  /// (contoh: http://192.168.1.10:8000/api)
  static String? _customBaseUrl;
  static bool _isBaseUrlLoadedFromStorage = false;

  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    if (Platform.isAndroid) {
      return 'http://192.168.18.59:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  } 

  static String get baseUrl => _customBaseUrl ?? defaultBaseUrl;

  static set customBaseUrl(String? url) {
    if (url != null && url.trim().isNotEmpty) {
      // Hapus trailing slash jika ada
      _customBaseUrl = url.trim().endsWith('/')
          ? url.trim().substring(0, url.trim().length - 1)
          : url.trim();
    } else {
      _customBaseUrl = null;
    }
    _isBaseUrlLoadedFromStorage = true;
    _dio?.options.baseUrl = baseUrl;
  }

  // Endpoints
  static String get loginEndpoint => '$baseUrl/login';
  static String get logoutEndpoint => '$baseUrl/logout';
  static String get meEndpoint => '$baseUrl/me';
  static String get profileEndpoint => '$baseUrl/profile';
  static String get profilePasswordEndpoint => '$baseUrl/profile/password';

  // Endpoints Materi Siswa
  static String get siswaMateriEndpoint => '$baseUrl/siswa/materi';
  static String siswaMateriByMapelEndpoint(int mapelId) =>
      '$baseUrl/siswa/materi/$mapelId';

  // Endpoints Materi Guru
  static String get guruMateriEndpoint => '$baseUrl/guru/materi';
  static String get guruMateriOptionsEndpoint =>
      '$baseUrl/guru/materi/options';
  static String guruMateriDetailEndpoint(String idGrubMateri) =>
      '$baseUrl/guru/materi/$idGrubMateri';

  // Endpoints Gacha & Inventory Banner Siswa
  static String get siswaGachaStatusEndpoint => '$baseUrl/siswa/gacha';
  static String get siswaGachaPanduanEndpoint => '$baseUrl/siswa/gacha/panduan';
  static String get siswaGachaPullEndpoint => '$baseUrl/siswa/gacha/pull';
  static String get siswaBannerEquipEndpoint => '$baseUrl/siswa/banner/equip';

  /// Mengubah path aset publik relatif (misal: 'images/Banner/space-hero.gif')
  /// menjadi URL penuh '{BASE_URL}/{asset_path}' (tanpa '/api').
  static String publicAssetUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    final clean = path.trim();
    final apiUri = Uri.tryParse(baseUrl);

    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      final assetUri = Uri.tryParse(clean);
      if (apiUri != null && assetUri != null && apiUri.host.isNotEmpty) {
        return assetUri
            .replace(
              scheme: apiUri.scheme,
              host: apiUri.host,
              port: apiUri.hasPort ? apiUri.port : null,
            )
            .toString();
      }
      return clean;
    }

    final rootUrl = baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    final normalizedPath = clean.startsWith('/') ? clean.substring(1) : clean;
    return '$rootUrl/$normalizedPath';
  }

  static String get gachaSummonGifUrl =>
      publicAssetUrl('images/Banner/pov-astronot-mendarat.gif');

  // Standar HTTP Headers
  static Map<String, String> defaultHeaders({String? token}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Instance Dio terpusat dengan Interceptor otomatis
  static Dio? _dio;

  static Dio get dio {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: defaultHeaders(),
          responseType: ResponseType.json,
        ),
      );

      _dio!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // Pastikan customBaseUrl dari storage sudah dimuat pada request pertama
            if (!_isBaseUrlLoadedFromStorage) {
              final savedBaseUrl = await StorageService.getCustomBaseUrl();
              if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
                customBaseUrl = savedBaseUrl;
              }
              _isBaseUrlLoadedFromStorage = true;
            }

            // Sinkronkan baseUrl terbaru
            options.baseUrl = baseUrl;

            // Sisipkan token Bearer secara otomatis jika belum diset manual
            if (!options.headers.containsKey('Authorization')) {
              final token = await StorageService.getToken();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            }

            handler.next(options);
          },
        ),
      );
    }
    return _dio!;
  }
}
