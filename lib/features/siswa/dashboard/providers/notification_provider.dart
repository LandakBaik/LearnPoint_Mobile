import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/models/notification_model.dart';

/// Shared state (Provider) untuk daftar notifikasi dan jumlah yang belum dibaca.
class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [
    const NotificationModel(
      id: 'n1',
      title: 'Tugas baru',
      message:
          'Pak Budi memberikan tugas Persamaan Linear. Kumpulkan sebelum besok pukul 23.59.',
      time: '10 menit yang lalu',
      icon: Icons.assignment_outlined,
      color: Color(0xFF2563EB),
      backgroundColor: Color(0xFFDBEAFE),
    ),
    const NotificationModel(
      id: 'n2',
      title: 'Materi pembelajaran tersedia',
      message:
          'Materi Struktur Sel untuk mata pelajaran IPA Terpadu sudah dapat dipelajari.',
      time: '1 jam yang lalu',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF16A34A),
      backgroundColor: Color(0xFFDCFCE7),
    ),
    const NotificationModel(
      id: 'n3',
      title: 'Pengingat jadwal',
      message:
          'Kelas Workshop Mobile Application dimulai hari ini pukul 09.00 WIB.',
      time: '3 jam yang lalu',
      icon: Icons.event_available_outlined,
      color: Color(0xFF9333EA),
      backgroundColor: Color(0xFFF3E8FF),
    ),
    const NotificationModel(
      id: 'n4',
      title: 'Nilai kuis sudah keluar',
      message:
          'Kamu mendapatkan nilai 90 untuk Kuis Sistem Organisasi Kehidupan. Pertahankan!',
      time: 'Kemarin',
      icon: Icons.emoji_events_outlined,
      color: Color(0xFFD97706),
      backgroundColor: Color(0xFFFEF3C7),
      isRead: true,
    ),
    const NotificationModel(
      id: 'n5',
      title: 'Pengumuman sekolah',
      message:
          'Jangan lupa membawa kartu pelajar untuk kegiatan sekolah minggu ini.',
      time: '2 hari yang lalu',
      icon: Icons.campaign_outlined,
      color: Color(0xFF0891B2),
      backgroundColor: Color(0xFFCFFAFE),
      isRead: true,
    ),
    const NotificationModel(
      id: 'n6',
      title: 'Pengumuman sekolah',
      message: 'Ada Lomba Lari Minggu depan.',
      time: '2 jam yang lalu',
      icon: Icons.campaign_outlined,
      color: Color(0xFF0891B2),
      backgroundColor: Color(0xFFCFFAFE),
      isRead: true,
    ),
    const NotificationModel(
      id: 'n7',
      title: 'Materi pembelajaran tersedia',
      message:
          'Materi Pemberontakan PKI untuk mata pelajaran Sejarah Terpadu sudah dapat dipelajari.',
      time: '59 menit yang lalu',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF16A34A),
      backgroundColor: Color(0xFFDCFCE7),
    ),
  ];

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((item) => !item.isRead).length;

  bool get hasUnread => unreadCount > 0;

  void markAsRead(String id) {
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index == -1 || _notifications[index].isRead) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
  }

  void markAllAsRead() {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void removeNotification(String id) {
    final previousLength = _notifications.length;
    _notifications.removeWhere((item) => item.id == id);
    if (_notifications.length != previousLength) {
      notifyListeners();
    }
  }
}
