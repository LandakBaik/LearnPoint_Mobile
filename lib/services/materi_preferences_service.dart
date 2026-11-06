import 'package:shared_preferences/shared_preferences.dart';

class MateriPreferencesService {
  static const String _keyCompletedList = 'materi_completed_list';
  static const String _keyBookmarkedList = 'materi_bookmarked_list';
  static const String _prefixLastSubBab = 'materi_subbab_';
  static const String _keyLastReadTitle = 'materi_last_read_title';
  static const String _keyLastReadSubject = 'materi_last_read_subject';

  /// Membuat key unik berdasarkan mata pelajaran dan judul materi
  static String _buildMateriKey(String subject, String title) {
    final cleanSubject = subject.trim().toLowerCase().replaceAll(' ', '_');
    final cleanTitle = title.trim().toLowerCase().replaceAll(' ', '_');
    return '${cleanSubject}_$cleanTitle';
  }

  // =========================================================
  // 1. SUB-BAB TERAKHIR (Posisi bacaan terakhir per materi)
  // =========================================================

  static Future<void> saveLastSubBab({
    required String subject,
    required String title,
    required int subBabIndex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefixLastSubBab${_buildMateriKey(subject, title)}';
    await prefs.setInt(key, subBabIndex);

    // Sekaligus catat sebagai materi terakhir yang sedang dipelajari
    await prefs.setString(_keyLastReadTitle, title);
    await prefs.setString(_keyLastReadSubject, subject);
  }

  static Future<int> getLastSubBab({
    required String subject,
    required String title,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefixLastSubBab${_buildMateriKey(subject, title)}';
    return prefs.getInt(key) ?? 0;
  }

  // =========================================================
  // 2. STATUS SELESAI (isCompleted)
  // =========================================================

  static Future<bool> isCompleted({
    required String subject,
    required String title,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final completedList = prefs.getStringList(_keyCompletedList) ?? <String>[];
    final itemKey = _buildMateriKey(subject, title);
    return completedList.contains(itemKey);
  }

  static Future<bool> toggleCompleted({
    required String subject,
    required String title,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final completedList =
        List<String>.from(prefs.getStringList(_keyCompletedList) ?? <String>[]);
    final itemKey = _buildMateriKey(subject, title);

    final bool newState;
    if (completedList.contains(itemKey)) {
      completedList.remove(itemKey);
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
    required String subject,
    required String title,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedList =
        prefs.getStringList(_keyBookmarkedList) ?? <String>[];
    final itemKey = _buildMateriKey(subject, title);
    return bookmarkedList.contains(itemKey);
  }

  static Future<bool> toggleBookmark({
    required String subject,
    required String title,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedList = List<String>.from(
      prefs.getStringList(_keyBookmarkedList) ?? <String>[],
    );
    final itemKey = _buildMateriKey(subject, title);

    final bool newState;
    if (bookmarkedList.contains(itemKey)) {
      bookmarkedList.remove(itemKey);
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

  // Helper publik agar widget list materi bisa mengecek key yang sama
  static String getMateriKey(String subject, String title) =>
      _buildMateriKey(subject, title);
}
