import 'package:flutter/material.dart';

class MateriModel {
  final int? id;
  final String materi;
  final String? kodeMapel;
  final int totalMateri;
  final List<String> guru;
  final Color color;
  final Color iconColor;
  final IconData icon;
  final String description;
  final String? planetImageAsset;

  MateriModel({
    this.id,
    required this.materi,
    this.kodeMapel,
    this.totalMateri = 0,
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
      kodeMapel: json['kode_mapel']?.toString(),
      totalMateri: total,
      guru: daftarGuru,
      color: style.bgColor,
      iconColor: style.iconColor,
      icon: style.icon,
      description: desc,
      planetImageAsset: 'assets/images/planet1.png',
    );
  }

  static ({Color bgColor, Color iconColor, IconData icon})
      _resolveSubjectStyle(String subjectName) {
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
    } else if (lower.contains('indonesia') || lower.contains('inggris') || lower.contains('bahasa')) {
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
  });

  factory MateriItemModel.fromJson(Map<String, dynamic> json) {
    return MateriItemModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      idGrubMateri: json['id_grub_materi']?.toString(),
      judul: (json['judul'] ?? 'Materi Pembelajaran').toString(),
      deskripsi: json['deskripsi']?.toString(),
      urlYoutube: json['url_youtube']?.toString(),
      fileMateri: json['file_materi']?.toString(),
      fileUrl: json['file_url']?.toString(),
      guru: json['guru']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

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
