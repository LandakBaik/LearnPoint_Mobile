import 'package:flutter/material.dart';

import '../../models/quiz_level_model.dart';
import 'quiz_back_header_widget.dart';
import 'quiz_level_node_item_widget.dart';

/// Konfigurasi setiap layer pada background scene QuizLevel.
class _SceneLayerSpec {
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

  const _SceneLayerSpec({
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

/// Konfigurasi satu tema background utuh ('chess', 'chess1', atau 'chess2').
class _QuizLevelScenePreset {
  final String baseSkyAsset;
  final double imageAspectRatio;
  final Color fallbackBgColor;
  final List<_SceneLayerSpec> layersBackToFront;

  const _QuizLevelScenePreset({
    required this.baseSkyAsset,
    required this.imageAspectRatio,
    required this.fallbackBgColor,
    required this.layersBackToFront,
  });
}

class QuizLevelMapSectionWidget extends StatefulWidget {
  final String themeTitle;
  final Color themeColor;
  final String sceneTheme;
  final List<QuizLevelNodeModel> levels;
  final ValueChanged<QuizLevelNodeModel>? onLevelTap;

  const QuizLevelMapSectionWidget({
    super.key,
    required this.themeTitle,
    required this.themeColor,
    this.sceneTheme = 'chess',
    required this.levels,
    this.onLevelTap,
  });

  @override
  State<QuizLevelMapSectionWidget> createState() =>
      _QuizLevelMapSectionWidgetState();
}

class _QuizLevelMapSectionWidgetState extends State<QuizLevelMapSectionWidget>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _entranceController;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0.0);

  // =========================================================================
  // TEMA 1: 'chess' (Biru Teal • 619 x 1480 • layer0 + layer1..layer7)
  // =========================================================================
  static const _QuizLevelScenePreset _chessPreset = _QuizLevelScenePreset(
    baseSkyAsset: 'assets/images/chess/layer0.png',
    imageAspectRatio: 1480.0 / 619.0,
    fallbackBgColor: Color(0xFF0A4D5E),
    layersBackToFront: [
      _SceneLayerSpec(
        levelOrder: 7,
        assetPath: 'assets/images/chess/layer7.png',
        labelXFraction: 0.22,
        labelYFraction: 0.175,
        scrollShiftFactor: 0.95,
        entranceSlideDistance: 140.0,
        entranceIntervalStart: 0.00,
        entranceIntervalEnd: 0.72,
      ),
      _SceneLayerSpec(
        levelOrder: 6,
        assetPath: 'assets/images/chess/layer6.png',
        labelXFraction: 0.58,
        labelYFraction: 0.335,
        scrollShiftFactor: 0.77,
        entranceSlideDistance: 118.0,
        entranceIntervalStart: 0.06,
        entranceIntervalEnd: 0.77,
      ),
      _SceneLayerSpec(
        levelOrder: 5,
        assetPath: 'assets/images/chess/layer5.png',
        labelXFraction: 0.22,
        labelYFraction: 0.440,
        scrollShiftFactor: 0.54,
        entranceSlideDistance: 96.0,
        entranceIntervalStart: 0.12,
        entranceIntervalEnd: 0.82,
      ),
      _SceneLayerSpec(
        levelOrder: 4,
        assetPath: 'assets/images/chess/layer4.png',
        labelXFraction: 0.76,
        labelYFraction: 0.555,
        scrollShiftFactor: 0.30,
        entranceSlideDistance: 74.0,
        entranceIntervalStart: 0.18,
        entranceIntervalEnd: 0.87,
      ),
      _SceneLayerSpec(
        levelOrder: 3,
        assetPath: 'assets/images/chess/layer3.png',
        labelXFraction: 0.85,
        labelYFraction: 0.615,
        scrollShiftFactor: 0.18,
        entranceSlideDistance: 52.0,
        entranceIntervalStart: 0.24,
        entranceIntervalEnd: 0.92,
      ),
      _SceneLayerSpec(
        levelOrder: 2,
        assetPath: 'assets/images/chess/layer2.png',
        labelXFraction: 0.16,
        labelYFraction: 0.705,
        scrollShiftFactor: 0.05,
        entranceSlideDistance: 30.0,
        entranceIntervalStart: 0.30,
        entranceIntervalEnd: 0.96,
      ),
      _SceneLayerSpec(
        levelOrder: 1,
        assetPath: 'assets/images/chess/layer1.png',
        labelXFraction: 0.51,
        labelYFraction: 0.848,
        scrollShiftFactor: 0.0,
        entranceSlideDistance: 14.0,
        entranceIntervalStart: 0.35,
        entranceIntervalEnd: 1.00,
      ),
    ],
  );

  // =========================================================================
  // TEMA 2: 'chess1' (Hijau Zaitun / Emas • 1080 x 2200 • layer1dasarlangit + 6 layer)
  // =========================================================================
  static const _QuizLevelScenePreset _chess1Preset = _QuizLevelScenePreset(
    baseSkyAsset: 'assets/images/chess1/layer1dasarlangit.png',
    imageAspectRatio: 2200.0 / 1080.0,
    fallbackBgColor: Color(0xFF4B5335),
    layersBackToFront: [
      _SceneLayerSpec(
        levelOrder: 6,
        assetPath: 'assets/images/chess1/layer1.5.png',
        // Tepat di atas bidak Ratu pada pedang raksasa paling belakang
        labelXFraction: 0.32,
        labelYFraction: 0.095,
        scrollShiftFactor: 0.88,
        entranceSlideDistance: 140.0,
        entranceIntervalStart: 0.00,
        entranceIntervalEnd: 0.72,
      ),
      _SceneLayerSpec(
        levelOrder: 5,
        assetPath: 'assets/images/chess1/layer1.4.png',
        // Tepat di atas ksatria pemanah / pilar kuda jembatan atas
        labelXFraction: 0.38,
        labelYFraction: 0.220,
        scrollShiftFactor: 0.65,
        entranceSlideDistance: 115.0,
        entranceIntervalStart: 0.07,
        entranceIntervalEnd: 0.78,
      ),
      _SceneLayerSpec(
        levelOrder: 4,
        assetPath: 'assets/images/chess1/layer1.3.png',
        // Tepat di atas ksatria berjubah di antara dua pedang tengah
        labelXFraction: 0.48,
        labelYFraction: 0.355,
        scrollShiftFactor: 0.44,
        entranceSlideDistance: 90.0,
        entranceIntervalStart: 0.14,
        entranceIntervalEnd: 0.84,
      ),
      _SceneLayerSpec(
        levelOrder: 3,
        assetPath: 'assets/images/chess1/layer1.2.png',
        // Tepat di atas bidak Benteng (Rook) di lereng papan catur kiri
        labelXFraction: 0.18,
        labelYFraction: 0.445,
        scrollShiftFactor: 0.25,
        entranceSlideDistance: 65.0,
        entranceIntervalStart: 0.21,
        entranceIntervalEnd: 0.90,
      ),
      _SceneLayerSpec(
        levelOrder: 2,
        assetPath: 'assets/images/chess1/layer1.1.png',
        // Tepat di atas ksatria berpedang di jembatan kanan bawah
        labelXFraction: 0.80,
        labelYFraction: 0.585,
        scrollShiftFactor: 0.09,
        entranceSlideDistance: 38.0,
        entranceIntervalStart: 0.28,
        entranceIntervalEnd: 0.96,
      ),
      _SceneLayerSpec(
        levelOrder: 1,
        assetPath: 'assets/images/chess1/layer1.1start.png',
        // Tepat di atas balkon papan catur paling depan/bawah (FIXED saat di-scroll)
        labelXFraction: 0.50,
        labelYFraction: 0.825,
        scrollShiftFactor: 0.0,
        entranceSlideDistance: 14.0,
        entranceIntervalStart: 0.35,
        entranceIntervalEnd: 1.00,
      ),
    ],
  );

  // =========================================================================
  // TEMA 3: 'chess2' (Coklat Emas / Reruntuhan • 1080 x 2200 • layer2dasarlangit + 5 layer)
  // =========================================================================
  static const _QuizLevelScenePreset _chess2Preset = _QuizLevelScenePreset(
    baseSkyAsset: 'assets/images/chess2/layer2dasarlangit.png',
    imageAspectRatio: 2200.0 / 1080.0,
    fallbackBgColor: Color(0xFF6B6552),
    layersBackToFront: [
      _SceneLayerSpec(
        levelOrder: 5,
        assetPath: 'assets/images/chess2/layer2.5.png',
        // Tepat di atas bola merah menyala pada altar paling atas
        labelXFraction: 0.31,
        labelYFraction: 0.085,
        scrollShiftFactor: 0.85,
        entranceSlideDistance: 135.0,
        entranceIntervalStart: 0.00,
        entranceIntervalEnd: 0.72,
      ),
      _SceneLayerSpec(
        levelOrder: 4,
        assetPath: 'assets/images/chess2/layer2.4.png',
        // Tepat di atas menara tinggi kanan
        labelXFraction: 0.82,
        labelYFraction: 0.220,
        scrollShiftFactor: 0.60,
        entranceSlideDistance: 105.0,
        entranceIntervalStart: 0.08,
        entranceIntervalEnd: 0.79,
      ),
      _SceneLayerSpec(
        levelOrder: 3,
        assetPath: 'assets/images/chess2/layer2.3.png',
        // Tepat di atas jembatan lengkung bertingkat tengah
        labelXFraction: 0.32,
        labelYFraction: 0.495,
        scrollShiftFactor: 0.35,
        entranceSlideDistance: 75.0,
        entranceIntervalStart: 0.16,
        entranceIntervalEnd: 0.86,
      ),
      _SceneLayerSpec(
        levelOrder: 2,
        assetPath: 'assets/images/chess2/layer2.2.png',
        // Tepat di atas bidak catur sisi kanan balkon tengah
        labelXFraction: 0.82,
        labelYFraction: 0.625,
        scrollShiftFactor: 0.12,
        entranceSlideDistance: 42.0,
        entranceIntervalStart: 0.25,
        entranceIntervalEnd: 0.94,
      ),
      _SceneLayerSpec(
        levelOrder: 1,
        assetPath: 'assets/images/chess2/layer2.1.png',
        // Tepat di atas bidak Kuda & Ratu paling depan bawah (FIXED saat di-scroll)
        labelXFraction: 0.24,
        labelYFraction: 0.725,
        scrollShiftFactor: 0.0,
        entranceSlideDistance: 14.0,
        entranceIntervalStart: 0.35,
        entranceIntervalEnd: 1.00,
      ),
    ],
  );

  _QuizLevelScenePreset get _activePreset {
    switch (widget.sceneTheme) {
      case 'chess1':
        return _chess1Preset;
      case 'chess2':
        return _chess2Preset;
      case 'chess':
      default:
        return _chessPreset;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);

    // Animasi gerakan ke atas per-layer saat membuka menu QuizLevel
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    )..forward();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    _scrollOffset.value = _scrollController.offset;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _entranceController.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  QuizLevelNodeModel _levelForOrder(int levelOrder) {
    final targetIndex = (levelOrder - 1).clamp(0, widget.levels.length - 1);
    if (widget.levels.isNotEmpty && targetIndex < widget.levels.length) {
      return widget.levels[targetIndex];
    }
    return QuizLevelNodeModel(
      levelNumber: levelOrder,
      title: 'Level $levelOrder',
      isUnlocked: levelOrder <= 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final preset = _activePreset;
    final activeLayers = preset.layersBackToFront;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        final viewportHeight = constraints.maxHeight;
        // Tinggi asli gambar sesuai proporsi preset agar TIDAK GEPENG
        final nativeImageHeight = viewportWidth * preset.imageAspectRatio;
        // Ruang scroll untuk menggerakkan layer belakang
        final scrollableHeight = viewportHeight + 320.0;

        return ColoredBox(
          color: preset.fallbackBgColor,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Layer Dasar Langit (FIXED, proporsi asli tidak gepeng)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: nativeImageHeight,
                child: Image.asset(
                  preset.baseSkyAsset,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                ),
              ),

              // 2. Layer-Layer Scene dari Belakang ke Depan (Proporsi asli rata bawah)
              AnimatedBuilder(
                animation: Listenable.merge([
                  _entranceController,
                  _scrollOffset,
                ]),
                builder: (context, _) {
                  final scrollValue = _scrollOffset.value.clamp(-120.0, 360.0);

                  return Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: [
                      for (final spec in activeLayers)
                        _buildLayerVisualOnly(
                          spec: spec,
                          nativeImageHeight: nativeImageHeight,
                          scrollValue: scrollValue,
                        ),
                    ],
                  );
                },
              ),

              // 3. Layer Scrollable Transparan (Menangkap gesture scroll & menaruh tombol teks level)
              SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: SizedBox(
                  width: viewportWidth,
                  height: scrollableHeight,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _entranceController,
                      _scrollOffset,
                    ]),
                    builder: (context, _) {
                      final rawScroll = _scrollOffset.value;
                      final clampedScroll = rawScroll.clamp(-120.0, 360.0);

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          for (final spec in activeLayers)
                            _buildLevelTextButton(
                              spec: spec,
                              viewportWidth: viewportWidth,
                              viewportHeight: viewportHeight,
                              nativeImageHeight: nativeImageHeight,
                              rawScroll: rawScroll,
                              clampedScroll: clampedScroll,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // 4. Header Atas (Tombol Kembali & Nama Tema Quiz)
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: QuizBackHeaderWidget(
                  title: widget.themeTitle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLayerVisualOnly({
    required _SceneLayerSpec spec,
    required double nativeImageHeight,
    required double scrollValue,
  }) {
    final entranceCurve = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(
        spec.entranceIntervalStart,
        spec.entranceIntervalEnd,
        curve: Curves.easeOutCubic,
      ),
    );

    final entranceDy = (1.0 - entranceCurve.value) * spec.entranceSlideDistance;
    final scrollDy = scrollValue * spec.scrollShiftFactor;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: nativeImageHeight,
      child: IgnorePointer(
        child: Transform.translate(
          offset: Offset(0, entranceDy + scrollDy),
          child: Image.asset(
            spec.assetPath,
            fit: BoxFit.fitWidth,
            alignment: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  Widget _buildLevelTextButton({
    required _SceneLayerSpec spec,
    required double viewportWidth,
    required double viewportHeight,
    required double nativeImageHeight,
    required double rawScroll,
    required double clampedScroll,
  }) {
    final entranceCurve = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(
        spec.entranceIntervalStart,
        spec.entranceIntervalEnd,
        curve: Curves.easeOutCubic,
      ),
    );

    final entranceDy = (1.0 - entranceCurve.value) * spec.entranceSlideDistance;
    final scrollDy = clampedScroll * spec.scrollShiftFactor;

    final imageTopInViewport = viewportHeight - nativeImageHeight;
    final screenY = imageTopInViewport +
        (nativeImageHeight * spec.labelYFraction) -
        18.0 +
        entranceDy +
        scrollDy;
    final left = (viewportWidth * spec.labelXFraction) - 55.0;
    final levelNode = _levelForOrder(spec.levelOrder);

    return Positioned(
      left: left.clamp(12.0, viewportWidth - 125.0),
      top: screenY + rawScroll,
      child: Opacity(
        opacity: entranceCurve.value.clamp(0.0, 1.0),
        child: QuizLevelNodeItemWidget(
          node: levelNode,
          accentColor: widget.themeColor,
          onTap: () => widget.onLevelTap?.call(levelNode),
        ),
      ),
    );
  }
}
