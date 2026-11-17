import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:learnpoint_mobile/shared/models/user_model.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';
  static const String _keyBaseUrl = 'custom_base_url';

  // Simpan token autentikasi
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  // Ambil token autentikasi
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  // Simpan data user
  static Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: _keyUser, value: userJson);
  }

  // Ambil data user
  static Future<UserModel?> getUser() async {
    final userJson = await _storage.read(key: _keyUser);
    if (userJson == null) return null;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  // Cek apakah sudah login (memiliki token aktif)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Simpan Base URL kustom jika ada konfigurasi khusus (misal IP laptop)
  static Future<void> saveCustomBaseUrl(String url) async {
    await _storage.write(key: _keyBaseUrl, value: url);
  }

  static Future<String?> getCustomBaseUrl() async {
    return await _storage.read(key: _keyBaseUrl);
  }

  // Hapus semua data autentikasi saat logout
  static Future<void> clearAuth() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUser);
  }
}

