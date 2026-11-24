import 'dart:convert';
import 'package:dio/dio.dart';

import 'package:learnpoint_mobile/core/config/api_config.dart';
import 'package:learnpoint_mobile/core/services/storage_service.dart';
import 'package:learnpoint_mobile/features/siswa/profile/models/student_profile_model.dart';

class ProfileException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  bool get isUnauthorized => statusCode == 401;

  const ProfileException(
    this.message, {
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => 'ProfileException($statusCode): $message';
}

class ProfileService {
  static Future<StudentProfileModel>? _inFlightFetch;

  /// Membaca cache profil lokal dari storage jika tersedia.
  static Future<StudentProfileModel?> loadCachedProfile() async {
    final cachedJson = await StorageService.getProfileJson();
    if (cachedJson != null) {
      return StudentProfileModel.fromProfileApi(cachedJson);
    }

    final cachedUser = await StorageService.getUser();
    if (cachedUser != null) {
      return StudentProfileModel.fromUserModel(cachedUser);
    }

    return null;
  }

  /// Mengambil data profil lengkap pengguna yang sedang login dari `GET /api/profile`.
  static Future<StudentProfileModel> fetchProfile() async {
    if (_inFlightFetch != null) {
      return _inFlightFetch!;
    }

    final future = _performFetchProfile();
    _inFlightFetch = future;
    try {
      return await future;
    } finally {
      _inFlightFetch = null;
    }
  }

  static Future<StudentProfileModel> _performFetchProfile() async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      throw const ProfileException(
        'Sesi login tidak ditemukan. Silakan login kembali.',
        statusCode: 401,
      );
    }

    try {
      final response = await ApiConfig.dio.get(
        '/profile',
        options: Options(receiveTimeout: const Duration(seconds: 12)),
      );

      final body = _normalizeData(response.data);
      if (body['success'] != true) {
        throw ProfileException(
          (body['message'] ?? 'Gagal memuat data profil.').toString(),
          statusCode: response.statusCode,
        );
      }

      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        throw const ProfileException(
          'Format data profil dari server tidak sesuai.',
        );
      }

      await StorageService.saveProfileJson(data);
      return StudentProfileModel.fromProfileApi(data);
    } on DioException catch (e) {
      throw _mapDioError(e, fallbackMessage: 'Gagal memuat data profil.');
    }
  }

  /// Memperbarui data kontak/biodata Guru via `PUT /api/profile`.
  /// Catatan API Laravel: hanya role Guru yang diperbolehkan mengubah `nomor_telepon`,
  /// `jenis_kelamin`, atau `password` (wajib menyertakan `current_password` jika mengganti password).
  static Future<StudentProfileModel> updateGuruProfile({
    String? nomorTelepon,
    String? jenisKelamin,
    String? currentPassword,
    String? password,
    String? passwordConfirmation,
  }) async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      throw const ProfileException(
        'Sesi login tidak ditemukan. Silakan login kembali.',
        statusCode: 401,
      );
    }

    final payload = <String, dynamic>{};
    if (nomorTelepon != null) {
      payload['nomor_telepon'] = nomorTelepon.trim();
    }
    if (jenisKelamin != null && jenisKelamin.trim().isNotEmpty) {
      payload['jenis_kelamin'] = jenisKelamin.trim();
    }
    if (password != null && password.isNotEmpty) {
      if (currentPassword != null && currentPassword.isNotEmpty) {
        payload['current_password'] = currentPassword;
      }
      payload['password'] = password;
      payload['password_confirmation'] = passwordConfirmation ?? password;
    }

    try {
      final response = await ApiConfig.dio.put(
        '/profile',
        data: payload,
      );

      final body = _normalizeData(response.data);
      if (body['success'] != true) {
        throw ProfileException(
          (body['message'] ?? 'Gagal memperbarui profil.').toString(),
          statusCode: response.statusCode,
        );
      }

      // Refresh full profile agar relasi guruMapels/kelas tetap lengkap
      try {
        return await fetchProfile();
      } catch (_) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          await StorageService.saveProfileJson(data);
          return StudentProfileModel.fromProfileApi(data);
        }
        rethrow;
      }
    } on DioException catch (e) {
      throw _mapDioError(e, fallbackMessage: 'Gagal memperbarui profil.');
    }
  }

  /// Memperbarui kata sandi akun via `PUT /api/profile/password` (Guru & Siswa).
  static Future<String> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      throw const ProfileException(
        'Sesi login tidak ditemukan. Silakan login kembali.',
        statusCode: 401,
      );
    }

    try {
      final response = await ApiConfig.dio.put(
        '/profile/password',
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': passwordConfirmation,
        },
      );

      final body = _normalizeData(response.data);
      if (body['success'] != true) {
        throw ProfileException(
          (body['message'] ?? 'Gagal memperbarui kata sandi.').toString(),
          statusCode: response.statusCode,
        );
      }

      return (body['message'] ?? 'Kata sandi berhasil diperbarui.').toString();
    } on DioException catch (e) {
      throw _mapDioError(e, fallbackMessage: 'Gagal memperbarui kata sandi.');
    }
  }

  static ProfileException _mapDioError(
    DioException e, {
    required String fallbackMessage,
  }) {
    final statusCode = e.response?.statusCode;
    final body = _normalizeData(e.response?.data);
    String? serverMessage = body['message']?.toString();
    final errors = body['errors'] is Map<String, dynamic>
        ? body['errors'] as Map<String, dynamic>
        : null;

    if (errors != null && errors.isNotEmpty) {
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        serverMessage = firstError.first.toString();
      } else if (firstError != null) {
        serverMessage = firstError.toString();
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ProfileException(
          'Koneksi ke server timeout. Periksa koneksi internet Anda.',
        );
      case DioExceptionType.connectionError:
        return ProfileException(
          'Tidak dapat terhubung ke server (${ApiConfig.baseUrl}). '
          'Pastikan backend Laravel berjalan.',
        );
      case DioExceptionType.badResponse:
        if (statusCode == 401) {
          return const ProfileException(
            'Sesi login telah berakhir. Silakan login kembali.',
            statusCode: 401,
          );
        }
        return ProfileException(
          serverMessage ?? fallbackMessage,
          statusCode: statusCode,
          errors: errors,
        );
      default:
        return ProfileException(
          serverMessage ?? fallbackMessage,
          statusCode: statusCode,
          errors: errors,
        );
    }
  }

  static Map<String, dynamic> _normalizeData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
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
