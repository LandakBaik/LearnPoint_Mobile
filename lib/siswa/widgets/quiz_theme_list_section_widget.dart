import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../models/materi_page.dart';
import '../../models/quiz_per_mapel.dart';
import 'quiz_planet_center_widget.dart';
import 'quiz_planet_wavy_rings_widget.dart';
import 'quiz_radial_menu_shard_widget.dart';

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

class _QuizThemeListSectionWidgetState
    extends State<QuizThemeListSectionWidget> {
  // Sudut putaran roda saat ini (dalam derajat)
  double _wheelRotationDeg = 0.0;

  // Menyimpan sudut jari terakhir saat drag melingkar
  double? _lastPanAngleRad;

  // Jarak sudut antar item menu (dalam derajat)
  static const double _itemStepDeg = 38.0;

  // Batas sudut kosong di bagian bawah (200° sampai 340°)
  static const double _emptyZoneStartStandardDeg = 200.0;
  static const double _emptyZoneEndStandardDeg = 340.0;
  static const double _fadeZoneDeg = 18.0;

  double _normalizeDeg(double deg) {
    double res = deg % 360.0;
    if (res < 0) res += 360.0;
    return res;
  }

  /// Menghitung opacity (0.0 - 1.0) berdasarkan sudut matematika standar
  /// (0° = Kanan, 90° = Atas, 180° = Kiri, 270° = Bawah).
  /// Area 200° sampai 340° dikosongkan (menghilang).
  double _calculateVisibility(double standardDeg) {
    final norm = _normalizeDeg(standardDeg);

    // Jika berada di dalam zona kosong (200° s/d 340°)
    if (norm > _emptyZoneStartStandardDeg && norm < _emptyZoneEndStandardDeg) {
      return 0.0;
    }

    // Efek transisi memudar (fade-out / fade-in) di dekat batas 200° dan 340°
    if (norm <= _emptyZoneStartStandardDeg &&
        norm > _emptyZoneStartStandardDeg - _fadeZoneDeg) {
      return (_emptyZoneStartStandardDeg - norm) / _fadeZoneDeg;
    }
    if (norm >= _emptyZoneEndStandardDeg &&
        norm < _emptyZoneEndStandardDeg + _fadeZoneDeg) {
      return (norm - _emptyZoneEndStandardDeg) / _fadeZoneDeg;
    }

    return 1.0;
  }

  void _onPanStart(DragStartDetails details, Offset center) {
    final dx = details.localPosition.dx - center.dx;
    final dy = center.dy - details.localPosition.dy;
    _lastPanAngleRad = math.atan2(dy, dx);
  }

  void _onPanUpdate(DragUpdateDetails details, Offset center) {
    final dx = details.localPosition.dx - center.dx;
    final dy = center.dy - details.localPosition.dy;
    final currentAngleRad = math.atan2(dy, dx);

    if (_lastPanAngleRad != null) {
      double deltaRad = currentAngleRad - _lastPanAngleRad!;
      if (deltaRad > math.pi) deltaRad -= 2 * math.pi;
      if (deltaRad < -math.pi) deltaRad += 2 * math.pi;

      final deltaDeg = deltaRad * 180.0 / math.pi;

      setState(() {
        final totalSpan = (widget.themes.length - 1) * _itemStepDeg;
        final minRot = -totalSpan;
        final maxRot = totalSpan;
        _wheelRotationDeg =
            (_wheelRotationDeg + deltaDeg).clamp(minRot, maxRot);
      });
    }

    _lastPanAngleRad = currentAngleRad;
  }

  void _onPanEnd(DragEndDetails details) {
    _lastPanAngleRad = null;
  }

  /// Deteksi klik berdasarkan koordinat sentuhan di layar agar tidak gagal
  /// akibat Transform.rotate pada widget di dalam Stack.
  void _handleTapUp(
    TapUpDetails details, {
    required Offset center,
    required double planetRadius,
    required double shardGap,
    required double shardWidth,
    required double shardHeight,
  }) {
    if (widget.onThemeTap == null) return;

    final tapPos = details.localPosition;
    final minRadius = planetRadius + shardGap * 0.5;
    final maxRadius = planetRadius + shardGap + shardWidth + 10.0;

    final dx = tapPos.dx - center.dx;
    final dy = tapPos.dy - center.dy;
    final distFromCenter = math.sqrt(dx * dx + dy * dy);

    // Abaikan jika klik tepat di tengah planet atau terlalu jauh di luar menu
    if (distFromCenter < minRadius || distFromCenter > maxRadius) {
      return;
    }

    for (int i = 0; i < widget.themes.length; i++) {
      final double baseStandardDeg = 185.0 - (i * _itemStepDeg);
      final double currentStandardDeg = baseStandardDeg + _wheelRotationDeg;
      final double visibility = _calculateVisibility(currentStandardDeg);

      if (visibility <= 0.15) continue;

      final double normDeg = _normalizeDeg(currentStandardDeg);
      final double screenAngleRad = -(normDeg * math.pi / 180.0);

      // Transformasi titik tap ke sistem koordinat lokal bilah menu ke-i
      final double distanceToShardCenter =
          planetRadius + shardGap + (shardWidth / 2);
      final double itemCenterX =
          center.dx + distanceToShardCenter * math.cos(screenAngleRad);
      final double itemCenterY =
          center.dy + distanceToShardCenter * math.sin(screenAngleRad);

      final double relX = tapPos.dx - itemCenterX;
      final double relY = tapPos.dy - itemCenterY;

      // Putar balik sebesar -screenAngleRad untuk mengecek apakah masuk kotak shardWidth x shardHeight
      final double cosA = math.cos(-screenAngleRad);
      final double sinA = math.sin(-screenAngleRad);
      final double localX = relX * cosA - relY * sinA;
      final double localY = relX * sinA + relY * cosA;

      if (localX.abs() <= (shardWidth / 2) + 6.0 &&
          localY.abs() <= (shardHeight / 2) + 6.0) {
        widget.onThemeTap!(widget.themes[i]);
        return;
      }
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
          constraints.maxHeight * 0.50,
        );

        // Ukuran planet di tengah dan ukuran bilah menu
        final double planetSize =
            (constraints.maxWidth * 0.42).clamp(145.0, 190.0);
        final double planetRadius = planetSize / 2;
        const double shardGap = 6.0;
        final double shardWidth =
            (constraints.maxWidth * 0.31).clamp(110.0, 142.0);
        const double shardHeight = 58.0;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (d) => _onPanStart(d, center),
          onPanUpdate: (d) => _onPanUpdate(d, center),
          onPanEnd: _onPanEnd,
          onTapUp: (d) => _handleTapUp(
            d,
            center: center,
            planetRadius: planetRadius,
            shardGap: shardGap,
            shardWidth: shardWidth,
            shardHeight: shardHeight,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Petunjuk interaksi putar di bagian bawah (area kosong 200° - 340°)
            //   Positioned(
            //     left: 24,
            //     right: 24,
            //     bottom: 32,
            //     child: Column(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Icon(
            //           Icons.swipe_rounded,
            //           color: Colors.cyanAccent.withValues(alpha: 0.45),
            //           size: 26,
            //         ),
            //         const SizedBox(height: 6),
            //         Text(
            //           'Putar sekeliling planet untuk melihat tema lainnya',
            //           textAlign: TextAlign.center,
            //           style: TextStyle(
            //             color: Colors.white.withValues(alpha: 0.55),
            //             fontSize: 12,
            //             fontWeight: FontWeight.w500,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),

              // 2. Daftar Pilihan Menu di Sekeliling Lingkaran
              for (int i = 0; i < widget.themes.length; i++)
                _buildRadialShardItem(
                  index: i,
                  item: widget.themes[i],
                  center: center,
                  planetRadius: planetRadius,
                  shardGap: shardGap,
                  shardWidth: shardWidth,
                  shardHeight: shardHeight,
                ),

              // 3. Animasi 2 Garis Melingkar Bergelombang di Belakang Planet
              Positioned(
                left: center.dx - (planetSize * 1.35) / 2,
                top: center.dy - (planetSize * 1.35) / 2,
                child: IgnorePointer(
                  child: QuizPlanetWavyRingsWidget(
                    planetSize: planetSize,
                  ),
                ),
              ),

              // 4. Lingkaran Tengah (Planet Mapel dari halaman Quiz)
              Positioned(
                left: center.dx - planetRadius,
                top: center.dy - planetRadius,
                width: planetSize,
                height: planetSize,
                child: Hero(
                  tag: heroTag,
                  child: QuizPlanetCenterWidget(
                    title: formattedSubject,
                    baseColor: planetColor,
                    imageAsset: widget.subject?.planetImageAsset,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRadialShardItem({
    required int index,
    required QuizPerMapelM item,
    required Offset center,
    required double planetRadius,
    required double shardGap,
    required double shardWidth,
    required double shardHeight,
  }) {
    final double baseStandardDeg = 185.0 - (index * _itemStepDeg);
    final double currentStandardDeg = baseStandardDeg + _wheelRotationDeg;
    final double visibility = _calculateVisibility(currentStandardDeg);

    // Jika berada di zona kosong (200° - 340°), sembunyikan sepenuhnya
    if (visibility <= 0.01) {
      return const SizedBox.shrink();
    }

    final double normDeg = _normalizeDeg(currentStandardDeg);
    final double standardRad = normDeg * math.pi / 180.0;

    // Di layar Flutter, sumbu Y ke bawah adalah positif, jadi sudut layar = -standardRad
    final double screenAngleRad = -standardRad;

    final double distanceToShardCenter =
        planetRadius + shardGap + (shardWidth / 2);

    final double itemCenterX =
        center.dx + distanceToShardCenter * math.cos(screenAngleRad);
    final double itemCenterY =
        center.dy + distanceToShardCenter * math.sin(screenAngleRad);

    // Cek apakah bilah berada di belahan kiri lingkaran (90° < normDeg < 270°)
    final bool isLeftHalf = normDeg > 90.0 && normDeg < 270.0;

    return Positioned(
      left: itemCenterX - (shardWidth / 2),
      top: itemCenterY - (shardHeight / 2),
      width: shardWidth,
      height: shardHeight,
      child: Opacity(
        opacity: visibility.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.75 + (0.25 * visibility),
          child: Transform.rotate(
            angle: screenAngleRad,
            alignment: Alignment.center,
            child: QuizRadialMenuShardWidget(
              item: item,
              variantIndex: index % 3,
              isTextFlipped: isLeftHalf,
            ),
          ),
        ),
      ),
    );
  }
}
