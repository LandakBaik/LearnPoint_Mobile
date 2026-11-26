import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/features/siswa/quiz/config/quiz_assets.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/quiz_level_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_back_header_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_level_node_item_widget.dart';

class QuizLevelMapSectionWidget extends StatefulWidget {
  static const int maxLevelsPerDifficulty = 5;

  final String themeTitle;
  final Color themeColor;
  final QuizScenePreset? scenePreset;
  final String sceneTheme;
  final List<QuizLevelNodeModel> levels;
  final String currentDifficulty;
  final List<String> activeDifficulties;
  final String? nextDifficulty;
  final bool isNextDifficultyUnlocked;
  final ValueChanged<String>? onSelectDifficulty;
  final VoidCallback? onNextDifficultyTap;
  final ValueChanged<QuizLevelNodeModel>? onLevelTap;

  const QuizLevelMapSectionWidget({
    super.key,
    required this.themeTitle,
    required this.themeColor,
    this.scenePreset,
    this.sceneTheme = 'chess',
    required this.levels,
    this.currentDifficulty = 'Mudah',
    this.activeDifficulties = const ['Mudah', 'Sedang', 'Sulit'],
    this.nextDifficulty,
    this.isNextDifficultyUnlocked = false,
    this.onSelectDifficulty,
    this.onNextDifficultyTap,
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
    final targetIndex = (levelOrder - 1).clamp(
      0,
      QuizLevelMapSectionWidget.maxLevelsPerDifficulty - 1,
    );
    if (widget.levels.isNotEmpty && targetIndex < widget.levels.length) {
      return widget.levels[targetIndex];
    }
    return QuizLevelNodeModel.lockedEmpty(
      arc: widget.currentDifficulty,
      levelNum: levelOrder,
    );
  }

  Color _difficultyBadgeColor(String diff) {
    switch (diff.toLowerCase()) {
      case 'sedang':
        return const Color(0xFFD97706);
      case 'sulit':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF059669);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preset = _activePreset;
    final activeLayers = preset.layersBackToFront;
    // Hanya tampilkan tombol node untuk Level 1 s/d Level 5
    final levelButtonLayers = activeLayers
        .where(
          (spec) =>
              spec.levelOrder >= 1 &&
              spec.levelOrder <=
                  QuizLevelMapSectionWidget.maxLevelsPerDifficulty,
        )
        .toList();

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

              // 3. Layer Scrollable Transparan (Menangkap gesture scroll & menaruh 5 tombol level)
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
                          for (final spec in levelButtonLayers)
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

              // 4. Header Atas (Tombol Kembali, Nama Tema Quiz, & Pilihan Difficulty)
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QuizBackHeaderWidget(
                      title: widget.themeTitle,
                      trailing: _buildCurrentDifficultyBadge(),
                    ),
                    if (widget.activeDifficulties.length > 1)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                        child: _buildDifficultyTabs(),
                      ),
                  ],
                ),
              ),

              // 5. Tombol "Difficulty Lanjutan" di Bagian Bawah
              if (widget.nextDifficulty != null)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 24,
                  child: _buildNextDifficultyButton(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentDifficultyBadge() {
    final badgeColor = _difficultyBadgeColor(widget.currentDifficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Text(
        'Difficulty: ${widget.currentDifficulty}',
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDifficultyTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.20),
          width: 1.2,
        ),
      ),
      child: Row(
        children: widget.activeDifficulties.map((diff) {
          final isSelected =
              diff.toLowerCase() == widget.currentDifficulty.toLowerCase();
          final activeColor = _difficultyBadgeColor(diff);

          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onSelectDifficulty?.call(diff),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  diff,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNextDifficultyButton() {
    final nextDiff = widget.nextDifficulty!;
    final unlocked = widget.isNextDifficultyUnlocked;
    final nextColor = _difficultyBadgeColor(nextDiff);

    return SafeArea(
      top: false,
      child: Center(
        child: GestureDetector(
          onTap: widget.onNextDifficultyTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: unlocked
                    ? [
                        nextColor,
                        nextColor.withValues(alpha: 0.85),
                      ]
                    : [
                        const Color(0xFF1E293B).withValues(alpha: 0.90),
                        const Color(0xFF0F172A).withValues(alpha: 0.90),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: unlocked
                    ? Colors.white.withValues(alpha: 0.75)
                    : Colors.white.withValues(alpha: 0.28),
                width: 1.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: unlocked
                      ? nextColor.withValues(alpha: 0.45)
                      : Colors.black.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  unlocked
                      ? Icons.rocket_launch_rounded
                      : Icons.lock_outline_rounded,
                  size: 17,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'Difficulty Lanjutan: $nextDiff',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
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
