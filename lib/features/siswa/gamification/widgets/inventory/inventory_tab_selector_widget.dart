import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InventoryTabSelectorWidget extends StatelessWidget {
  final bool isPowerTab;
  final int totalPowerQty;
  final int unlockedBannerCount;
  final int totalBannerCount;
  final ValueChanged<int> onTabChanged;

  const InventoryTabSelectorWidget({
    super.key,
    required this.isPowerTab,
    required this.totalPowerQty,
    required this.unlockedBannerCount,
    required this.totalBannerCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1738).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              title: 'Item Power',
              badgeText: '$totalPowerQty Stok',
              icon: Icons.bolt_rounded,
              isActive: isPowerTab,
              activeGradient: const [Color(0xFF2563EB), Color(0xFF4F46E5)],
              activeBorderColor: const Color(0xFF38BDF8),
              onTap: () => onTabChanged(0),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _TabButton(
              title: 'Banner Kosmik',
              badgeText: totalBannerCount > 0
                  ? '$unlockedBannerCount/$totalBannerCount'
                  : '$unlockedBannerCount',
              icon: Icons.panorama_rounded,
              isActive: !isPowerTab,
              activeGradient: const [Color(0xFF7C3AED), Color(0xFF4F46E5)],
              activeBorderColor: const Color(0xFFC084FC),
              onTap: () => onTabChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final String badgeText;
  final IconData icon;
  final bool isActive;
  final List<Color> activeGradient;
  final Color activeBorderColor;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.badgeText,
    required this.icon,
    required this.isActive,
    required this.activeGradient,
    required this.activeBorderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: activeGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? activeBorderColor.withValues(alpha: 0.8)
                : Colors.transparent,
            width: 1.2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeGradient.first.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.black.withValues(alpha: 0.28)
                    : Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isActive
                      ? const Color(0xFFFDE68A)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
