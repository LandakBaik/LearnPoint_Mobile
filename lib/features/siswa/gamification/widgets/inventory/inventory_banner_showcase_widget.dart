import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:learnpoint_mobile/features/siswa/gamification/models/item_model.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/widgets/inventory/inventory_state_widgets.dart';

/// Kartu showcase detail Banner yang sedang dipilih (pratinjau + tombol pasang).
class InventoryBannerShowcaseWidget extends StatelessWidget {
  final BannerItemModel? banner;
  final bool isEquipping;
  final VoidCallback onEquip;
  final VoidCallback onOpenGacha;

  const InventoryBannerShowcaseWidget({
    super.key,
    required this.banner,
    required this.isEquipping,
    required this.onEquip,
    required this.onOpenGacha,
  });

  @override
  Widget build(BuildContext context) {
    final b = banner;
    if (b == null) {
      return const InventoryEmptyShowcaseWidget(
        icon: Icons.panorama_rounded,
        message: 'Belum ada koleksi banner ditemukan.',
      );
    }

    final accent = b.isEquipped ? const Color(0xFF10B981) : b.rarityColor;

    return Container(
      key: ValueKey('banner_showcase_${b.kode}_${b.isEquipped}_${b.isUnlocked}'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF151C48).withValues(alpha: 0.94),
            const Color(0xFF0C1230).withValues(alpha: 0.96),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.75), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildPreview(b),
          const SizedBox(width: 14),
          Expanded(child: _buildDetail(b)),
        ],
      ),
    );
  }

  Widget _buildPreview(BannerItemModel b) {
    return SizedBox(
      width: 118,
      height: 118,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF080D24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.28), width: 1.4),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            BannerMediaView(
              banner: b,
              defaultWidget: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 36),
                ),
              ),
              fallbackWidget: const Center(
                child: Icon(Icons.panorama_rounded, color: Colors.white70, size: 36),
              ),
            ),
            if (!b.isUnlocked) _buildLockedOverlay(),
            if (b.isEquipped)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'AKTIF',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_rounded, color: Color(0xFFFBBF24), size: 26),
          const SizedBox(height: 4),
          Text(
            'TERKUNCI',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(BannerItemModel b) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                b.nama,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15.5,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: b.rarityColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: b.rarityColor.withValues(alpha: 0.8)),
              ),
              child: Text(
                b.badge.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          b.deskripsi.isNotEmpty
              ? b.deskripsi
              : 'Banner latar belakang Hero Dashboard Siswa bertema kosmik.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFCBD5E1),
            fontSize: 11.5,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        _buildActionButton(b),
      ],
    );
  }

  Widget _buildActionButton(BannerItemModel b) {
    final VoidCallback? onPressed = !b.isUnlocked
        ? onOpenGacha
        : (b.isEquipped || isEquipping ? null : onEquip);

    final Color bg = b.isEquipped
        ? const Color(0xFF10B981)
        : (b.isUnlocked ? const Color(0xFFF59E0B) : const Color(0xFF312E81));
    final Color borderColor = b.isEquipped
        ? const Color(0xFF34D399)
        : (b.isUnlocked ? const Color(0xFFFDE68A) : const Color(0xFF6366F1));

    final String label = b.isEquipped
        ? 'Terpasang di Dashboard'
        : (b.isUnlocked
              ? (isEquipping ? 'Memasang Banner...' : 'Pasang ke Dashboard')
              : 'Dapatkan di Gacha Antariksa');

    final IconData icon = b.isEquipped
        ? Icons.check_circle_rounded
        : (b.isUnlocked ? Icons.wallpaper_rounded : Icons.auto_awesome_rounded);

    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          disabledBackgroundColor: b.isEquipped ? bg : Colors.white12,
          foregroundColor: b.isUnlocked && !b.isEquipped
              ? const Color(0xFF0F172A)
              : Colors.white,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
            side: BorderSide(color: borderColor),
          ),
        ),
        icon: Icon(icon, size: 15),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
