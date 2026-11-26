import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:learnpoint_mobile/features/siswa/gamification/models/item_model.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/widgets/inventory/inventory_state_widgets.dart';

/// Kartu showcase detail Item Power yang sedang dipilih.
class InventoryPowerShowcaseWidget extends StatelessWidget {
  final ItemModel? item;

  const InventoryPowerShowcaseWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final selected = item;
    if (selected == null) {
      return const InventoryEmptyShowcaseWidget(
        icon: Icons.bolt_rounded,
        message: 'Item Power tidak ditemukan.',
      );
    }

    final hasStock = selected.qty > 0;
    final accent = selected.color;

    return Container(
      key: ValueKey('power_showcase_${selected.kode}_${selected.qty}'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF131C47).withValues(alpha: 0.92),
            const Color(0xFF0D1333).withValues(alpha: 0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.65), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildHologramOrb(selected, hasStock, accent),
          const SizedBox(width: 14),
          Expanded(child: _buildDetail(selected, hasStock, accent)),
        ],
      ),
    );
  }

  Widget _buildHologramOrb(ItemModel selected, bool hasStock, Color accent) {
    return Container(
      width: 102,
      height: 118,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            accent.withValues(alpha: 0.32),
            const Color(0xFF090D24).withValues(alpha: 0.92),
          ],
          radius: 0.85,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.7), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.25), width: 1.2),
            ),
          ),
          Icon(selected.icon, size: 46, color: accent),
          Positioned(top: 7, left: 7, child: _buildStatusChip(hasStock)),
          Positioned(
            bottom: 7,
            right: 7,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
              decoration: BoxDecoration(
                color: const Color(0xFF070B1E).withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: hasStock ? accent : Colors.white24),
              ),
              child: Text(
                'x${selected.qty}',
                style: GoogleFonts.plusJakartaSans(
                  color: hasStock ? Colors.white : Colors.white54,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool hasStock) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: hasStock
            ? const Color(0xFF10B981).withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: hasStock ? const Color(0xFF34D399) : Colors.white24,
          width: 0.8,
        ),
      ),
      child: Text(
        hasStock ? 'AKTIF' : 'HABIS',
        style: GoogleFonts.plusJakartaSans(
          color: hasStock ? const Color(0xFF6EE7B7) : Colors.white60,
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildDetail(ItemModel selected, bool hasStock, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                selected.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accent.withValues(alpha: 0.7)),
              ),
              child: Text(
                selected.rarity.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  color: accent,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        if (selected.tagline.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            selected.tagline,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFFDE68A),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 6),
        Text(
          selected.desc,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFCBD5E1),
            fontSize: 11.5,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 8),
        _buildEffectStrip(selected, hasStock),
      ],
    );
  }

  Widget _buildEffectStrip(ItemModel selected, bool hasStock) {
    final text = selected.detailEfek.isNotEmpty
        ? selected.detailEfek
        : (hasStock
              ? 'Siap diaktifkan saat mengerjakan soal Kuis Petualangan.'
              : 'Stok habis. Dapatkan lagi melalui Gacha Antariksa!');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(
            hasStock ? Icons.rocket_launch_rounded : Icons.auto_awesome_rounded,
            size: 13,
            color: hasStock ? const Color(0xFF38BDF8) : const Color(0xFFFBBF24),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFE2E8F0),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
