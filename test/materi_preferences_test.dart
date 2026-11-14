import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Reset SharedPreferences dengan initial values kosong sebelum tiap test case
    SharedPreferences.setMockInitialValues({});
  });

  group('[Black Box Test] Materi Preferences Service - Status Bookmark', () {
    test('TC-BM-01: Materi belum dibookmark secara default', () async {
      final isBookmarked = await MateriPreferencesService.isBookmarked(
        id: 3,
        subject: 'Matematika',
        title: 'Pengenalan Aljabar',
      );

      expect(isBookmarked, isFalse,
          reason: 'Materi yang belum pernah disimpan harus mengembalikan false');
    });

    test('TC-BM-02: Menambah bookmark materi (Toggle Aktif)', () async {
      final newState = await MateriPreferencesService.toggleBookmark(
        id: 3,
        subject: 'Matematika',
        title: 'Pengenalan Aljabar',
      );

      expect(newState, isTrue, reason: 'State setelah bookmark pertama harus true');

      final isSaved = await MateriPreferencesService.isBookmarked(
        id: 3,
        subject: 'Matematika',
        title: 'Pengenalan Aljabar',
      );
      expect(isSaved, isTrue, reason: 'Data bookmark harus tersimpan di SharedPreferences');
    });

    test('TC-BM-03: Menghapus bookmark materi (Toggle Nonaktif)', () async {
      // 1. Tambah bookmark
      await MateriPreferencesService.toggleBookmark(
        id: 3,
        subject: 'Matematika',
        title: 'Pengenalan Aljabar',
      );

      // 2. Klik lagi untuk menghapus bookmark
      final newState = await MateriPreferencesService.toggleBookmark(
        id: 3,
        subject: 'Matematika',
        title: 'Pengenalan Aljabar',
      );

      expect(newState, isFalse, reason: 'State setelah ditoggle ulang harus false');

      final isSaved = await MateriPreferencesService.isBookmarked(
        id: 3,
        subject: 'Matematika',
        title: 'Pengenalan Aljabar',
      );
      expect(isSaved, isFalse, reason: 'Data bookmark harus sudah terhapus');
    });

    test('TC-BM-04: Mendapatkan seluruh daftar kunci bookmark', () async {
      await MateriPreferencesService.toggleBookmark(id: 3, subject: 'Matematika', title: 'Aljabar');
      await MateriPreferencesService.toggleBookmark(id: 6, subject: 'IPA', title: 'Makhluk Hidup');

      final keys = await MateriPreferencesService.getBookmarkedKeys();

      expect(keys.length, 2);
      expect(keys.contains('id_3'), isTrue);
      expect(keys.contains('id_6'), isTrue);
    });
  });

  group('[Black Box Test] Materi Preferences Service - Status Selesai Dipelajari', () {
    test('TC-CMP-01: Materi belum selesai secara default', () async {
      final completed = await MateriPreferencesService.isCompleted(
        id: 3,
        subject: 'Matematika',
        title: 'Pengenalan Aljabar',
      );

      expect(completed, isFalse);
    });

    test('TC-CMP-02: Menandai materi selesai dipelajari', () async {
      final newState = await MateriPreferencesService.toggleCompleted(
        id: 3,
        subject: 'Matematika',
        title: 'Pengenalan Aljabar',
      );

      expect(newState, isTrue);

      final isCompleted = await MateriPreferencesService.isCompleted(
        id: 3,
        subject: 'Matematika',
        title: 'Pengenalan Aljabar',
      );
      expect(isCompleted, isTrue);
    });

    test('TC-CMP-03: Membatalkan tanda selesai materi', () async {
      await MateriPreferencesService.toggleCompleted(
        id: 3,
        subject: 'Matematika',
        title: 'Pengenalan Aljabar',
      );

      final newState = await MateriPreferencesService.toggleCompleted(
        id: 3,
        subject: 'Matematika',
        title: 'Pengenalan Aljabar',
      );

      expect(newState, isFalse);

      final isCompleted = await MateriPreferencesService.isCompleted(
        id: 3,
        subject: 'Matematika',
        title: 'Pengenalan Aljabar',
      );
      expect(isCompleted, isFalse);
    });
  });

  group('[Black Box Test] Materi Preferences Service - Riwayat Terakhir Dibaca', () {
    test('TC-LR-01: Mengembalikan null jika belum ada materi yang pernah dibuka', () async {
      final lastRead = await MateriPreferencesService.getLastRead();
      expect(lastRead, isNull);
    });

    test('TC-LR-02: Menyimpan dan memuat riwayat materi terakhir yang dibaca', () async {
      await MateriPreferencesService.saveLastSubBab(
        id: 3,
        subject: 'Matematika',
        title: 'Pengenalan Aljabar & Operasi Hitung',
        guru: 'Pak Budi',
        deskripsi: 'Deskripsi singkat aljabar',
        urlYoutube: 'https://youtube.com/watch?v=sample',
        fileMateri: 'materi/aljabar.pdf',
        fileUrl: 'http://10.10.5.92:8000/storage/materi/aljabar.pdf',
        subBabIndex: 2,
      );

      final lastRead = await MateriPreferencesService.getLastRead();

      expect(lastRead, isNotNull);
      expect(lastRead!.id, 3);
      expect(lastRead.subject, 'Matematika');
      expect(lastRead.title, 'Pengenalan Aljabar & Operasi Hitung');
      expect(lastRead.guru, 'Pak Budi');
      expect(lastRead.subBabIndex, 2);
      expect(lastRead.urlYoutube, 'https://youtube.com/watch?v=sample');
    });

    test('TC-LR-03: Menimpa riwayat dengan materi baru yang terakhir dibuka', () async {
      // Buka materi pertama
      await MateriPreferencesService.saveLastSubBab(
        id: 3,
        subject: 'Matematika',
        title: 'Aljabar',
        subBabIndex: 0,
      );

      // Buka materi kedua (paling baru)
      await MateriPreferencesService.saveLastSubBab(
        id: 6,
        subject: 'IPA',
        title: 'Klasifikasi Makhluk Hidup',
        guru: 'Bu Siti',
        subBabIndex: 1,
      );

      final lastRead = await MateriPreferencesService.getLastRead();

      expect(lastRead, isNotNull);
      expect(lastRead!.id, 6);
      expect(lastRead.subject, 'IPA');
      expect(lastRead.title, 'Klasifikasi Makhluk Hidup');
      expect(lastRead.guru, 'Bu Siti');
      expect(lastRead.subBabIndex, 1);
    });
  });

  group('[Black Box Test] Kompatibilitas Key & Fallback Data Lama', () {
    test('TC-CP-01: Membaca status bookmark format lama (berbasis subject_title)', () async {
      // Simulasikan ada data lama pengguna tanpa prefix id
      SharedPreferences.setMockInitialValues({
        'materi_bookmarked_list': ['matematika_aljabar_dasar'],
      });

      // Sistem harus tetap mengenali materi lama tersebut
      final isBookmarked = await MateriPreferencesService.isBookmarked(
        subject: 'Matematika',
        title: 'Aljabar Dasar',
      );

      expect(isBookmarked, isTrue);
    });
  });
}
