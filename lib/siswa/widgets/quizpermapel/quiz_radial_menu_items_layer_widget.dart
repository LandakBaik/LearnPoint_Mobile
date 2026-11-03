import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../models/quiz_per_mapel.dart';
import 'quiz_radial_menu_shard_widget.dart';

/// Widget khusus yang menampilkan hingga 6 pilihan tema di sekeliling planet
/// serta menganimasikan pedang yang dipilih agar menancap ke dalam planet.
class QuizRadialMenuItemsLayerWidget extends StatelessWidget {
  final List<QuizPerMapelM> currentItems;
  final Offset center;
  final double planetRadius;
  final double shardGap;
  final double shardWidth;
  final double shardHeight;
  final int? stabbingSlotIndex;
  final double stabProgress;
  final void Function(int slotIndex, QuizPerMapelM item)? onSlotTap;

  // Sudut tetap (dalam derajat matematika standar: 0° = Kanan, 90° = Atas, 180° = Kiri)
  // untuk maksimal 6 pilihan di sekeliling planet:
  // Digeser lebih ke atas agar bagian bawah (background tangan) tidak tertutup pedang.
  static const List<double> slotAnglesDeg = [
    118.0, // Kiri Paling Atas
    148.0, // Kiri Tengah-Atas
    178.0, // Kiri Tengah
    62.0,  // Kanan Paling Atas
    32.0,  // Kanan Tengah-Atas
    2.0,   // Kanan Tengah
  ];

  /// Menghitung titik koordinat (Offset) tempat ujung pedang menancap di permukaan planet
  /// sesuai dengan slot pedang yang dipilih.
  static Offset calculateStabImpactOffset({
    required int slotIndex,
    required Offset center,
    required double planetRadius,
  }) {
    final safeIndex = slotIndex.clamp(0, slotAnglesDeg.length - 1);
    final standardDeg = slotAnglesDeg[safeIndex];
    final screenAngleRad = -(standardDeg * math.pi / 180.0);

    // Titik tumbukan tepat di tepi permukaan bola utama planet (sekitar 0.72 * planetRadius)
    final impactRadius = planetRadius * 0.72;
    return Offset(
      center.dx + impactRadius * math.cos(screenAngleRad),
      center.dy + impactRadius * math.sin(screenAngleRad),
    );
  }

  const QuizRadialMenuItemsLayerWidget({
    super.key,
    required this.currentItems,
    required this.center,
    required this.planetRadius,
    required this.shardGap,
    required this.shardWidth,
    required this.shardHeight,
    this.stabbingSlotIndex,
    this.stabProgress = 0.0,
    this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (int i = 0;
            i < currentItems.length && i < slotAnglesDeg.length;
            i++)
          _buildShardAtSlot(
            slotIndex: i,
            item: currentItems[i],
          ),
      ],
    );
  }

  Widget _buildShardAtSlot({
    required int slotIndex,
    required QuizPerMapelM item,
  }) {
    final double standardDeg = slotAnglesDeg[slotIndex];
    final double standardRad = standardDeg * math.pi / 180.0;

    // Di layar Flutter, sumbu Y ke bawah adalah positif, jadi sudut layar = -standardRad
    final double screenAngleRad = -standardRad;

    final bool isThisStabbing = stabbingSlotIndex == slotIndex;
    final bool isAnotherStabbing =
        stabbingSlotIndex != null && stabbingSlotIndex != slotIndex;

    // Jarak normal titik tengah pedang dari pusat planet
    final double baseDistance = planetRadius + shardGap + (shardWidth / 2);
    double currentDistance = baseDistance;

    if (isThisStabbing) {
      // Fase 1 (0.0 -> 0.16): Pedang mundur sedikit mengambil ancang-ancang (+20px)
      // Fase 2 (0.16 -> 0.42): Pedang menghujam masuk sampai benar-benar menancap penuh ke dalam planet
      // Fase 3 (0.42 -> 1.00): Pedang tertancap diam di planet sementara cahaya keluar & membesar
      if (stabProgress < 0.16) {
        final windUpT = Curves.easeOut.transform(stabProgress / 0.16);
        currentDistance = baseDistance + (20.0 * windUpT);
      } else {
        final lungeT = Curves.easeInCubic.transform(
          ((stabProgress - 0.16) / 0.26).clamp(0.0, 1.0),
        );
        final startDist = baseDistance + 20.0;
        final targetDist = baseDistance - (planetRadius * 0.62) - shardGap;
        currentDistance = startDist + (targetDist - startDist) * lungeT;
      }
    }

    // Pedang lain yang tidak dipilih memudar perlahan saat animasi tusukan berjalan
    final double itemOpacity = isAnotherStabbing
        ? (1.0 - (stabProgress * 2.2)).clamp(0.0, 1.0)
        : 1.0;

    final double itemCenterX =
        center.dx + currentDistance * math.cos(screenAngleRad);
    final double itemCenterY =
        center.dy + currentDistance * math.sin(screenAngleRad);

    // Slot 0, 1, 2 berada di sisi kiri planet, sehingga teksnya diputar 180° agar tidak terbalik
    final bool isLeftHalf = slotIndex < 3;

    return Positioned(
      left: itemCenterX - (shardWidth / 2),
      top: itemCenterY - (shardHeight / 2),
      width: shardWidth,
      height: shardHeight,
      child: Opacity(
        opacity: itemOpacity,
        child: Transform.rotate(
          angle: screenAngleRad,
          alignment: Alignment.center,
          child: QuizRadialMenuShardWidget(
            item: item,
            variantIndex: slotIndex % 3,
            isTextFlipped: isLeftHalf,
            onTap: stabbingSlotIndex == null
                ? () => onSlotTap?.call(slotIndex, item)
                : null,
          ),
        ),
      ),
    );
  }
}
