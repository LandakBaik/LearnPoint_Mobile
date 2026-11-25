import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/features/siswa/quiz/config/quiz_assets.dart';

class QuizPerMapelM {
  final int? id;
  final String title;
  final String subtitle;
  final Color color;
  final String? menuImageAsset;
  /// Index ke dalam array `scenes` (`List<QuizScenePreset>`) milik planet mapel-nya
  /// (berasal dari kolom `quizzes.asset` di database).
  final int assetIndex;
  // Fallback ID scene string ('chess', 'chess1', 'chess2', 'void_ruin', 'ribbon1')
  final String levelSceneTheme;

  QuizPerMapelM({
    this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    this.menuImageAsset,
    this.assetIndex = 0,
    this.levelSceneTheme = 'chess',
  });

  /// Mengambil `QuizScenePreset` berdasarkan `planetGroup` dari mapel yang sedang dibuka
  /// dan `assetIndex` (`quizzes.asset`) milik kuis ini.
  QuizScenePreset resolveScenePreset(QuizPlanetAssetGroup planetGroup) {
    return planetGroup.sceneAt(assetIndex);
  }

  /// Factory untuk mengubah JSON dari endpoint GET /api/siswa/quizzes Laravel
  /// menjadi objek `QuizPerMapelM` lengkap dengan `assetIndex` (`quizzes.asset`).
  factory QuizPerMapelM.fromJson(
    Map<String, dynamic> json, {
    int fallbackIndex = 0,
  }) {
    const palette = <Color>[
      Color(0xFF3674D9),
      Color(0xFF218B5B),
      Color(0xFFD97706),
      Color(0xFFDC2626),
      Color(0xFF9333EA),
      Color(0xFF0891B2),
      Color(0xFFDB2777),
      Color(0xFF4F46E5),
      Color(0xFF059669),
    ];

    final rawAsset = json['asset'];
    final int resolvedAssetIndex = rawAsset != null
        ? (int.tryParse(rawAsset.toString()) ?? fallbackIndex)
        : fallbackIndex;

    final rawMapelAsset = json['mapel_asset'];
    final int mapelAssetIdx = rawMapelAsset != null
        ? (int.tryParse(rawMapelAsset.toString()) ?? 0)
        : 0;
    final planetGroup = QuizAssets.planetGroupAt(mapelAssetIdx);
    final scenePreset = planetGroup.sceneAt(resolvedAssetIndex);

    return QuizPerMapelM(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse((json['id'] ?? '').toString()),
      title: (json['judul'] ?? 'Kuis Petualangan').toString(),
      subtitle: (json['deskripsi'] ?? 'Selesaikan misi petualangan').toString(),
      color: palette[fallbackIndex % palette.length],
      menuImageAsset: planetGroup.menuShardAsset,
      assetIndex: resolvedAssetIndex,
      levelSceneTheme: scenePreset.id,
    );
  }
}

final List<QuizPerMapelM> quizMapel = [
  QuizPerMapelM(
    title: 'Geometri',
    subtitle: 'Bangun datar & ruang',
    color: const Color(0xFF3674D9),
    menuImageAsset: QuizAssets.planet1MenuShard,
    assetIndex: 0, // scenes[0]
    levelSceneTheme: 'chess',
  ),
  QuizPerMapelM(
    title: 'Logaritma',
    subtitle: 'Sifat & persamaan logaritma',
    color: const Color(0xFF218B5B),
    menuImageAsset: QuizAssets.planet1MenuShard,
    assetIndex: 1, // scenes[1]
    levelSceneTheme: 'chess1',
  ),
  QuizPerMapelM(
    title: 'Aljabar',
    subtitle: 'Operasi bentuk aljabar',
    color: const Color(0xFFD97706),
    menuImageAsset: QuizAssets.planet1MenuShard,
    assetIndex: 2, // scenes[2]
    levelSceneTheme: 'chess2',
  ),
  QuizPerMapelM(
    title: 'Trigonometri',
    subtitle: 'Sudut & perbandingan segitiga',
    color: const Color(0xFFDC2626),
    menuImageAsset: QuizAssets.planet1MenuShard,
    assetIndex: 0, // scenes[0]
    levelSceneTheme: 'chess',
  ),
  QuizPerMapelM(
    title: 'Statistika',
    subtitle: 'Penyajian & pengolahan data',
    color: const Color(0xFF9333EA),
    menuImageAsset: QuizAssets.planet1MenuShard,
    assetIndex: 1, // scenes[1]
    levelSceneTheme: 'chess1',
  ),
  QuizPerMapelM(
    title: 'Peluang',
    subtitle: 'Kombinatorika & probabilitas',
    color: const Color(0xFF0891B2),
    menuImageAsset: QuizAssets.planet1MenuShard,
    assetIndex: 2, // scenes[2]
    levelSceneTheme: 'chess2',
  ),
  QuizPerMapelM(
    title: 'Kalkulus',
    subtitle: 'Limit, turunan & integral',
    color: const Color(0xFFDB2777),
    menuImageAsset: QuizAssets.planet1MenuShard,
    assetIndex: 0, // scenes[0]
    levelSceneTheme: 'chess',
  ),
  QuizPerMapelM(
    title: 'Matriks',
    subtitle: 'Determinan & invers matriks',
    color: const Color(0xFF4F46E5),
    menuImageAsset: QuizAssets.planet1MenuShard,
    assetIndex: 1, // scenes[1]
    levelSceneTheme: 'chess1',
  ),
  QuizPerMapelM(
    title: 'Vektor',
    subtitle: 'Besaran & arah ruang',
    color: const Color(0xFF059669),
    menuImageAsset: QuizAssets.planet1MenuShard,
    assetIndex: 2, // scenes[2]
    levelSceneTheme: 'chess2',
  ),
];
