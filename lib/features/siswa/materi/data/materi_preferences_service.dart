import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Model sederhana untuk data materi yang terakhir dibaca siswa.
class LastReadMateri {
  final int? id;
  final String title;
  final String subject;
  final String? guru;
  final String? deskripsi;
  final String? urlYoutube;
  final String? fileMateri;
  final String? fileUrl;
  final int subBabIndex;
  final DateTime updatedAt;

  const LastReadMateri({
    this.id,
    required this.title,
    required this.subject,
    this.guru,
    this.deskripsi,
    this.urlYoutube,
    this.fileMateri,
    this.fileUrl,
    this.subBabIndex = 0,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'guru': guru,
        'deskripsi': deskripsi,
        'url_youtube': urlYoutube,
        'file_materi': fileMateri,
        'file_url': fileUrl,
        'sub_bab_index': subBabIndex,
        'updated_at': updatedAt.toIso8601String(),
      };

  factory LastReadMateri.fromJson(Map<String, dynamic> json) => LastReadMateri(
        id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
        title: (json['title'] ?? 'Materi Pembelajaran').toString(),
        subject: (json['subject'] ?? 'Mata Pelajaran').toString(),
        guru: json['guru']?.toString(),
        deskripsi: json['deskripsi']?.toString(),
        urlYoutube: json['url_youtube']?.toString(),
        fileMateri: json['file_materi']?.toString(),
        fileUrl: json['file_url']?.toString(),
        subBabIndex: int.tryParse(json['sub_bab_index']?.toString() ?? '0') ?? 0,
        updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      );
}

class MateriPreferencesService {
  static const String _keyCompletedList = 'materi_completed_list';
  static const String _keyBookmarkedList = 'materi_bookmarked_list';
  static const String _prefixLastSubBab = 'materi_subbab_';
  static const String _keyLastReadData = 'materi_last_read_json';
  static const String _keyLastReadTitle = 'materi_last_read_title';
  static const String _keyLastReadSubject = 'materi_last_read_subject';

  /// Membuat key unik materi.
  /// Prioritas menggunakan ID Materi database agar kebal terhadap perubahan nama/judul.
  /// Jika ID bernilai null (misal offline/fallback), fallback ke subject_title.
  static String resolveKey({int? id, required String subject, required String title}) {
    if (id != null && id > 0) {
      return 'id_$id';
    }
    final cleanSubject = subject.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    final cleanTitle = title.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    return '${cleanSubject}_$cleanTitle';
  }

  // =========================================================
  // 1. SUB-BAB TERAKHIR & MATERI TERAKHIR DIBACA
  // =========================================================

  static Future<void> saveLastSubBab({
    int? id,
    required String subject,
    required String title,
    String? guru,
    String? deskripsi,
    String? urlYoutube,
    String? fileMateri,
    String? fileUrl,
    required int subBabIndex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final itemKey = resolveKey(id: id, subject: subject, title: title);
    await prefs.setInt('$_prefixLastSubBab$itemKey', subBabIndex);

    // Simpan objek LastRead lengkap dalam format JSON
    final lastRead = LastReadMateri(
      id: id,
      title: title,
      subject: subject,
      guru: guru,
      deskripsi: deskripsi,
      urlYoutube: urlYoutube,
      fileMateri: fileMateri,
      fileUrl: fileUrl,
      subBabIndex: subBabIndex,
      updatedAt: DateTime.now(),
    );
    await prefs.setString(_keyLastReadData, jsonEncode(lastRead.toJson()));

    // Tetap simpan string title & subject untuk backward-compatibility
    await prefs.setString(_keyLastReadTitle, title);
    await prefs.setString(_keyLastReadSubject, subject);
  }

  static Future<int> getLastSubBab({
    int? id,
    required String subject,
    required String title,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final itemKey = resolveKey(id: id, subject: subject, title: title);
    final val = prefs.getInt('$_prefixLastSubBab$itemKey');
    if (val != null) return val;

    // Fallback coba cek format kunci lama jika ada data sebelumnya
    final oldKey = resolveKey(subject: subject, title: title);
    return prefs.getInt('$_prefixLastSubBab$oldKey') ?? 0;
  }

  /// Mengambil data materi terakhir yang dibuka siswa (untuk Dashboard Siswa).
  static Future<LastReadMateri?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_keyLastReadData);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawJson);
        if (decoded is Map<String, dynamic>) {
          return LastReadMateri.fromJson(decoded);
        }
      } catch (_) {}
    }

    // Fallback jika hanya ada data title & subject lama
    final title = prefs.getString(_keyLastReadTitle);
    final subject = prefs.getString(_keyLastReadSubject);
    if (title != null && title.isNotEmpty) {
      return LastReadMateri(
        title: title,
        subject: subject ?? 'Materi Pembelajaran',
        updatedAt: DateTime.now(),
      );
    }
    return null;
  }

  // =========================================================
  // 2. STATUS SELESAI (isCompleted)
  // =========================================================

  static Future<bool> isCompleted({
    int? id,
    required String subject,
    required String title,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final completedList = prefs.getStringList(_keyCompletedList) ?? <String>[];
    final itemKey = resolveKey(id: id, subject: subject, title: title);
    if (completedList.contains(itemKey)) return true;

    // Fallback cek kunci lama
    final oldKey = resolveKey(subject: subject, title: title);
    return completedList.contains(oldKey);
  }

  static Future<bool> toggleCompleted({
    int? id,
    required String subject,
    required String title,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final completedList =
        List<String>.from(prefs.getStringList(_keyCompletedList) ?? <String>[]);
    final itemKey = resolveKey(id: id, subject: subject, title: title);
    final oldKey = resolveKey(subject: subject, title: title);

    final bool newState;
    if (completedList.contains(itemKey) || completedList.contains(oldKey)) {
      completedList.remove(itemKey);
      completedList.remove(oldKey);
      newState = false;
    } else {
      completedList.add(itemKey);
      newState = true;
    }

    await prefs.setStringList(_keyCompletedList, completedList);
    return newState;
  }

  static Future<List<String>> getCompletedKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyCompletedList) ?? <String>[];
  }

  // =========================================================
  // 3. STATUS BOOKMARK (isBookmarked)
  // =========================================================

  static Future<bool> isBookmarked({
    int? id,
    required String subject,
    required String title,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedList =
        prefs.getStringList(_keyBookmarkedList) ?? <String>[];
    final itemKey = resolveKey(id: id, subject: subject, title: title);
    if (bookmarkedList.contains(itemKey)) return true;

    // Fallback cek kunci lama
    final oldKey = resolveKey(subject: subject, title: title);
    return bookmarkedList.contains(oldKey);
  }

  static Future<bool> toggleBookmark({
    int? id,
    required String subject,
    required String title,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedList = List<String>.from(
      prefs.getStringList(_keyBookmarkedList) ?? <String>[],
    );
    final itemKey = resolveKey(id: id, subject: subject, title: title);
    final oldKey = resolveKey(subject: subject, title: title);

    final bool newState;
    if (bookmarkedList.contains(itemKey) || bookmarkedList.contains(oldKey)) {
      bookmarkedList.remove(itemKey);
      bookmarkedList.remove(oldKey);
      newState = false;
    } else {
      bookmarkedList.add(itemKey);
      newState = true;
    }

    await prefs.setStringList(_keyBookmarkedList, bookmarkedList);
    return newState;
  }

  static Future<List<String>> getBookmarkedKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyBookmarkedList) ?? <String>[];
  }

  /// Helper untuk mencocokkan key baik berbasis ID maupun title
  static String getMateriKey(String subject, String title, {int? id}) =>
      resolveKey(id: id, subject: subject, title: title);
}
