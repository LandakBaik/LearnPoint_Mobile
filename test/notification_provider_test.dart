import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:learnpoint_mobile/features/siswa/dashboard/models/notification_model.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/providers/notification_provider.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/screens/notifikasi_screen.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/widgets/dashboard_header_widget.dart';
import 'package:learnpoint_mobile/features/siswa/profile/models/student_profile_model.dart';

void main() {
  group('NotificationProvider', () {
    test('marks single and all notifications as read and notifies listeners', () {
      final provider = NotificationProvider();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      expect(provider.notifications.length, 7);
      expect(provider.unreadCount, 4);
      expect(provider.hasUnread, isTrue);

      provider.markAsRead('n1');
      expect(provider.unreadCount, 3);
      expect(notifyCount, 1);

      // Menandai item yang sudah dibaca tidak memicu notifyListeners ulang
      provider.markAsRead('n1');
      expect(notifyCount, 1);

      provider.markAllAsRead();
      expect(provider.unreadCount, 0);
      expect(provider.hasUnread, isFalse);
      expect(notifyCount, 2);
    });

    test('adds and removes notifications correctly', () {
      final provider = NotificationProvider();

      provider.addNotification(
        const NotificationModel(
          id: 'n8',
          title: 'Pengingat baru',
          message: 'Ujian dimulai besok.',
          time: 'Baru saja',
          icon: Icons.notifications_active_outlined,
          color: Colors.blue,
          backgroundColor: Colors.lightBlueAccent,
        ),
      );

      expect(provider.notifications.first.id, 'n8');
      expect(provider.unreadCount, 5);

      provider.removeNotification('n8');
      expect(provider.notifications.length, 7);
      expect(provider.unreadCount, 4);
    });
  });

  testWidgets('NotificationScreen and DashboardHeaderWidget share unread state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => NotificationProvider(),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    DashboardHeaderWidget(
                      profile: const StudentProfileModel.empty(),
                      onNotificationTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const NotificationScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    // Awalnya ada 4 notifikasi belum dibaca di badge header
    expect(find.text('4'), findsOneWidget);

    // Buka halaman NotificationScreen
    await tester.tap(find.byIcon(Icons.notifications_none_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Tandai dibaca'), findsOneWidget);

    // Tap notifikasi pertama ('Tugas baru') -> unread berkurang menjadi 3
    await tester.tap(find.text('Tugas baru'));
    await tester.pumpAndSettle();

    // Kembali ke halaman sebelumnya, badge header ikut berubah menjadi 3
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget);

    // Buka lagi dan tekan "Tandai dibaca" -> badge hilang
    await tester.tap(find.byIcon(Icons.notifications_none_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tandai dibaca'));
    await tester.pumpAndSettle();

    expect(find.text('Tandai dibaca'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('3'), findsNothing);
    expect(find.text('4'), findsNothing);
  });
}
