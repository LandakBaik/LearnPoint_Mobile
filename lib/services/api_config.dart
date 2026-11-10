import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'storage_service.dart';

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
      return 'http://10.10.5.92:8000/api';
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
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
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
