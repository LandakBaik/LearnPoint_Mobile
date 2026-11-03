import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  /// Default base URL berdasarkan platform:
  /// - Android Emulator: 10.0.2.2 merujuk ke localhost pada mesin host
  /// - iOS Simulator / Desktop / Web: 127.0.0.1 atau localhost
  /// Catatan: Jika menggunakan Device Fisik (HP asli), ubah ke IP Laptop/PC Anda
  /// (contoh: http://192.168.1.10:8000/api)
  static String? _customBaseUrl;

  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.5.1:8000/api';
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
  }

  // Endpoints
  static String get loginEndpoint => '$baseUrl/login';
  static String get logoutEndpoint => '$baseUrl/logout';
  static String get meEndpoint => '$baseUrl/me';
  static String get profileEndpoint => '$baseUrl/profile';

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
}

