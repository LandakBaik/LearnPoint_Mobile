import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import 'api_config.dart';
import 'storage_service.dart';

class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;
  final String? token;
  final Map<String, dynamic>? errors;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
    this.token,
    this.errors,
  });
}

class AuthService {
  /// Melakukan login ke API Laravel (/api/login)
  static Future<AuthResult> login({
    required String login,
    required String password,
    String? deviceName,
  }) async {
    // Muat custom base URL jika pernah disimpan sebelumnya
    final savedBaseUrl = await StorageService.getCustomBaseUrl();
    if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
      ApiConfig.customBaseUrl = savedBaseUrl;
    }

    final url = Uri.parse(ApiConfig.loginEndpoint);

    try {
      final response = await http
          .post(
            url,
            headers: ApiConfig.defaultHeaders(),
            body: jsonEncode({
              'login': login.trim(),
              'password': password,
              'device_name': deviceName ?? 'LearnPoint Mobile',
            }),
          )
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData = _decodeResponse(response.body);

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(responseData);

        if (authResponse.token != null && authResponse.user != null) {
          // Simpan token & user ke Secure Storage
          await StorageService.saveToken(authResponse.token!);
          await StorageService.saveUser(authResponse.user!);

          return AuthResult(
            success: true,
            message: authResponse.message.isNotEmpty
                ? authResponse.message
                : 'Login berhasil.',
            user: authResponse.user,
            token: authResponse.token,
          );
        } else {
          return AuthResult(
            success: false,
            message: 'Format data respon login tidak sesuai.',
          );
        }
      } else if (response.statusCode == 422) {
        // Validasi input gagal dari Laravel
        String errorMsg = responseData['message'] ?? 'Validasi input gagal.';
        if (responseData['errors'] is Map<String, dynamic>) {
          final errorsMap = responseData['errors'] as Map<String, dynamic>;
          final firstError = errorsMap.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMsg = firstError.first.toString();
          }
        }
        return AuthResult(
          success: false,
          message: errorMsg,
          errors: responseData['errors'] is Map<String, dynamic>
              ? responseData['errors']
              : null,
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Kredensial salah atau akun dinonaktifkan
        final msg = responseData['message'] ??
            'Username/password salah atau akun tidak memiliki akses.';
        return AuthResult(
          success: false,
          message: msg,
        );
      } else {
        return AuthResult(
          success: false,
          message: responseData['message'] ??
              'Terjadi kesalahan (Kode: ${response.statusCode}).',
        );
      }
    } on SocketException catch (_) {
      return AuthResult(
        success: false,
        message:
            'Tidak dapat terhubung ke server.\nPastikan backend Laravel berjalan di:\n${ApiConfig.baseUrl}',
      );
    } on TimeoutException catch (_) {
      return AuthResult(
        success: false,
        message: 'Koneksi ke server timeout (waktu habis). Cek koneksi Anda.',
      );
    } on FormatException catch (_) {
      return AuthResult(
        success: false,
        message: 'Format balasan server bukan JSON yang valid.',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Gagal melakukan login: ${e.toString()}',
      );
    }
  }

  /// Mengambil profil user terbaru dari server (/api/me)
  static Future<UserModel?> fetchCurrentUser() async {
    final token = await StorageService.getToken();
    if (token == null) return null;

    try {
      final url = Uri.parse(ApiConfig.meEndpoint);
      final response = await http
          .get(url, headers: ApiConfig.defaultHeaders(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = _decodeResponse(response.body);
        if (responseData['data'] != null &&
            responseData['data']['user'] != null) {
          final user = UserModel.fromJson(responseData['data']['user']);
          await StorageService.saveUser(user);
          return user;
        }
      }
    } catch (_) {
      // Jika offline, fallback ke user di storage
    }
    return await StorageService.getUser();
  }

  /// Melakukan logout dan mencabut token di server (/api/logout)
  static Future<void> logout() async {
    final token = await StorageService.getToken();
    if (token != null) {
      try {
        final url = Uri.parse(ApiConfig.logoutEndpoint);
        await http
            .post(url, headers: ApiConfig.defaultHeaders(token: token))
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        // Abaikan error jaringan saat logout, yang penting storage lokal dihapus
      }
    }
    await StorageService.clearAuth();
  }

  static Map<String, dynamic> _decodeResponse(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}

