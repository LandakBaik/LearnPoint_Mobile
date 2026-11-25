import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/features/siswa/quiz/config/quiz_assets.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/quiz_level_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_back_header_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_level_node_item_widget.dart';

class QuizLevelMapSectionWidget extends StatefulWidget {
  final String themeTitle;
  final Color themeColor;
  final QuizScenePreset? scenePreset;
  final String sceneTheme;
  final List<QuizLevelNodeModel> levels;
  final ValueChanged<QuizLevelNodeModel>? onLevelTap;

  const QuizLevelMapSectionWidget({
    super.key,
    required this.themeTitle,
    required this.themeColor,
    this.scenePreset,
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

  QuizScenePreset get _activePreset =>
      widget.scenePreset ??
      QuizAssets.resolveScenePreset(sceneId: widget.sceneTheme);

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
    required QuizSceneLayer spec,
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
    required QuizSceneLayer spec,
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
