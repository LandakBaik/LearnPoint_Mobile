import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:learnpoint_mobile/features/siswa/dashboard/models/notification_model.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/providers/notification_provider.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/screens/tugas_screen.dart';
import 'package:learnpoint_mobile/features/siswa/mapel/screens/mapel_screen.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/screens/quiz_screen.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/screens/detail_ujian_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreIfNeeded);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().load(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_loadMoreIfNeeded)
      ..dispose();
    super.dispose();
  }

  void _loadMoreIfNeeded() {
    if (_scrollController.position.extentAfter < 240) {
      context.read<NotificationProvider>().loadMore();
    }
  }

  Future<void> _open(NotificationModel notification) async {
    await context.read<NotificationProvider>().markAsRead(notification.id);
    if (!mounted) return;

    // URL adalah petunjuk utama; data/id_referensi menjadi fallback backend.
    final source = '${notification.url ?? ''} ${notification.type} '
        '${notification.data['resource_type'] ?? ''}'.toLowerCase();
    final id = _notificationResourceId(notification);
    Widget? destination;
    if (source.contains('tugas')) {
      destination = const TugasPage();
    } else if (source.contains('materi') || source.contains('mapel')) {
      destination = const MapelScreen();
    } else if (source.contains('kuis') || source.contains('quiz')) {
      destination = const Quiz();
    } else if (source.contains('ujian') && id != null) {
      destination = DetailUjianPage(ujianId: id);
    }
    if (destination != null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => destination!),
      );
    }
  }

  int? _notificationResourceId(NotificationModel notification) {
    const keys = ['id_referensi', 'resource_id', 'tugas_id', 'materi_id', 'quiz_id', 'ujian_id'];
    for (final key in keys) {
      final value = notification.data[key];
      final parsed = value is int ? value : int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    final match = RegExp(r'/(?:tugas|materi|kuis|ujian)/(\d+)').firstMatch(notification.url ?? '');
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Notifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
        actions: [
          if (provider.hasUnread)
            TextButton.icon(
              onPressed: () => provider.markAllAsRead(),
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Tandai dibaca'),
            ),
        ],
      ),
      body: _buildBody(provider, notifications),
    );
  }

  Widget _buildBody(
    NotificationProvider provider,
    List<NotificationModel> notifications,
  ) {
    if (provider.isLoading && notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null && notifications.isEmpty) {
      return _ErrorState(message: provider.error!, onRetry: provider.refresh);
    }
    if (notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: provider.refresh,
        child: ListView(children: const [SizedBox(height: 220), Center(child: Text('Belum ada notifikasi'))]),
      );
    }
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: notifications.length + (provider.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == notifications.length) {
            return const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()));
          }
          final notification = notifications[index];
          return _NotificationCard(notification: notification, onTap: () => _open(notification));
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_rounded, size: 42, color: Color(0xFF64748B)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ]),
        ),
      );
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});
  final NotificationModel notification;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notification.isRead ? Colors.white : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: notification.isRead ? const Color(0xFFE2E8F0) : const Color(0xFFBFDBFE)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: notification.backgroundColor, borderRadius: BorderRadius.circular(13)), child: Icon(notification.icon, color: notification.color)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Expanded(child: Text(notification.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))), if (!notification.isRead) const Padding(padding: EdgeInsets.only(left: 8), child: CircleAvatar(radius: 4, backgroundColor: Color(0xFF2563EB)))]),
                const SizedBox(height: 6),
                Text(notification.message, style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF475569))),
                const SizedBox(height: 10),
                Text(notification.timeAgo, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
              ])),
            ]),
          ),
        ),
      );
}
