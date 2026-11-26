import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kartu showcase kosong saat tidak ada item / banner yang dipilih.
class InventoryEmptyShowcaseWidget extends StatelessWidget {
  final IconData icon;
  final String message;

  const InventoryEmptyShowcaseWidget({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131C47).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF38BDF8), size: 22),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryApiErrorBannerWidget extends StatelessWidget {
  const InventoryApiErrorBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF7F1D1D).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF87171).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Color(0xFFFCA5A5), size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Menampilkan data tersimpan. Ketuk ikon sinkronisasi untuk muat ulang.',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFFECACA),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryLoadingStateWidget extends StatelessWidget {
  const InventoryLoadingStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF38BDF8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Menyinkronkan inventori antariksa...',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF94A3B8),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
