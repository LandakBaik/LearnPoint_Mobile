import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? url;
  final Map<String, dynamic> data;
  final bool isRead;
  final String timeAgo;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.url,
    required this.data,
    required this.isRead,
    required this.timeAgo,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return NotificationModel(
      id: json['id'].toString(),
      title: (json['judul'] ?? json['title'] ?? 'Notifikasi').toString(),
      message: (json['pesan'] ?? json['message'] ?? '').toString(),
      type: (json['tipe'] ?? json['type'] ?? 'info').toString(),
      url: json['url']?.toString(),
      data: rawData is Map
          ? Map<String, dynamic>.from(rawData)
          : const <String, dynamic>{},
      isRead: json['is_read'] == true || json['is_read'] == 1,
      timeAgo: (json['time_ago'] ?? json['time'] ?? 'Baru saja').toString(),
    );
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        message: message,
        type: type,
        url: url,
        data: data,
        isRead: isRead ?? this.isRead,
        timeAgo: timeAgo,
      );

  IconData get icon => switch (type) {
        'materi_baru' => Icons.menu_book_rounded,
        'tugas_baru' || 'tugas_dikumpulkan' || 'tugas_terlambat' ||
        'nilai_tugas' => Icons.assignment_outlined,
        'kuis_baru' || 'kuis_selesai' => Icons.quiz_outlined,
        'ujian_baru' || 'ujian_selesai' || 'ujian_remidi' ||
        'nilai_ujian' => Icons.fact_check_outlined,
        'pengingat_deadline' || 'pengingat_ujian' || 'pengingat_koreksi' =>
          Icons.event_available_outlined,
        _ => Icons.campaign_outlined,
      };

  Color get color => switch (type) {
        'materi_baru' => const Color(0xFF16A34A),
        'tugas_baru' || 'tugas_dikumpulkan' || 'tugas_terlambat' ||
        'nilai_tugas' => const Color(0xFF2563EB),
        'kuis_baru' || 'kuis_selesai' || 'ujian_baru' || 'ujian_selesai' ||
        'ujian_remidi' || 'nilai_ujian' => const Color(0xFF9333EA),
        _ => const Color(0xFF0891B2),
      };

  Color get backgroundColor => Color.alphaBlend(
        color.withValues(alpha: 0.14),
        Colors.white,
      );
}
