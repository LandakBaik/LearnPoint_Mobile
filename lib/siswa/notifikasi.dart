import 'package:flutter/material.dart';

import '../models/notification_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const List<NotificationModel> notifications = [
    NotificationModel(
      id: 'n1',
      title: 'Tugas baru',
      message: 'Pak Budi memberikan tugas Persamaan Linear. Kumpulkan sebelum besok pukul 23.59.',
      time: '10 menit yang lalu',
      icon: Icons.assignment_outlined,
      color: Color(0xFF2563EB),
      backgroundColor: Color(0xFFDBEAFE),
    ),
    NotificationModel(
      id: 'n2',
      title: 'Materi pembelajaran tersedia',
      message: 'Materi Struktur Sel untuk mata pelajaran IPA Terpadu sudah dapat dipelajari.',
      time: '1 jam yang lalu',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF16A34A),
      backgroundColor: Color(0xFFDCFCE7),
    ),
    NotificationModel(
      id: 'n3',
      title: 'Pengingat jadwal',
      message: 'Kelas Workshop Mobile Application dimulai hari ini pukul 09.00 WIB.',
      time: '3 jam yang lalu',
      icon: Icons.event_available_outlined,
      color: Color(0xFF9333EA),
      backgroundColor: Color(0xFFF3E8FF),
    ),
    NotificationModel(
      id: 'n4',
      title: 'Nilai kuis sudah keluar',
      message: 'Kamu mendapatkan nilai 90 untuk Kuis Sistem Organisasi Kehidupan. Pertahankan!',
      time: 'Kemarin',
      icon: Icons.emoji_events_outlined,
      color: Color(0xFFD97706),
      backgroundColor: Color(0xFFFEF3C7),
      isRead: true,
    ),
    NotificationModel(
      id: 'n5',
      title: 'Pengumuman sekolah',
      message: 'Jangan lupa membawa kartu pelajar untuk kegiatan sekolah minggu ini.',
      time: '2 hari yang lalu',
      icon: Icons.campaign_outlined,
      color: Color(0xFF0891B2),
      backgroundColor: Color(0xFFCFFAFE),
      isRead: true,
    ),
    NotificationModel(
      id: 'n6',
      title: 'Pengumuman sekolah',
      message: 'Ada Lomba Lari Minggu depan.',
      time: '2 jam yang lalu',
      icon: Icons.campaign_outlined,
      color: Color(0xFF0891B2),
      backgroundColor: Color(0xFFCFFAFE),
      isRead: true,
    ),
    NotificationModel(
      id: 'n7',
      title: 'Materi pembelajaran tersedia',
      message: 'Materi Pemberontakan PKI untuk mata pelajaran Sejarah Terpadu sudah dapat dipelajari.',
      time: '59 menit yang lalu',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF16A34A),
      backgroundColor: Color(0xFFDCFCE7),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: notifications.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = notifications[index];

          return _NotificationCard(notification: notification);
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead
              ? const Color(0xFFE2E8F0)
              : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: notification.backgroundColor,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(notification.icon, color: notification.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  notification.time,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
