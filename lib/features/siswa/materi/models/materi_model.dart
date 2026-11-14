import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/core/config/api_config.dart';

class MateriModel {
  final int? id;
  final String materi;
  final int totalMateri;
  final int totalKuis;
  final List<String> guru;
  final Color color;
  final Color iconColor;
  final IconData icon;
  final String description;
  final String? planetImageAsset;

  MateriModel({
    this.id,
    required this.materi,
    this.totalMateri = 0,
    this.totalKuis = 0,
    this.guru = const [],
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.description,
    this.planetImageAsset,
  });

  /// Factory untuk mengubah JSON dari endpoint GET /api/siswa/materi Laravel
  /// menjadi objek MateriModel lengkap dengan warna & ikon otomatis.
  factory MateriModel.fromJson(Map<String, dynamic> json) {
    final namaMapel = (json['nama_mapel'] ?? 'Mata Pelajaran').toString();
    final total = int.tryParse((json['total_materi'] ?? 0).toString()) ?? 0;
    final totalKuis = int.tryParse((json['total_kuis'] ?? 0).toString()) ?? 0;

    final List<String> daftarGuru = [];
    if (json['guru'] is List) {
      for (final g in (json['guru'] as List)) {
        if (g != null && g.toString().trim().isNotEmpty) {
          daftarGuru.add(g.toString());
        }
      }
    }

    final style = _resolveSubjectStyle(namaMapel);
    final desc = daftarGuru.isNotEmpty
        ? '$total Materi • ${daftarGuru.first}'
        : '$total Materi Pembelajaran';

    return MateriModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse((json['id'] ?? '').toString()),
      materi: namaMapel,
      totalMateri: total,
      totalKuis: totalKuis,
      guru: daftarGuru,
      color: style.bgColor,
      iconColor: style.iconColor,
      icon: style.icon,
      description: desc,
      planetImageAsset: 'assets/images/planet1.png',
    );
  }

  static ({Color bgColor, Color iconColor, IconData icon}) _resolveSubjectStyle(
    String subjectName,
  ) {
    final lower = subjectName.toLowerCase();
    if (lower.contains('matematika')) {
      return (
        bgColor: const Color(0xFFEAF2FF),
        iconColor: const Color(0xFF3674D9),
        icon: Icons.calculate_outlined,
      );
    } else if (lower.contains('fisika')) {
      return (
        bgColor: const Color(0xFFEAFBF3),
        iconColor: const Color(0xFF218B5B),
        icon: Icons.bolt_outlined,
      );
    } else if (lower.contains('biologi') || lower.contains('ipa')) {
      return (
        bgColor: const Color(0xFFFFF7E6),
        iconColor: const Color(0xFFD97706),
        icon: Icons.eco_outlined,
      );
    } else if (lower.contains('indonesia') ||
        lower.contains('inggris') ||
        lower.contains('bahasa')) {
      return (
        bgColor: const Color(0xFFFEE2E2),
        iconColor: const Color(0xFFDC2626),
        icon: Icons.menu_book_outlined,
      );
    } else if (lower.contains('kimia')) {
      return (
        bgColor: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF9333EA),
        icon: Icons.science_outlined,
      );
    }
    return (
      bgColor: const Color(0xFFEAF2FF),
      iconColor: const Color(0xFF3674D9),
      icon: Icons.school_outlined,
    );
  }
}

/// Informasi identitas mata pelajaran dan kelas siswa pada halaman opsi mapel,
/// sesuai objek `data.mapel` dari GET /api/siswa/materi/{mapelId}.
class MapelDetailModel {
  final int id;
  final String namaMapel;
  final String? namaKelas;
  final int? tingkatan;
  final String? semester;
  final String? tahunAjaran;
  final List<MateriItemModel> materis;

  const MapelDetailModel({
    required this.id,
    required this.namaMapel,
    this.namaKelas,
    this.tingkatan,
    this.semester,
    this.tahunAjaran,
    this.materis = const [],
  });

  /// Label sub-header seperti di versi web:
  /// contoh: "Kelas VII-A • Semester Ganjil • 2026/2027"
  String? get identitasLabel {
    final parts = <String>[];
    if (namaKelas != null && namaKelas!.trim().isNotEmpty) {
      final raw = namaKelas!.trim();
      parts.add(
        raw.toLowerCase().startsWith('kelas') ? raw : 'Kelas $raw',
      );
    }
    if (semester != null && semester!.trim().isNotEmpty) {
      final raw = semester!.trim();
      parts.add(
        raw.toLowerCase().startsWith('semester') ? raw : 'Semester $raw',
      );
    }
    if (tahunAjaran != null && tahunAjaran!.trim().isNotEmpty) {
      parts.add(tahunAjaran!.trim());
    }
    return parts.isEmpty ? null : parts.join(' • ');
  }

  factory MapelDetailModel.fromJson(Map<String, dynamic> data) {
    final mapel = data['mapel'] is Map<String, dynamic>
        ? data['mapel'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final rawMateris =
        data['materis'] is List ? data['materis'] as List : const [];

    return MapelDetailModel(
      id: mapel['id'] is int
          ? mapel['id'] as int
          : int.tryParse((mapel['id'] ?? '0').toString()) ?? 0,
      namaMapel: (mapel['nama_mapel'] ?? 'Mata Pelajaran').toString(),
      namaKelas: mapel['nama_kelas']?.toString(),
      tingkatan: mapel['tingkatan'] is int
          ? mapel['tingkatan'] as int
          : int.tryParse((mapel['tingkatan'] ?? '').toString()),
      semester: mapel['semester']?.toString(),
      tahunAjaran: mapel['tahun_ajaran']?.toString(),
      materis: rawMateris
          .whereType<Map<String, dynamic>>()
          .map(MateriItemModel.fromJson)
          .toList(),
    );
  }
}

/// Model untuk 1 item materi di dalam suatu mata pelajaran
/// Sesuai response GET /api/siswa/materi/{mapelId} dari MateriController Laravel
class MateriItemModel {
  final int id;
  final String? idGrubMateri;
  final String judul;
  final String? deskripsi;
  final String? urlYoutube;
  final String? fileMateri;
  final String? fileUrl;
  final String? guru;
  final String? createdAt;
  final bool isDownloaded;
  final String? localFilePath;

  const MateriItemModel({
    required this.id,
    this.idGrubMateri,
    required this.judul,
    this.deskripsi,
    this.urlYoutube,
    this.fileMateri,
    this.fileUrl,
    this.guru,
    this.createdAt,
    this.isDownloaded = false,
    this.localFilePath,
  });

  bool get hasVideo => urlYoutube != null && urlYoutube!.trim().isNotEmpty;
  bool get hasFile => fileUrl != null && fileUrl!.trim().isNotEmpty;
  bool get hasDeskripsi => deskripsi != null && deskripsi!.trim().isNotEmpty;
  bool get hasLocalFile => localFilePath != null && localFilePath!.trim().isNotEmpty;

  /// Copy with untuk memperbarui status unduhan di UI
  MateriItemModel copyWith({
    bool? isDownloaded,
    String? localFilePath,
  }) {
    return MateriItemModel(
      id: id,
      idGrubMateri: idGrubMateri,
      judul: judul,
      deskripsi: deskripsi,
      urlYoutube: urlYoutube,
      fileMateri: fileMateri,
      fileUrl: fileUrl,
      guru: guru,
      createdAt: createdAt,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localFilePath: localFilePath ?? this.localFilePath,
    );
  }

  /// Nama file lampiran, contoh: "aljabar_dasar.pdf".
  String? get fileName => (fileMateri ?? fileUrl)?.split('/').last;

  /// Tanggal terbit dalam waktu lokal (null jika tidak ada / format salah).
  DateTime? get createdAtDate =>
      createdAt == null ? null : DateTime.tryParse(createdAt!)?.toLocal();

  factory MateriItemModel.fromJson(Map<String, dynamic> json) {
    final fileMateri = _nullIfEmpty(json['file_materi']);
    return MateriItemModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      idGrubMateri: json['id_grub_materi']?.toString(),
      judul: (json['judul'] ?? 'Materi Pembelajaran').toString(),
      deskripsi: _nullIfEmpty(json['deskripsi']),
      urlYoutube: _nullIfEmpty(json['url_youtube']),
      fileMateri: fileMateri,
      fileUrl: _resolveFileUrl(_nullIfEmpty(json['file_url']), fileMateri),
      guru: _nullIfEmpty(json['guru']),
      createdAt: json['created_at']?.toString(),
      isDownloaded: json['is_downloaded'] == 1 || json['is_downloaded'] == true,
      localFilePath: json['local_file_path']?.toString(),
    );
  }

  static String? _nullIfEmpty(dynamic value) {
    final s = value?.toString().trim();
    return (s == null || s.isEmpty) ? null : s;
  }

  /// Laravel membuat `file_url` dengan `asset()`, yang bisa menghasilkan
  /// `http://localhost/storage/...` (tidak bisa diakses dari HP/emulator).
  /// Host-nya disamakan dengan host [ApiConfig.baseUrl] agar selalu terjangkau.
  static String? _resolveFileUrl(String? fileUrl, String? fileMateri) {
    final apiUri = Uri.tryParse(ApiConfig.baseUrl);
    if (apiUri == null || apiUri.host.isEmpty) return fileUrl;

    if (fileUrl != null) {
      final uri = Uri.tryParse(fileUrl);
      if (uri != null && uri.hasScheme) {
        return uri
            .replace(
              scheme: apiUri.scheme,
              host: apiUri.host,
              port: apiUri.hasPort ? apiUri.port : null,
            )
            .toString();
      }
    }

    if (fileMateri != null) {
      final origin = apiUri.replace(path: '', query: null).toString();
      return '$origin/storage/$fileMateri';
    }
    return fileUrl;
  }
}

/// Data contoh lokal. Sudah TIDAK dipakai oleh fitur Materi (sekarang 100% dari API),
/// tetapi masih dipakai oleh layar Kuis (`quiz_screen.dart`).
final List<MateriModel> subjek = [
  MateriModel(
    id: 1,
    materi: 'matematika',
    color: const Color(0xFFEAF2FF),
    iconColor: const Color(0xFF3674D9),
    icon: Icons.calculate_outlined,
    description: 'Angka, rumus, dan logika',
    planetImageAsset: 'assets/images/planet1.png',
  ),
  MateriModel(
    id: 2,
    materi: 'Fisika',
    color: const Color(0xFFEAFBF3),
    iconColor: const Color(0xFF218B5B),
    icon: Icons.bolt_outlined,
    description: 'Energi, gaya, dan gerak',
    planetImageAsset: 'assets/images/planet1.png',
  ),
  MateriModel(
    id: 3,
    materi: 'Biologi',
    color: const Color(0xFFFFF7E6),
    iconColor: const Color(0xFFD97706),
    icon: Icons.eco_outlined,
    description: 'Makhluk hidup dan ekosistem',
    planetImageAsset: 'assets/images/planet1.png',
  ),
  MateriModel(
    id: 4,
    materi: 'Bahasa Indonesia',
    color: const Color(0xFFFEE2E2),
    iconColor: const Color(0xFFDC2626),
    icon: Icons.menu_book_outlined,
    description: 'Tata bahasa dan literasi',
    planetImageAsset: 'assets/images/planet1.png',
  ),
  MateriModel(
    id: 5,
    materi: 'Kimia',
    color: const Color(0xFFF3E8FF),
    iconColor: const Color(0xFF9333EA),
    icon: Icons.science_outlined,
    description: 'Struktur dan reaksi zat',
    planetImageAsset: 'assets/images/planet1.png',
  ),
];
