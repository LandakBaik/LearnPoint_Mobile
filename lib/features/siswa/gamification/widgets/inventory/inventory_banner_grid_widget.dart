import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:learnpoint_mobile/features/siswa/gamification/models/item_model.dart';

class InventoryBannerGridWidget extends StatelessWidget {
  final List<BannerItemModel> banners;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const InventoryBannerGridWidget({
    super.key,
    required this.banners,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.panorama_photosphere_rounded,
              color: Color(0xFF38BDF8),
              size: 38,
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada daftar banner kosmik.',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 2, bottom: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.48,
      ),
      itemCount: banners.length,
      itemBuilder: (context, index) => _BannerGridCell(
        banner: banners[index],
        isSelected: index == selectedIndex,
        onTap: () => onSelect(index),
      ),
    );
  }
}

class _BannerGridCell extends StatelessWidget {
  final BannerItemModel banner;
  final bool isSelected;
  final VoidCallback onTap;

  const _BannerGridCell({
    required this.banner,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF0B1030),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFBBF24)
                : (banner.isEquipped
                      ? const Color(0xFF10B981)
                      : (banner.isUnlocked
                            ? Colors.white.withValues(alpha: 0.35)
                            : Colors.white.withValues(alpha: 0.12))),
            width: isSelected || banner.isEquipped ? 2.4 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.25),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            BannerMediaView(
              banner: banner,
              defaultWidget: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              fallbackWidget: Container(color: const Color(0xFF1E1B4B)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.82),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            if (!banner.isUnlocked)
              Container(
                color: Colors.black.withValues(alpha: 0.52),
                child: const Center(
                  child: Icon(Icons.lock_rounded, color: Colors.white70, size: 26),
                ),
              ),
            Positioned(top: 7, right: 7, child: _buildBadge()),
            Positioned(left: 10, right: 10, bottom: 8, child: _buildCaption()),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: banner.isEquipped
            ? const Color(0xFF10B981)
            : banner.rarityColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (banner.isEquipped) ...[
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 10),
            const SizedBox(width: 3),
          ],
          Text(
            banner.isEquipped ? 'TERPASANG' : banner.badge.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaption() {
    final String status = banner.isEquipped
        ? 'Aktif di Dashboard'
        : (banner.isUnlocked
              ? 'Ketuk untuk lihat & pasang'
              : 'Terkunci • Buka via Gacha');
    final Color statusColor = banner.isEquipped
        ? const Color(0xFF6EE7B7)
        : (banner.isUnlocked ? const Color(0xFFBAE6FD) : Colors.white60);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          banner.nama,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          status,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            color: statusColor,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
