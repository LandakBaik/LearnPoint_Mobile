/// Sentralisasi seluruh path aset untuk fitur Quiz & Gacha.
/// Dikelompokkan berdasarkan Lobby Parallax, Gacha, dan Tema Masing-Masing Planet.
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
  // 3. PLANET 1: CHESS THEME (`assets/images/quiz/planets/planet_1_chess/`)
  // ===========================================================================
  static const String _planet1Dir =
      'assets/images/quiz/planets/planet_1_chess';
  static const String planet1 = '$_planet1Dir/planet.png';
  static const String planet1MenuShard = '$_planet1Dir/menu_shard.png';
  static const String planet1HandDecor = '$_planet1Dir/hand_decor.png';

  static const String sceneChessTealDir = '$_planet1Dir/scenes/chess_teal';
  static const String sceneChessOliveDir = '$_planet1Dir/scenes/chess_olive';
  static const String sceneChessRuinsDir = '$_planet1Dir/scenes/chess_ruins';

  // ===========================================================================
  // 4. PLANET 2: VOID THEME (`assets/images/quiz/planets/planet_2_void/`)
  // ===========================================================================
  static const String _planet2Dir = 'assets/images/quiz/planets/planet_2_void';
  static const String planet2 = '$_planet2Dir/planet.png';

  static const String sceneVoidRuinDir = '$_planet2Dir/scenes/void_ruin';

  // ===========================================================================
  // 5. PLANET 3: RIBBON THEME (`assets/images/quiz/planets/planet_3_ribbon/`)
  // ===========================================================================
  static const String _planet3Dir =
      'assets/images/quiz/planets/planet_3_ribbon';
  static const String planet3 = '$_planet3Dir/planet.png';

  static const String sceneRibbonCastleDir =
      '$_planet3Dir/scenes/ribbon_castle';

  // ===========================================================================
  // 6. PLANET 4: SUN THEME (`assets/images/quiz/planets/planet_4_sun/`)
  // ===========================================================================
  static const String _planet4Dir = 'assets/images/quiz/planets/planet_4_sun';
  static const String planet4 = '$_planet4Dir/planet.png';

  /// Mengecek apakah path gambar planet menggunakan tema Planet 2 (Void).
  static bool isPlanet2Void(String? planetAsset) {
    if (planetAsset == null || planetAsset.isEmpty) return false;
    return planetAsset.contains('planet_2_void') ||
        planetAsset.contains('planet2');
  }

  /// Mengecek apakah path gambar planet menggunakan tema Planet 3 (Ribbon).
  static bool isPlanet3Ribbon(String? planetAsset) {
    if (planetAsset == null || planetAsset.isEmpty) return false;
    return planetAsset.contains('planet_3_ribbon') ||
        planetAsset.contains('planet3');
  }

  /// Menentukan sceneTheme override berdasarkan planet yang sedang dipilih.
  static String? resolveSceneThemeForPlanet(String? planetAsset) {
    if (isPlanet2Void(planetAsset)) return 'void_ruin';
    if (isPlanet3Ribbon(planetAsset)) return 'ribbon1';
    return null;
  }
}
