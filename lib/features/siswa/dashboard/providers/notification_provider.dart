import 'package:flutter/foundation.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/models/notification_model.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/services/notification_service.dart';

/// State inbox, badge, dan sinkronisasi aksi notifikasi dengan API Laravel.
class NotificationProvider extends ChangeNotifier {
  NotificationProvider({NotificationService? service})
      : _service = service ?? NotificationService();

  final NotificationService _service;
  final List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  int _currentPage = 0;
  int _lastPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get hasUnread => unreadCount > 0;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _currentPage < _lastPage;
  String? get error => _error;

  Future<void> load({bool refresh = false}) async {
    if (_isLoading || (!refresh && _currentPage > 0)) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _service.fetch(page: 1);
      _notifications
        ..clear()
        ..addAll(result.items);
      _currentPage = result.currentPage;
      _lastPage = result.lastPage;
      _unreadCount = result.unreadCount;
    } catch (e) {
      _error = _friendlyError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(refresh: true);

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final result = await _service.fetch(page: _currentPage + 1);
      _notifications.addAll(result.items);
      _currentPage = result.currentPage;
      _lastPage = result.lastPage;
      _unreadCount = result.unreadCount;
    } catch (e) {
      _error = _friendlyError(e);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshUnreadCount() async {
    try {
      _unreadCount = await _service.fetchUnreadCount();
      notifyListeners();
    } catch (_) {
      // Badge lama tetap ditampilkan ketika perangkat sedang offline.
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index < 0 || _notifications[index].isRead) return;
    final previous = _notifications[index];
    _notifications[index] = previous.copyWith(isRead: true);
    _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount) as int;
    notifyListeners();
    try {
      _notifications[index] = await _service.markAsRead(id);
      await refreshUnreadCount();
    } catch (e) {
      _notifications[index] = previous;
      _unreadCount++;
      _error = _friendlyError(e);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    if (!hasUnread) return;
    final before = List<NotificationModel>.from(_notifications);
    final previousUnread = _unreadCount;
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _unreadCount = 0;
    notifyListeners();
    try {
      await _service.markAllAsRead();
    } catch (e) {
      _notifications
        ..clear()
        ..addAll(before);
      _unreadCount = previousUnread;
      _error = _friendlyError(e);
      notifyListeners();
    }
  }

  String _friendlyError(Object error) => error is NotificationException
      ? error.message
      : 'Gagal memuat notifikasi. Silakan coba lagi.';
}
