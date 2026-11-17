import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';

/// Database Helper SQLite untuk caching data materi e-learning secara offline.
class MateriDatabaseHelper {
  static const String _dbName = 'learnpoint_materi.db';
  static const int _dbVersion = 2; // Naik versi ke 2 untuk mendukung download offline

  // Nama Tabel
  static const String tableMapels = 'cached_mapels';
  static const String tableMateris = 'cached_materis';

  MateriDatabaseHelper._internal();
  static final MateriDatabaseHelper instance = MateriDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Tabel Cache Mata Pelajaran
    await db.execute('''
      CREATE TABLE $tableMapels (
        id INTEGER PRIMARY KEY,
        nama_mapel TEXT NOT NULL,
        total_materi INTEGER DEFAULT 0,
        total_kuis INTEGER DEFAULT 0,
        guru_list TEXT,
        nama_kelas TEXT,
        tingkatan INTEGER,
        semester TEXT,
        tahun_ajaran TEXT,
        last_synced TEXT
      )
    ''');

    // 2. Tabel Cache Butir Materi (Mendukung Opsi 1 & 4)
    await db.execute('''
      CREATE TABLE $tableMateris (
        id INTEGER PRIMARY KEY,
        mapel_id INTEGER NOT NULL,
        id_grub_materi TEXT,
        judul TEXT NOT NULL,
        deskripsi TEXT,
        url_youtube TEXT,
        file_materi TEXT,
        file_url TEXT,
        guru TEXT,
        created_at TEXT,
        is_downloaded INTEGER DEFAULT 0,
        local_file_path TEXT,
        last_synced TEXT,
        FOREIGN KEY (mapel_id) REFERENCES $tableMapels (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $tableMateris ADD COLUMN is_downloaded INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $tableMateris ADD COLUMN local_file_path TEXT',
      );
    }
  }

  // ===========================================================================
  // 1. OPERASI TABEL MAPELS
  // ===========================================================================

  /// Menyimpan / memperbarui cache daftar mata pelajaran ke SQLite.
  Future<void> cacheMapels(List<MateriModel> mapelList) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final item in mapelList) {
        if (item.id == null) continue;
        batch.insert(
          tableMapels,
          {
            'id': item.id,
            'nama_mapel': item.materi,
            'total_materi': item.totalMateri,
            'total_kuis': item.totalKuis,
            'guru_list': jsonEncode(item.guru),
            'last_synced': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  /// Membaca seluruh mata pelajaran tersimpan di SQLite.
  Future<List<MateriModel>> getCachedMapels() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableMapels,
      orderBy: 'nama_mapel ASC',
    );

    if (maps.isEmpty) return [];

    return maps.map((row) {
      List<dynamic> rawGuru = [];
      if (row['guru_list'] != null && row['guru_list'].toString().isNotEmpty) {
        try {
          rawGuru = jsonDecode(row['guru_list'].toString()) as List<dynamic>;
        } catch (_) {}
      }

      return MateriModel.fromJson({
        'id': row['id'],
        'nama_mapel': row['nama_mapel'],
        'total_materi': row['total_materi'] ?? 0,
        'total_kuis': row['total_kuis'] ?? 0,
        'guru': rawGuru,
      });
    }).toList();
  }

  // ===========================================================================
  // 2. OPERASI TABEL MATERIS
  // ===========================================================================

  /// Menyimpan / memperbarui cache detail mapel & materi-materinya ke SQLite.
  /// Mempertahankan status unduhan lokal (`is_downloaded` & `local_file_path`) yang sudah ada.
  Future<void> cacheDetailMapel(MapelDetailModel detail) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      // Ambil data download materi sebelumnya agar tidak tertimpa/hilang
      final existingRows = await txn.query(
        tableMateris,
        columns: ['id', 'is_downloaded', 'local_file_path'],
        where: 'mapel_id = ?',
        whereArgs: [detail.id],
      );

      final Map<int, Map<String, dynamic>> existingDownloadMap = {
        for (var row in existingRows) row['id'] as int: row,
      };

      // 1. Update info identitas kelas & semester pada tabel mapels
      await txn.update(
        tableMapels,
        {
          'nama_kelas': detail.namaKelas,
          'tingkatan': detail.tingkatan,
          'semester': detail.semester,
          'tahun_ajaran': detail.tahunAjaran,
          'last_synced': now,
        },
        where: 'id = ?',
        whereArgs: [detail.id],
      );

      // 2. Refresh materi untuk mapel ini
      await txn.delete(
        tableMateris,
        where: 'mapel_id = ?',
        whereArgs: [detail.id],
      );

      final batch = txn.batch();
      for (final m in detail.materis) {
        final existing = existingDownloadMap[m.id];
        final isDownloaded = existing != null ? (existing['is_downloaded'] as int? ?? 0) : 0;
        final localPath = existing != null ? existing['local_file_path'] as String? : null;

        batch.insert(
          tableMateris,
          {
            'id': m.id,
            'mapel_id': detail.id,
            'id_grub_materi': m.idGrubMateri,
            'judul': m.judul,
            'deskripsi': m.deskripsi,
            'url_youtube': m.urlYoutube,
            'file_materi': m.fileMateri,
            'file_url': m.fileUrl,
            'guru': m.guru,
            'created_at': m.createdAt,
            'is_downloaded': isDownloaded,
            'local_file_path': localPath,
            'last_synced': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  /// Mengambil detail mapel beserta daftar materinya dari cache SQLite jika offline.
  Future<MapelDetailModel?> getCachedDetailMapel(int mapelId) async {
    final db = await database;

    // Ambil data mapel
    final List<Map<String, dynamic>> mapelRows = await db.query(
      tableMapels,
      where: 'id = ?',
      whereArgs: [mapelId],
      limit: 1,
    );

    if (mapelRows.isEmpty) return null;
    final mapelRow = mapelRows.first;

    // Ambil data materi
    final List<Map<String, dynamic>> materiRows = await db.query(
      tableMateris,
      where: 'mapel_id = ?',
      whereArgs: [mapelId],
      orderBy: 'id DESC',
    );

    final List<MateriItemModel> materis = materiRows.map((row) {
      return MateriItemModel(
        id: row['id'] as int,
        idGrubMateri: row['id_grub_materi']?.toString(),
        judul: (row['judul'] ?? 'Materi Pembelajaran').toString(),
        deskripsi: row['deskripsi']?.toString(),
        urlYoutube: row['url_youtube']?.toString(),
        fileMateri: row['file_materi']?.toString(),
        fileUrl: row['file_url']?.toString(),
        guru: row['guru']?.toString(),
        createdAt: row['created_at']?.toString(),
        isDownloaded: (row['is_downloaded'] as int? ?? 0) == 1,
        localFilePath: row['local_file_path']?.toString(),
      );
    }).toList();

    return MapelDetailModel(
      id: mapelRow['id'] as int,
      namaMapel: (mapelRow['nama_mapel'] ?? 'Mata Pelajaran').toString(),
      namaKelas: mapelRow['nama_kelas']?.toString(),
      tingkatan: mapelRow['tingkatan'] as int?,
      semester: mapelRow['semester']?.toString(),
      tahunAjaran: mapelRow['tahun_ajaran']?.toString(),
      materis: materis,
    );
  }

  // ===========================================================================
  // 3. FITUR DOWNLOAD OFFLINE (Opsi 4)
  // ===========================================================================

  /// Mengunduh file modul materi ke penyimpanan lokal perangkat & menandai di SQLite
  Future<String?> downloadMateriFile({
    required int materiId,
    required String fileUrl,
    required String fileName,
  }) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final materiDir = Directory(p.join(appDocDir.path, 'downloaded_materi'));
      if (!await materiDir.exists()) {
        await materiDir.create(recursive: true);
      }

      final savePath = p.join(materiDir.path, '${materiId}_$fileName');

      final dio = Dio();
      await dio.download(fileUrl, savePath);

      final db = await database;
      await db.update(
        tableMateris,
        {
          'is_downloaded': 1,
          'local_file_path': savePath,
        },
        where: 'id = ?',
        whereArgs: [materiId],
      );

      return savePath;
    } catch (_) {
      return null;
    }
  }

  /// Menghapus file fisik unduhan dari memori HP & update status SQLite
  Future<bool> deleteDownloadedMateri(int materiId) async {
    try {
      final db = await database;
      final rows = await db.query(
        tableMateris,
        columns: ['local_file_path'],
        where: 'id = ?',
        whereArgs: [materiId],
      );

      if (rows.isNotEmpty) {
        final localPath = rows.first['local_file_path'] as String?;
        if (localPath != null && localPath.isNotEmpty) {
          final file = File(localPath);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }

      await db.update(
        tableMateris,
        {
          'is_downloaded': 0,
          'local_file_path': null,
        },
        where: 'id = ?',
        whereArgs: [materiId],
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Mengecek apakah suatu materi sudah terunduh secara offline
  Future<bool> isMateriDownloaded(int materiId) async {
    final db = await database;
    final rows = await db.query(
      tableMateris,
      columns: ['is_downloaded', 'local_file_path'],
      where: 'id = ?',
      whereArgs: [materiId],
    );

    if (rows.isEmpty) return false;
    final row = rows.first;
    final isDownloaded = (row['is_downloaded'] as int? ?? 0) == 1;
    final localPath = row['local_file_path'] as String?;

    if (isDownloaded && localPath != null) {
      return await File(localPath).exists();
    }
    return false;
  }

  /// Menghapus seluruh cache (misal saat logout).
  Future<void> clearAllCache() async {
    final db = await database;
    await db.delete(tableMateris);
    await db.delete(tableMapels);
  }
}
