import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:learnpoint_mobile/features/siswa/dashboard/providers/notification_provider.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/widgets/dashboard_header_widget.dart';
import 'package:learnpoint_mobile/features/siswa/profile/models/student_profile_model.dart';
import 'package:learnpoint_mobile/features/siswa/profile/providers/profile_provider.dart';
import 'package:learnpoint_mobile/features/siswa/profile/services/profile_service.dart';
import 'package:learnpoint_mobile/shared/models/user_model.dart';

void main() {
  group('ProfileProvider', () {
    test('seedFromUser and clearCache update state and notify listeners', () {
      final provider = ProfileProvider();
      int notifications = 0;
      provider.addListener(() => notifications++);

      final user = UserModel(
        id: 1,
        name: 'Budi Santoso',
        username: 'budi_s',
        email: 'budi@siswa.learnpoint.sch.id',
        role: 'siswa',
      );

      provider.seedFromUser(user);
      expect(provider.profile, isNotNull);
      expect(provider.currentProfile.name, 'Budi Santoso');
      expect(notifications, 1);

      provider.clearCache();
      expect(provider.profile, isNull);
      expect(provider.currentProfile.isEmpty, isTrue);
      expect(notifications, 2);
    });

    test('ensureLoaded loads cache first and fetches remote when forced', () async {
      const cached = StudentProfileModel(
        name: 'Cached Siswa',
        username: 'cached_siswa',
        initials: 'CS',
        email: 'cached@siswa.learnpoint.sch.id',
        gradeClass: 'Kelas VIII-A',
        schoolName: 'SMP LearnPoint',
        address: '-',
        dateOfBirth: '-',
        gender: 'Laki-laki',
        parentName: '-',
        parentPhone: '-',
        role: 'siswa',
      );
      const remote = StudentProfileModel(
        name: 'Remote Siswa',
        username: 'remote_siswa',
        initials: 'RS',
        email: 'remote@siswa.learnpoint.sch.id',
        gradeClass: 'Kelas VIII-A',
        schoolName: 'SMP LearnPoint',
        address: '-',
        dateOfBirth: '-',
        gender: 'Laki-laki',
        parentName: '-',
        parentPhone: '-',
        role: 'siswa',
      );

      int remoteCalls = 0;
      final provider = ProfileProvider(
        loadCachedProfile: () async => cached,
        fetchProfileRemote: () async {
          remoteCalls++;
          return remote;
        },
      );

      final first = await provider.ensureLoaded();
      expect(first?.name, 'Cached Siswa');
      expect(remoteCalls, 0);

      final refreshed = await provider.ensureLoaded(forceRefresh: true);
      expect(refreshed?.name, 'Remote Siswa');
      expect(provider.currentProfile.name, 'Remote Siswa');
      expect(remoteCalls, 1);
    });

    test('fetchProfile stores ProfileException message without throwing', () async {
      final provider = ProfileProvider(
        fetchProfileRemote: () async {
          throw const ProfileException('Sesi berakhir', statusCode: 401);
        },
      );

      await provider.fetchProfile();
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, 'Sesi berakhir');
    });

    test('updateGuruProfile updates shared state across listeners', () async {
      const updated = StudentProfileModel(
        name: 'Dewi Lestari',
        username: 'dewi_l',
        initials: 'DL',
        email: 'dewi@guru.learnpoint.sch.id',
        gradeClass: 'Wali Kelas VII-A',
        schoolName: 'SMP LearnPoint',
        address: '-',
        dateOfBirth: '-',
        gender: 'Perempuan',
        parentName: '-',
        parentPhone: '08123456789',
        role: 'guru',
      );

      final provider = ProfileProvider(
        updateGuruProfileRemote: ({
          nomorTelepon,
          jenisKelamin,
          password,
          passwordConfirmation,
        }) async =>
            updated,
      );

      final result = await provider.updateGuruProfile(
        nomorTelepon: '08123456789',
        jenisKelamin: 'Perempuan',
      );

      expect(result.parentPhone, '08123456789');
      expect(provider.currentProfile.name, 'Dewi Lestari');
      expect(provider.currentProfile.parentPhone, '08123456789');
    });
  });

  testWidgets('DashboardHeaderWidget and AkunScreen react to ProfileProvider', (
    tester,
  ) async {
    const initialProfile = StudentProfileModel(
      name: 'Dewi Lestari',
      username: 'dewi_l',
      initials: 'DL',
      email: 'dewi@guru.learnpoint.sch.id',
      gradeClass: 'Wali Kelas VII-A',
      schoolName: 'SMP LearnPoint',
      address: '-',
      dateOfBirth: '-',
      gender: 'Perempuan',
      parentName: '-',
      parentPhone: '08110000111',
      role: 'guru',
    );
    const updatedProfile = StudentProfileModel(
      name: 'Dewi Lestari',
      username: 'dewi_l',
      initials: 'DL',
      email: 'dewi@guru.learnpoint.sch.id',
      gradeClass: 'Wali Kelas VII-A',
      schoolName: 'SMP LearnPoint',
      address: '-',
      dateOfBirth: '-',
      gender: 'Perempuan',
      parentName: '-',
      parentPhone: '08999999999',
      role: 'guru',
    );

    bool useUpdated = false;
    final profileProvider = ProfileProvider(
      loadCachedProfile: () async => initialProfile,
      fetchProfileRemote: () async =>
          useUpdated ? updatedProfile : initialProfile,
      updateGuruProfileRemote: ({
        nomorTelepon,
        jenisKelamin,
        password,
        passwordConfirmation,
      }) async =>
          updatedProfile,
    );

    await profileProvider.ensureLoaded();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider<ProfileProvider>.value(
            value: profileProvider,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                DashboardHeaderWidget(),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('D'), findsOneWidget);

    await tester.tap(find.text('D'));
    await tester.pumpAndSettle();

    expect(find.text('Profil Akun'), findsOneWidget);
    expect(find.text('08110000111'), findsOneWidget);

    useUpdated = true;
    await profileProvider.updateGuruProfile(nomorTelepon: '08999999999');
    await tester.pumpAndSettle();

    expect(find.text('08999999999'), findsOneWidget);
  });
}
