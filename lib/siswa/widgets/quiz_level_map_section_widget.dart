import 'package:flutter/material.dart';

import '../../models/quiz_level_model.dart';
import 'quiz_back_header_widget.dart';
import 'quiz_level_node_item_widget.dart';

/// Konfigurasi setiap layer pada background chess (layer1 s/d layer7).
/// Urutan tumpukan: nomor paling kecil berada di layer paling atas (depan),
/// sedangkan layer0 berada paling dasar (fixed).
class _ChessLayerSpec {
  final int layerNumber;
  final String assetPath;
  final double labelXFraction;
  final double labelYFraction;
  // Seberapa banyak layer ini turun ke bawah ketika di-scroll (0.0 = fixed seperti layer1)
  final double scrollShiftFactor;
  // Jarak muncul dari bawah ke atas saat transisi membuka menu QuizLevel
  final double entranceSlideDistance;
  final double entranceIntervalStart;
  final double entranceIntervalEnd;

  const _ChessLayerSpec({
    required this.layerNumber,
    required this.assetPath,
    required this.labelXFraction,
    required this.labelYFraction,
    required this.scrollShiftFactor,
    required this.entranceSlideDistance,
    required this.entranceIntervalStart,
    required this.entranceIntervalEnd,
  });
}

class QuizLevelMapSectionWidget extends StatefulWidget {
  final String themeTitle;
  final Color themeColor;
  final List<QuizLevelNodeModel> levels;
  final ValueChanged<QuizLevelNodeModel>? onLevelTap;

  const QuizLevelMapSectionWidget({
    super.key,
    required this.themeTitle,
    required this.themeColor,
    required this.levels,
    this.onLevelTap,
  });

  @override
  State<QuizLevelMapSectionWidget> createState() =>
      _QuizLevelMapSectionWidgetState();
}

class _QuizLevelMapSectionWidgetState extends State<QuizLevelMapSectionWidget>
    with SingleTickerProviderStateMixin {
  // Rasio asli gambar di assets/images/chess/ adalah 619 x 1480
  static const double _imageAspectRatio = 1480.0 / 619.0;

  late final ScrollController _scrollController;
  late final AnimationController _entranceController;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0.0);

  // Urutan dari belakang (layer7) ke paling depan/atas (layer1):
  // - layer1: FIXED (scrollShiftFactor = 0.0)
  // - layer2: turun dikit saat di-scroll
  // - layer3: turun agak lebih dari layer2
  // - dst sampai layer7 turun paling banyak
  static const List<_ChessLayerSpec> _layersBackToFront = [
    _ChessLayerSpec(
      layerNumber: 7,
      assetPath: 'assets/images/chess/layer7.png',
      // Di atas kastil kiri / patung kuda catur raksasa
      labelXFraction: 0.22,
      labelYFraction: 0.175,
      scrollShiftFactor: 0.95,
      entranceSlideDistance: 140.0,
      entranceIntervalStart: 0.00,
      entranceIntervalEnd: 0.72,
    ),
    _ChessLayerSpec(
      layerNumber: 6,
      assetPath: 'assets/images/chess/layer6.png',
      // Tepat di atas gagang pedang & bukit tengah
      labelXFraction: 0.58,
      labelYFraction: 0.335,
      scrollShiftFactor: 0.77,
      entranceSlideDistance: 118.0,
      entranceIntervalStart: 0.06,
      entranceIntervalEnd: 0.77,
    ),
    _ChessLayerSpec(
      layerNumber: 5,
      assetPath: 'assets/images/chess/layer5.png',
      // Tepat di atas puncak menara kastil kiri
      labelXFraction: 0.22,
      labelYFraction: 0.440,
      scrollShiftFactor: 0.54,
      entranceSlideDistance: 96.0,
      entranceIntervalStart: 0.12,
      entranceIntervalEnd: 0.82,
    ),
    _ChessLayerSpec(
      layerNumber: 4,
      assetPath: 'assets/images/chess/layer4.png',
      // Tepat di atas benteng kanan-tengah
      labelXFraction: 0.76,
      labelYFraction: 0.555,
      scrollShiftFactor: 0.30,
      entranceSlideDistance: 74.0,
      entranceIntervalStart: 0.18,
      entranceIntervalEnd: 0.87,
    ),
    _ChessLayerSpec(
      layerNumber: 3,
      assetPath: 'assets/images/chess/layer3.png',
      // Tepat di atas kubah menara hijau di sisi kanan (turun agak lebih dari layer2)
      labelXFraction: 0.85,
      labelYFraction: 0.615,
      scrollShiftFactor: 0.18,
      entranceSlideDistance: 52.0,
      entranceIntervalStart: 0.24,
      entranceIntervalEnd: 0.92,
    ),
    _ChessLayerSpec(
      layerNumber: 2,
      assetPath: 'assets/images/chess/layer2.png',
      // Tepat di atas menara jembatan kiri bawah (turun dikit)
      labelXFraction: 0.16,
      labelYFraction: 0.705,
      scrollShiftFactor: 0.05,
      entranceSlideDistance: 30.0,
      entranceIntervalStart: 0.30,
      entranceIntervalEnd: 0.96,
    ),
    _ChessLayerSpec(
      layerNumber: 1,
      assetPath: 'assets/images/chess/layer1.png',
      // Tepat di atas siluet karakter di daratan paling depan (Layer 1 FIXED saat scroll)
      labelXFraction: 0.51,
      labelYFraction: 0.848,
      scrollShiftFactor: 0.0,
      entranceSlideDistance: 14.0,
      entranceIntervalStart: 0.35,
      entranceIntervalEnd: 1.00,
    ),
  ];

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

  QuizLevelNodeModel _levelForLayer(int layerNumber) {
    final targetIndex = (layerNumber - 1).clamp(0, widget.levels.length - 1);
    if (widget.levels.isNotEmpty && targetIndex < widget.levels.length) {
      return widget.levels[targetIndex];
    }
    return QuizLevelNodeModel(
      levelNumber: layerNumber,
      title: 'Level $layerNumber',
      isUnlocked: layerNumber <= 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        final viewportHeight = constraints.maxHeight;
        // Tinggi asli gambar sesuai proporsi 619x1480 agar TIDAK GEPENG
        final nativeImageHeight = viewportWidth * _imageAspectRatio;
        // Ruang scroll untuk menggerakkan layer2..layer7
        final scrollableHeight = viewportHeight + 320.0;

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Layer 0: Background warna utama & langit (FIXED, proporsi asli tidak gepeng)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: nativeImageHeight,
              child: Image.asset(
                'assets/images/chess/layer0.png',
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
              ),
            ),

            // 2. Layer 7 s/d Layer 1 (Proporsi asli 619x1480 rata bawah, tidak gepeng)
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
                    for (final spec in _layersBackToFront)
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
                        for (final spec in _layersBackToFront)
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
        );
      },
    );
  }

  /// Menggambar gambar PNG per-layer dengan proporsi asli (nativeImageHeight):
  /// - layer1 memiliki scrollShiftFactor = 0.0 -> tetap FIXED di tempatnya
  /// - layer2..layer7 turun ke bawah secara bertingkat saat di-scroll
  Widget _buildLayerVisualOnly({
    required _ChessLayerSpec spec,
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

  /// Menempatkan teks level tepat mengikuti posisi objek pada ukuran asli gambar (nativeImageHeight).
  Widget _buildLevelTextButton({
    required _ChessLayerSpec spec,
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

    // Karena gambar di-anchor di bottom: 0 dengan tinggi nativeImageHeight,
    // titik atas gambar berada di (viewportHeight - nativeImageHeight).
    final imageTopInViewport = viewportHeight - nativeImageHeight;
    final screenY = imageTopInViewport +
        (nativeImageHeight * spec.labelYFraction) -
        18.0 +
        entranceDy +
        scrollDy;
    final left = (viewportWidth * spec.labelXFraction) - 55.0;
    final levelNode = _levelForLayer(spec.layerNumber);

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
