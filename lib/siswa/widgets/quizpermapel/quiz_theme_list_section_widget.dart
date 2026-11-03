import 'package:flutter/material.dart';

import '../../../models/materi_page.dart';
import '../../../models/quiz_per_mapel.dart';
import '../../quizLevel.dart';
import 'quiz_planet_center_widget.dart';
import 'quiz_planet_wavy_rings_widget.dart';
import 'quiz_radial_menu_items_layer_widget.dart';
import 'quiz_radial_pagination_controls_widget.dart';
import 'quiz_sword_stab_light_overlay_widget.dart';

class QuizThemeListSectionWidget extends StatefulWidget {
  final MateriModel? subject;
  final String subjectTitle;
  final List<QuizPerMapelM> themes;
  final ValueChanged<QuizPerMapelM>? onThemeTap;

  const QuizThemeListSectionWidget({
    super.key,
    this.subject,
    required this.subjectTitle,
    required this.themes,
    this.onThemeTap,
  });

  @override
  State<QuizThemeListSectionWidget> createState() =>
      _QuizThemeListSectionWidgetState();
}

class _QuizThemeListSectionWidgetState extends State<QuizThemeListSectionWidget>
    with SingleTickerProviderStateMixin {
  static const int _itemsPerPage = 6;
  int _currentPage = 0;

  // State untuk animasi pedang menancap & cahaya membesar sebelum pindah halaman
  late final AnimationController _stabTransitionController;
  int? _stabbingSlotIndex;

  @override
  void initState() {
    super.initState();
    // Durasi 1800ms (1.8 detik) agar animasi menancap dan cahaya membesar terasa dramatis & tidak terlalu cepat
    _stabTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _stabTransitionController.dispose();
    super.dispose();
  }

  int get _totalPages =>
      (widget.themes.length / _itemsPerPage).ceil().clamp(1, 999);

  List<QuizPerMapelM> get _currentPageItems {
    final startIndex = _currentPage * _itemsPerPage;
    if (startIndex >= widget.themes.length) return const [];
    final endIndex =
        (startIndex + _itemsPerPage).clamp(0, widget.themes.length);
    return widget.themes.sublist(startIndex, endIndex);
  }

  void _goToPreviousPage() {
    if (_stabbingSlotIndex != null) return;
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _goToNextPage() {
    if (_stabbingSlotIndex != null) return;
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }

  Future<void> _handleSlotTap(int slotIndex, QuizPerMapelM item) async {
    if (_stabbingSlotIndex != null) return;

    setState(() {
      _stabbingSlotIndex = slotIndex;
    });

    // Jalankan animasi pedang menancap -> cahaya semakin terang memenuhi layar
    await _stabTransitionController.forward(from: 0.0);

    if (!mounted) return;

    // Pindah ke halaman QuizLevel dengan transisi fade halus dari layar bercahaya
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            QuizLevel(themeItem: item),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );

    // Reset posisi pedang & cahaya saat user menekan tombol Back dari QuizLevel
    if (mounted) {
      _stabTransitionController.reset();
      setState(() {
        _stabbingSlotIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedSubject = widget.subjectTitle.isNotEmpty
        ? '${widget.subjectTitle[0].toUpperCase()}${widget.subjectTitle.substring(1)}'
        : widget.subjectTitle;

    final planetColor =
        widget.subject?.iconColor ?? const Color(0xFF2DD4BF);
    final heroTag =
        'quiz_planet_${widget.subject?.materi ?? widget.subjectTitle}';

    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(
          constraints.maxWidth / 2,
          constraints.maxHeight * 0.46,
        );

        // Ukuran planet di tengah dan ukuran bilah menu
        final double planetSize =
            (constraints.maxWidth * 0.42).clamp(150.0, 220.0);
        final double planetRadius = planetSize / 2;
        const double shardGap = 8.0;
        final double shardWidth =
            (constraints.maxWidth * 0.30).clamp(110.0, 155.0);
        const double shardHeight = 60.0;

        return AnimatedBuilder(
          animation: _stabTransitionController,
          builder: (context, _) {
            final stabProgress = _stabTransitionController.value;

            // Faktor meredupkan planet & elemen sekitar saat pedang sudah menancap (0.42 -> 1.0)
            final dimFactor = stabProgress <= 0.42
                ? 0.0
                : ((stabProgress - 0.42) / 0.58).clamp(0.0, 1.0);
            final contentOpacity = (1.0 - dimFactor * 0.85).clamp(0.0, 1.0);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Layer 6 Pilihan Menu di Sekeliling Planet
                Positioned.fill(
                  child: Opacity(
                    opacity: contentOpacity,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: QuizRadialMenuItemsLayerWidget(
                        key: ValueKey<int>(_currentPage),
                        currentItems: _currentPageItems,
                        center: center,
                        planetRadius: planetRadius,
                        shardGap: shardGap,
                        shardWidth: shardWidth,
                        shardHeight: shardHeight,
                        stabbingSlotIndex: _stabbingSlotIndex,
                        stabProgress: stabProgress,
                        onSlotTap: _handleSlotTap,
                      ),
                    ),
                  ),
                ),

                // 2. Animasi 2 Garis Melingkar Bergelombang di Belakang Planet
                Positioned(
                  left: center.dx - (planetSize * 1.35) / 2,
                  top: center.dy - (planetSize * 1.35) / 2,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: contentOpacity,
                      child: QuizPlanetWavyRingsWidget(
                        planetSize: planetSize,
                      ),
                    ),
                  ),
                ),

                // 3. Lingkaran Tengah (Planet Mapel dari halaman Quiz)
                Positioned(
                  left: center.dx - planetRadius,
                  top: center.dy - planetRadius,
                  width: planetSize,
                  height: planetSize,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: contentOpacity,
                      child: Hero(
                        tag: heroTag,
                        child: QuizPlanetCenterWidget(
                          title: formattedSubject,
                          baseColor: planetColor,
                          imageAsset: widget.subject?.planetImageAsset,
                        ),
                      ),
                    ),
                  ),
                ),

                // 4. Tombol Previous & Next di Bagian Bawah
                if (_totalPages > 1)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 28,
                    child: Opacity(
                      opacity: (1.0 - (stabProgress * 2.5)).clamp(0.0, 1.0),
                      child: Center(
                        child: QuizRadialPaginationControlsWidget(
                          currentPage: _currentPage,
                          totalPages: _totalPages,
                          onPrevious: _goToPreviousPage,
                          onNext: _goToNextPage,
                        ),
                      ),
                    ),
                  ),

                // 5. Overlay Cahaya Membesar dari Titik Pedang Menancap hingga Memenuhi Layar
                if (_stabbingSlotIndex != null)
                  Positioned.fill(
                    child: QuizSwordStabLightOverlayWidget(
                      progress: stabProgress,
                      center:
                          QuizRadialMenuItemsLayerWidget.calculateStabImpactOffset(
                        slotIndex: _stabbingSlotIndex!,
                        center: center,
                        planetRadius: planetRadius,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
