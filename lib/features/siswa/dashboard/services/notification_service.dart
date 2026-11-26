import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:learnpoint_mobile/core/config/api_config.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/models/notification_model.dart';

class NotificationException implements Exception {
  const NotificationException(this.message);
  final String message;
}

class NotificationPage {
  const NotificationPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.unreadCount,
  });
  final List<NotificationModel> items;
  final int currentPage;
  final int lastPage;
  final int unreadCount;
}

class NotificationService {
  Future<NotificationPage> fetch({int page = 1, int perPage = 20}) async {
    final body = await _request(() => ApiConfig.dio.get('/notifikasi',
        queryParameters: {'page': page, 'per_page': perPage}));
    final data = _map(body['data']);
    final pagination = _map(data['notifikasis']);
    final rawItems = pagination['data'];
    return NotificationPage(
      items: rawItems is List
          ? rawItems.whereType<Map>().map((item) => NotificationModel.fromJson(
              Map<String, dynamic>.from(item))).toList()
          : const [],
      currentPage: _asInt(pagination['current_page'], page),
      lastPage: _asInt(pagination['last_page'], 1),
      unreadCount: _asInt(_map(data['counts'])['unread'], 0),
    );
  }

  Future<int> fetchUnreadCount() async {
    final body = await _request(() => ApiConfig.dio.get('/notifikasi/counts'));
    return _asInt(_map(body['data'])['unread'], 0);
  }

  Future<NotificationModel> markAsRead(String id) async {
    final body = await _request(() => ApiConfig.dio.post('/notifikasi/$id/read'));
    return NotificationModel.fromJson(_map(body['data']));
  }

  Future<void> markAllAsRead() =>
      _request(() => ApiConfig.dio.post('/notifikasi/mark-all-read'));

  Future<Map<String, dynamic>> _request(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final body = _map(response.data);
      if (body['success'] != true) {
        throw NotificationException(
          (body['message'] ?? 'Permintaan notifikasi gagal.').toString(),
        );
      }
      return body;
    } on DioException catch (error) {
      final body = _map(error.response?.data);
      throw NotificationException(
        (body['message'] ?? 'Tidak dapat terhubung ke server.').toString(),
      );
    }
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is String) {
      try {
        return _map(jsonDecode(value));
      } catch (_) {}
    }
    return const {};
  }

  static int _asInt(dynamic value, int fallback) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? fallback;
}
