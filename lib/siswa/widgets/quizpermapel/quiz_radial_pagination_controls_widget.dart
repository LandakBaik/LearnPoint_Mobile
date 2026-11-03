import 'package:flutter/material.dart';

/// Widget kontrol tombol Previous & Next untuk mengganti halaman 6 daftar tema
/// di bagian bawah planet.
class QuizRadialPaginationControlsWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const QuizRadialPaginationControlsWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final bool canGoPrev = currentPage > 0;
    final bool canGoNext = currentPage < totalPages - 1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tombol Previous
        _PaginationButton(
          icon: Icons.arrow_back_ios_new_rounded,
          label: 'Prev',
          isEnabled: canGoPrev,
          isIconLeft: true,
          onTap: canGoPrev ? onPrevious : null,
        ),

        const SizedBox(width: 16),

        // Indikator Halaman (misal: 1 / 2)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF042228).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF22D3EE).withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Text(
            '${currentPage + 1} / $totalPages',
            style: const TextStyle(
              color: Color(0xFFE0F2FE),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Tombol Next
        _PaginationButton(
          icon: Icons.arrow_forward_ios_rounded,
          label: 'Next',
          isEnabled: canGoNext,
          isIconLeft: false,
          onTap: canGoNext ? onNext : null,
        ),
      ],
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEnabled;
  final bool isIconLeft;
  final VoidCallback? onTap;

  const _PaginationButton({
    required this.icon,
    required this.label,
    required this.isEnabled,
    required this.isIconLeft,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF22D3EE);
    final Color borderColor = isEnabled
        ? activeColor.withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.15);
    final Color textColor = isEnabled
        ? const Color(0xFFE0F2FE)
        : Colors.white.withValues(alpha: 0.3);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isEnabled ? 1.0 : 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isEnabled
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF0E7490),
                        Color(0xFF155E75),
                      ],
                    )
                  : null,
              color: isEnabled
                  ? null
                  : const Color(0xFF042228).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isIconLeft) ...[
                  Icon(icon, size: 15, color: textColor),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!isIconLeft) ...[
                  const SizedBox(width: 6),
                  Icon(icon, size: 15, color: textColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
