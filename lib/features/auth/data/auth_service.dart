import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

import 'package:learnpoint_mobile/shared/models/user_model.dart';
import 'package:learnpoint_mobile/core/config/api_config.dart';
import 'package:learnpoint_mobile/core/services/storage_service.dart';

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
  /// Melakukan login ke API Laravel (/api/login) menggunakan Dio
  static Future<AuthResult> login({
    required String login,
    required String password,
    String? deviceName,
  }) async {
    try {
      final response = await ApiConfig.dio.post(
        '/login',
        data: {
          'login': login.trim(),
          'password': password,
          'device_name': deviceName ?? 'LearnPoint Mobile',
        },
      );

      final Map<String, dynamic> responseData = _normalizeData(response.data);

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
      }

      return AuthResult(
        success: false,
        message: responseData['message']?.toString() ??
            'Terjadi kesalahan (Kode: ${response.statusCode}).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return AuthResult(
          success: false,
          message: 'Koneksi ke server timeout (waktu habis). Cek koneksi Anda.',
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        return AuthResult(
          success: false,
          message:
              'Tidak dapat terhubung ke server.\nPastikan backend Laravel berjalan di:\n${ApiConfig.baseUrl}',
        );
      }

      final statusCode = e.response?.statusCode;
      final Map<String, dynamic> responseData =
          _normalizeData(e.response?.data);

      if (statusCode == 422) {
        // Validasi input gagal dari Laravel
        String errorMsg =
            responseData['message']?.toString() ?? 'Validasi input gagal.';
        if (responseData['errors'] is Map<String, dynamic>) {
          final errorsMap = responseData['errors'] as Map<String, dynamic>;
          if (errorsMap.isNotEmpty) {
            final firstError = errorsMap.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMsg = firstError.first.toString();
            }
          }
        }
        return AuthResult(
          success: false,
          message: errorMsg,
          errors: responseData['errors'] is Map<String, dynamic>
              ? responseData['errors'] as Map<String, dynamic>
              : null,
        );
      } else if (statusCode == 401 || statusCode == 403) {
        // Kredensial salah atau akun dinonaktifkan
        final msg = responseData['message']?.toString() ??
            'Username/password salah atau akun tidak memiliki akses.';
        return AuthResult(
          success: false,
          message: msg,
        );
      } else if (statusCode != null) {
        return AuthResult(
          success: false,
          message: responseData['message']?.toString() ??
              'Terjadi kesalahan (Kode: $statusCode).',
        );
      }

      return AuthResult(
        success: false,
        message:
            'Tidak dapat terhubung ke server.\nPastikan backend Laravel berjalan di:\n${ApiConfig.baseUrl}',
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

  /// Mengambil profil user terbaru dari server (/api/me) menggunakan Dio
  static Future<UserModel?> fetchCurrentUser() async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final response = await ApiConfig.dio.get(
        '/me',
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = _normalizeData(response.data);
        final data = responseData['data'];
        if (data is Map<String, dynamic> && data['user'] is Map<String, dynamic>) {
          final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
          await StorageService.saveUser(user);
          return user;
        }
      }
    } catch (_) {
      // Jika offline atau gagal, fallback ke user di storage
    }
    return await StorageService.getUser();
  }

  /// Melakukan logout dan mencabut token di server (/api/logout) menggunakan Dio
  static Future<void> logout() async {
    final token = await StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await ApiConfig.dio.post(
          '/logout',
          options: Options(
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
      } catch (_) {
        // Abaikan error jaringan saat logout, yang penting storage lokal dihapus
      }
    }
    await StorageService.clearAuth();
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
