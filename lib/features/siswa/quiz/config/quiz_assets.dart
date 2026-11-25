import 'package:flutter/material.dart';

/// Konfigurasi setiap layer pada background scene QuizLevel.
class QuizSceneLayer {
  final int levelOrder; // 1 = Level 1 (paling depan/bawah), dst
  final String assetPath;
  final double labelXFraction;
  final double labelYFraction;
  // Seberapa banyak layer ini turun ke bawah ketika di-scroll (0.0 = fixed)
  final double scrollShiftFactor;
  // Jarak muncul dari bawah ke atas saat transisi membuka menu QuizLevel
  final double entranceSlideDistance;
  final double entranceIntervalStart;
  final double entranceIntervalEnd;

  const QuizSceneLayer({
    required this.levelOrder,
    required this.assetPath,
    required this.labelXFraction,
    required this.labelYFraction,
    required this.scrollShiftFactor,
    required this.entranceSlideDistance,
    required this.entranceIntervalStart,
    required this.entranceIntervalEnd,
  });
}

/// Konfigurasi satu tema background scene level utuh (`QuizScenePreset`).
/// Dicocokkan dengan kolom `quizzes.asset` (index di dalam array `scenes` milik planet mapel-nya).
class QuizScenePreset {
  final String id;
  final String baseSkyAsset;
  final double imageAspectRatio;
  final Color fallbackBgColor;
  final List<QuizSceneLayer> layersBackToFront;

  const QuizScenePreset({
    required this.id,
    required this.baseSkyAsset,
    required this.imageAspectRatio,
    required this.fallbackBgColor,
    required this.layersBackToFront,
  });
}

/// Konfigurasi satu kelompok aset tema Planet (`QuizPlanetAssetGroup`).
/// Dicocokkan dengan kolom `mapels.asset` (index di dalam array `QuizAssets.planetGroups`).
class QuizPlanetAssetGroup {
  final int index;
  final String id;
  final String planetAsset;
  final String menuShardAsset;
  final String handDecorAsset;
  final Color radialBgColor;
  final List<QuizScenePreset> scenes;

  const QuizPlanetAssetGroup({
    required this.index,
    required this.id,
    required this.planetAsset,
    required this.menuShardAsset,
    required this.handDecorAsset,
    required this.radialBgColor,
    required this.scenes,
  });

  /// Mengambil `QuizScenePreset` berdasarkan nilai `quizzes.asset` (Opsi A: index relatif terhadap `scenes` planet ini).
  QuizScenePreset sceneAt(int quizAssetIndex) {
    if (scenes.isEmpty) {
      return QuizAssets.chessTealScene;
    }
    final safeIndex = quizAssetIndex < 0 ? 0 : (quizAssetIndex % scenes.length);
    return scenes[safeIndex];
  }
}

/// Sentralisasi seluruh path aset untuk fitur Quiz & Gacha.
/// Dikelompokkan berdasarkan Lobby Parallax, Gacha, dan Array `planetGroups`.
class QuizAssets {
  QuizAssets._();

  // ===========================================================================
  // 1. LOBBY PARALLAX (`assets/images/quiz/lobby/`)
  // ===========================================================================
  static const String _lobbyDir = 'assets/images/quiz/lobby';
  static const String lobbyMainBg = '$_lobbyDir/vg_main.png';
  static const String lobbySpiral = '$_lobbyDir/vg_spiral.png';
  static const String lobbyBigStars = '$_lobbyDir/vg_big_stars.png';
  static const String lobbySmallStars = '$_lobbyDir/vg_small_stars.png';
  static const String lobbyMist = '$_lobbyDir/vg_mist.png';
  static const String lobbyLightPath = '$_lobbyDir/lightpath1.png';
  static const String lobbyGroundStars = '$_lobbyDir/vg_ground_stars.png';
  static const String lobbyCharacter = '$_lobbyDir/vg_character.gif';
  static const String lobbyFallenStarLight = '$_lobbyDir/fallenstar_light.png';
  static const String lobbyStars1 = '$_lobbyDir/stars1.png';
  static const String lobbyStars2 = '$_lobbyDir/stars2.png';

  // ===========================================================================
  // 2. GACHA PARALLAX & UI (`assets/images/quiz/gacha/`)
  // ===========================================================================
  static const String _gachaDir = 'assets/images/quiz/gacha';
  static const String gachaMainBg = '$_gachaDir/gacha_main.png';
  static const String gachaSpiral = '$_gachaDir/gacha_spiral.png';
  static const String gachaBigStars = '$_gachaDir/gacha_bigstars.png';
  static const String gachaStars = '$_gachaDir/gacha_stars.png';
  static const String gachaMist = '$_gachaDir/gacha_mist.png';
  static const String gachaLightPath = '$_gachaDir/gacha_lightpath.png';
  static const String gachaGroundStarsLight =
      '$_gachaDir/gacha_groundstars_light.png';
  static const String gachaOpOrb = '$_gachaDir/gacha op.gif';
  static const String gachaPullEffect = '$_gachaDir/gacha_pull.gif';

  // ===========================================================================
  // 3. PATH DIREKTORI PLANET
  // ===========================================================================
  static const String _planet1Dir =
      'assets/images/quiz/planets/planet_1_chess';
  static const String planet1 = '$_planet1Dir/planet.png';
  static const String planet1MenuShard = '$_planet1Dir/menu_shard.png';
  static const String planet1HandDecor = '$_planet1Dir/hand_decor.png';
  static const String sceneChessTealDir = '$_planet1Dir/scenes/chess_teal';
  static const String sceneChessOliveDir = '$_planet1Dir/scenes/chess_olive';
  static const String sceneChessRuinsDir = '$_planet1Dir/scenes/chess_ruins';

  static const String _planet2Dir = 'assets/images/quiz/planets/planet_2_void';
  static const String planet2 = '$_planet2Dir/planet.png';
  static const String sceneVoidRuinDir = '$_planet2Dir/scenes/void_ruin';

  static const String _planet3Dir =
      'assets/images/quiz/planets/planet_3_ribbon';
  static const String planet3 = '$_planet3Dir/planet.png';
  static const String sceneRibbonCastleDir =
      '$_planet3Dir/scenes/ribbon_castle';

  static const String _planet4Dir = 'assets/images/quiz/planets/planet_4_sun';
  static const String planet4 = '$_planet4Dir/planet.png';

  // ===========================================================================
  // 4. DAFTAR SCENE PRESETS (`QuizScenePreset`)
  // ===========================================================================

  /// Planet 1 - Scene 0: Chess Teal (Biru Teal • 619 x 1480 • layer0 + layer1..layer7)
  static const QuizScenePreset chessTealScene = QuizScenePreset(
    id: 'chess',
    baseSkyAsset: '$sceneChessTealDir/layer0.png',
    imageAspectRatio: 1480.0 / 619.0,
    fallbackBgColor: Color(0xFF0A4D5E),
    layersBackToFront: [
      QuizSceneLayer(
        levelOrder: 7,
        assetPath: '$sceneChessTealDir/layer7.png',
        labelXFraction: 0.22,
        labelYFraction: 0.175,
        scrollShiftFactor: 0.95,
        entranceSlideDistance: 140.0,
        entranceIntervalStart: 0.00,
        entranceIntervalEnd: 0.72,
      ),
      QuizSceneLayer(
        levelOrder: 6,
        assetPath: '$sceneChessTealDir/layer6.png',
        labelXFraction: 0.58,
        labelYFraction: 0.335,
        scrollShiftFactor: 0.77,
        entranceSlideDistance: 118.0,
        entranceIntervalStart: 0.06,
        entranceIntervalEnd: 0.77,
      ),
      QuizSceneLayer(
        levelOrder: 5,
        assetPath: '$sceneChessTealDir/layer5.png',
        labelXFraction: 0.22,
        labelYFraction: 0.440,
        scrollShiftFactor: 0.54,
        entranceSlideDistance: 96.0,
        entranceIntervalStart: 0.12,
        entranceIntervalEnd: 0.82,
      ),
      QuizSceneLayer(
        levelOrder: 4,
        assetPath: '$sceneChessTealDir/layer4.png',
        labelXFraction: 0.76,
        labelYFraction: 0.555,
        scrollShiftFactor: 0.30,
        entranceSlideDistance: 74.0,
        entranceIntervalStart: 0.18,
        entranceIntervalEnd: 0.87,
      ),
      QuizSceneLayer(
        levelOrder: 3,
        assetPath: '$sceneChessTealDir/layer3.png',
        labelXFraction: 0.85,
        labelYFraction: 0.615,
        scrollShiftFactor: 0.18,
        entranceSlideDistance: 52.0,
        entranceIntervalStart: 0.24,
        entranceIntervalEnd: 0.92,
      ),
      QuizSceneLayer(
        levelOrder: 2,
        assetPath: '$sceneChessTealDir/layer2.png',
        labelXFraction: 0.16,
        labelYFraction: 0.705,
        scrollShiftFactor: 0.05,
        entranceSlideDistance: 30.0,
        entranceIntervalStart: 0.30,
        entranceIntervalEnd: 0.96,
      ),
      QuizSceneLayer(
        levelOrder: 1,
        assetPath: '$sceneChessTealDir/layer1.png',
        labelXFraction: 0.51,
        labelYFraction: 0.848,
        scrollShiftFactor: 0.0,
        entranceSlideDistance: 14.0,
        entranceIntervalStart: 0.35,
        entranceIntervalEnd: 1.00,
      ),
    ],
  );

  /// Planet 1 - Scene 1: Chess Olive (Hijau Zaitun / Emas • 1080 x 2200)
  static const QuizScenePreset chessOliveScene = QuizScenePreset(
    id: 'chess1',
    baseSkyAsset: '$sceneChessOliveDir/layer1dasarlangit.png',
    imageAspectRatio: 2200.0 / 1080.0,
    fallbackBgColor: Color(0xFF4B5335),
    layersBackToFront: [
      QuizSceneLayer(
        levelOrder: 6,
        assetPath: '$sceneChessOliveDir/layer1.5.png',
        labelXFraction: 0.32,
        labelYFraction: 0.095,
        scrollShiftFactor: 0.88,
        entranceSlideDistance: 140.0,
        entranceIntervalStart: 0.00,
        entranceIntervalEnd: 0.72,
      ),
      QuizSceneLayer(
        levelOrder: 5,
        assetPath: '$sceneChessOliveDir/layer1.4.png',
        labelXFraction: 0.38,
        labelYFraction: 0.220,
        scrollShiftFactor: 0.65,
        entranceSlideDistance: 115.0,
        entranceIntervalStart: 0.07,
        entranceIntervalEnd: 0.78,
      ),
      QuizSceneLayer(
        levelOrder: 4,
        assetPath: '$sceneChessOliveDir/layer1.3.png',
        labelXFraction: 0.48,
        labelYFraction: 0.355,
        scrollShiftFactor: 0.44,
        entranceSlideDistance: 90.0,
        entranceIntervalStart: 0.14,
        entranceIntervalEnd: 0.84,
      ),
      QuizSceneLayer(
        levelOrder: 3,
        assetPath: '$sceneChessOliveDir/layer1.2.png',
        labelXFraction: 0.18,
        labelYFraction: 0.445,
        scrollShiftFactor: 0.25,
        entranceSlideDistance: 65.0,
        entranceIntervalStart: 0.21,
        entranceIntervalEnd: 0.90,
      ),
      QuizSceneLayer(
        levelOrder: 2,
        assetPath: '$sceneChessOliveDir/layer1.1.png',
        labelXFraction: 0.80,
        labelYFraction: 0.585,
        scrollShiftFactor: 0.09,
        entranceSlideDistance: 38.0,
        entranceIntervalStart: 0.28,
        entranceIntervalEnd: 0.96,
      ),
      QuizSceneLayer(
        levelOrder: 1,
        assetPath: '$sceneChessOliveDir/layer1.1start.png',
        labelXFraction: 0.50,
        labelYFraction: 0.825,
        scrollShiftFactor: 0.0,
        entranceSlideDistance: 14.0,
        entranceIntervalStart: 0.35,
        entranceIntervalEnd: 1.00,
      ),
    ],
  );

  /// Planet 1 - Scene 2: Chess Ruins (Coklat Emas / Reruntuhan • 1080 x 2200)
  static const QuizScenePreset chessRuinsScene = QuizScenePreset(
    id: 'chess2',
    baseSkyAsset: '$sceneChessRuinsDir/layer2dasarlangit.png',
    imageAspectRatio: 2200.0 / 1080.0,
    fallbackBgColor: Color(0xFF6B6552),
    layersBackToFront: [
      QuizSceneLayer(
        levelOrder: 6,
        assetPath: '$sceneChessRuinsDir/layer2.5.png',
        labelXFraction: 0.31,
        labelYFraction: 0.085,
        scrollShiftFactor: 0.88,
        entranceSlideDistance: 140.0,
        entranceIntervalStart: 0.00,
        entranceIntervalEnd: 0.72,
      ),
      QuizSceneLayer(
        levelOrder: 5,
        assetPath: '$sceneChessRuinsDir/layer2.4.png',
        labelXFraction: 0.82,
        labelYFraction: 0.220,
        scrollShiftFactor: 0.65,
        entranceSlideDistance: 115.0,
        entranceIntervalStart: 0.07,
        entranceIntervalEnd: 0.78,
      ),
      QuizSceneLayer(
        levelOrder: 4,
        assetPath: '$sceneChessRuinsDir/layer2.3.png',
        labelXFraction: 0.32,
        labelYFraction: 0.495,
        scrollShiftFactor: 0.44,
        entranceSlideDistance: 90.0,
        entranceIntervalStart: 0.14,
        entranceIntervalEnd: 0.84,
      ),
      QuizSceneLayer(
        levelOrder: 3,
        assetPath: '$sceneChessRuinsDir/layer2.2.png',
        labelXFraction: 0.82,
        labelYFraction: 0.625,
        scrollShiftFactor: 0.25,
        entranceSlideDistance: 65.0,
        entranceIntervalStart: 0.21,
        entranceIntervalEnd: 0.90,
      ),
      QuizSceneLayer(
        levelOrder: 2,
        assetPath: '$sceneChessRuinsDir/layer2.1.png',
        labelXFraction: 0.24,
        labelYFraction: 0.725,
        scrollShiftFactor: 0.09,
        entranceSlideDistance: 38.0,
        entranceIntervalStart: 0.28,
        entranceIntervalEnd: 0.96,
      ),
      QuizSceneLayer(
        levelOrder: 1,
        assetPath: '$sceneChessRuinsDir/layer2.0start.png',
        labelXFraction: 0.50,
        labelYFraction: 0.865,
        scrollShiftFactor: 0.0,
        entranceSlideDistance: 14.0,
        entranceIntervalStart: 0.35,
        entranceIntervalEnd: 1.00,
      ),
    ],
  );

  /// Planet 2 - Scene 0: Void Ruin (Ungu & Jingga • 1080 x 2200)
  static const QuizScenePreset voidRuinScene = QuizScenePreset(
    id: 'void_ruin',
    baseSkyAsset: '$sceneVoidRuinDir/layer5dasar.png',
    imageAspectRatio: 2200.0 / 1080.0,
    fallbackBgColor: Color(0xFF0F051D),
    layersBackToFront: [
      QuizSceneLayer(
        levelOrder: 6,
        assetPath: '$sceneVoidRuinDir/layer5.5.png',
        labelXFraction: 0.51,
        labelYFraction: 0.115,
        scrollShiftFactor: 0.88,
        entranceSlideDistance: 140.0,
        entranceIntervalStart: 0.00,
        entranceIntervalEnd: 0.72,
      ),
      QuizSceneLayer(
        levelOrder: 5,
        assetPath: '$sceneVoidRuinDir/layer5.4.png',
        labelXFraction: 0.62,
        labelYFraction: 0.215,
        scrollShiftFactor: 0.65,
        entranceSlideDistance: 115.0,
        entranceIntervalStart: 0.07,
        entranceIntervalEnd: 0.78,
      ),
      QuizSceneLayer(
        levelOrder: 4,
        assetPath: '$sceneVoidRuinDir/layer5.3.png',
        labelXFraction: 0.28,
        labelYFraction: 0.355,
        scrollShiftFactor: 0.44,
        entranceSlideDistance: 90.0,
        entranceIntervalStart: 0.14,
        entranceIntervalEnd: 0.84,
      ),
      QuizSceneLayer(
        levelOrder: 3,
        assetPath: '$sceneVoidRuinDir/layer5.2.png',
        labelXFraction: 0.40,
        labelYFraction: 0.505,
        scrollShiftFactor: 0.25,
        entranceSlideDistance: 65.0,
        entranceIntervalStart: 0.21,
        entranceIntervalEnd: 0.90,
      ),
      QuizSceneLayer(
        levelOrder: 2,
        assetPath: '$sceneVoidRuinDir/layer5.1.png',
        labelXFraction: 0.67,
        labelYFraction: 0.635,
        scrollShiftFactor: 0.09,
        entranceSlideDistance: 38.0,
        entranceIntervalStart: 0.28,
        entranceIntervalEnd: 0.96,
      ),
      QuizSceneLayer(
        levelOrder: 1,
        assetPath: '$sceneVoidRuinDir/layer5.0dasar.png',
        labelXFraction: 0.46,
        labelYFraction: 0.855,
        scrollShiftFactor: 0.0,
        entranceSlideDistance: 14.0,
        entranceIntervalStart: 0.35,
        entranceIntervalEnd: 1.00,
      ),
    ],
  );

  /// Planet 3 - Scene 0: Ribbon Castle (Pita Merah & Kastil • 1080 x 2200)
  static const QuizScenePreset ribbonCastleScene = QuizScenePreset(
    id: 'ribbon1',
    baseSkyAsset: '$sceneRibbonCastleDir/layerbackground.png',
    imageAspectRatio: 2200.0 / 1080.0,
    fallbackBgColor: Color(0xFF90B8D8),
    layersBackToFront: [
      QuizSceneLayer(
        levelOrder: 6,
        assetPath: '$sceneRibbonCastleDir/layer4.5.png',
        labelXFraction: 0.52,
        labelYFraction: 0.145,
        scrollShiftFactor: 0.88,
        entranceSlideDistance: 140.0,
        entranceIntervalStart: 0.00,
        entranceIntervalEnd: 0.72,
      ),
      QuizSceneLayer(
        levelOrder: 5,
        assetPath: '$sceneRibbonCastleDir/layer4.4.png',
        labelXFraction: 0.28,
        labelYFraction: 0.440,
        scrollShiftFactor: 0.65,
        entranceSlideDistance: 115.0,
        entranceIntervalStart: 0.07,
        entranceIntervalEnd: 0.78,
      ),
      QuizSceneLayer(
        levelOrder: 4,
        assetPath: '$sceneRibbonCastleDir/layer4.3.png',
        labelXFraction: 0.76,
        labelYFraction: 0.535,
        scrollShiftFactor: 0.44,
        entranceSlideDistance: 90.0,
        entranceIntervalStart: 0.14,
        entranceIntervalEnd: 0.84,
      ),
      QuizSceneLayer(
        levelOrder: 3,
        assetPath: '$sceneRibbonCastleDir/layer4.2.png',
        labelXFraction: 0.20,
        labelYFraction: 0.675,
        scrollShiftFactor: 0.25,
        entranceSlideDistance: 65.0,
        entranceIntervalStart: 0.21,
        entranceIntervalEnd: 0.90,
      ),
      QuizSceneLayer(
        levelOrder: 2,
        assetPath: '$sceneRibbonCastleDir/layer4.1.png',
        labelXFraction: 0.78,
        labelYFraction: 0.725,
        scrollShiftFactor: 0.09,
        entranceSlideDistance: 38.0,
        entranceIntervalStart: 0.28,
        entranceIntervalEnd: 0.96,
      ),
      QuizSceneLayer(
        levelOrder: 1,
        assetPath: '$sceneRibbonCastleDir/layer4.0 dasar.png',
        labelXFraction: 0.44,
        labelYFraction: 0.875,
        scrollShiftFactor: 0.0,
        entranceSlideDistance: 14.0,
        entranceIntervalStart: 0.35,
        entranceIntervalEnd: 1.00,
      ),
    ],
  );

  // ===========================================================================
  // 5. ARRAY UTAMA `planetGroups` (Dicocokkan dengan kolom `mapels.asset`)
  // ===========================================================================
  static const List<QuizPlanetAssetGroup> planetGroups = [
    // Index 0 -> Planet 1: Chess (`mapels.asset = 0`)
    QuizPlanetAssetGroup(
      index: 0,
      id: 'planet_1_chess',
      planetAsset: planet1,
      menuShardAsset: planet1MenuShard,
      handDecorAsset: planet1HandDecor,
      radialBgColor: Color(0xFF053A43),
      scenes: [
        chessTealScene,  // quizzes.asset = 0
        chessOliveScene, // quizzes.asset = 1
        chessRuinsScene, // quizzes.asset = 2
      ],
    ),

    // Index 1 -> Planet 2: Void (`mapels.asset = 1`)
    QuizPlanetAssetGroup(
      index: 1,
      id: 'planet_2_void',
      planetAsset: planet2,
      menuShardAsset: planet1MenuShard,
      handDecorAsset: planet1HandDecor,
      radialBgColor: Color(0xFF1A0B2E),
      scenes: [
        voidRuinScene, // quizzes.asset = 0
      ],
    ),

    // Index 2 -> Planet 3: Ribbon (`mapels.asset = 2`)
    QuizPlanetAssetGroup(
      index: 2,
      id: 'planet_3_ribbon',
      planetAsset: planet3,
      menuShardAsset: planet1MenuShard,
      handDecorAsset: planet1HandDecor,
      radialBgColor: Color(0xFF331832),
      scenes: [
        ribbonCastleScene, // quizzes.asset = 0
      ],
    ),

    // Index 3 -> Planet 4: Sun (`mapels.asset = 3`)
    QuizPlanetAssetGroup(
      index: 3,
      id: 'planet_4_sun',
      planetAsset: planet4,
      menuShardAsset: planet1MenuShard,
      handDecorAsset: planet1HandDecor,
      radialBgColor: Color(0xFF3D1A06),
      scenes: [
        chessRuinsScene, // fallback scene sampai scene khusus Sun ditambahkan
      ],
    ),
  ];

  /// Mengambil `QuizPlanetAssetGroup` berdasarkan kolom `mapels.asset` (index array `planetGroups`).
  static QuizPlanetAssetGroup planetGroupAt(int? assetIndex) {
    if (planetGroups.isEmpty) {
      throw StateError('planetGroups tidak boleh kosong.');
    }
    final idx = (assetIndex == null || assetIndex < 0)
        ? 0
        : (assetIndex % planetGroups.length);
    return planetGroups[idx];
  }

  /// Mencari `QuizPlanetAssetGroup` berdasarkan path `planetImageAsset` atau `assetIndex`.
  static QuizPlanetAssetGroup resolvePlanetGroup({
    int? assetIndex,
    String? planetAsset,
  }) {
    if (assetIndex != null) {
      return planetGroupAt(assetIndex);
    }
    if (planetAsset != null && planetAsset.isNotEmpty) {
      for (final group in planetGroups) {
        if (group.planetAsset == planetAsset ||
            planetAsset.contains(group.id)) {
          return group;
        }
      }
    }
    return planetGroups[0];
  }

  /// Mengambil `QuizScenePreset` berdasarkan `planetAssetIndex` (`mapels.asset`)
  /// dan `quizAssetIndex` (`quizzes.asset`), atau berdasarkan `sceneId` string lama.
  static QuizScenePreset resolveScenePreset({
    int? planetAssetIndex,
    int? quizAssetIndex,
    String? sceneId,
  }) {
    if (planetAssetIndex != null || quizAssetIndex != null) {
      final group = planetGroupAt(planetAssetIndex);
      return group.sceneAt(quizAssetIndex ?? 0);
    }
    switch (sceneId) {
      case 'chess1':
        return chessOliveScene;
      case 'chess2':
        return chessRuinsScene;
      case 'ribbon1':
        return ribbonCastleScene;
      case 'void_ruin':
        return voidRuinScene;
      case 'chess':
      default:
        return chessTealScene;
    }
  }
}
