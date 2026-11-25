import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/detail_materi/detail_materi_colors.dart';

class DetailMateriDialogs {
  const DetailMateriDialogs._();

  static Future<bool?> showDeleteOfflineDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Unduhan Offline?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Materi ini tidak akan tersedia secara offline lagi jika file dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showOpenExternalUrlDialog(
    BuildContext context, {
    required String label,
    required bool isVideo,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isVideo
                    ? const Color(0xFFFEE2E2)
                    : DetailMateriColors.lightPurple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isVideo
                    ? Icons.play_circle_fill_rounded
                    : Icons.open_in_new_rounded,
                color: isVideo
                    ? const Color(0xFFDC2626)
                    : DetailMateriColors.primaryPurple,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isVideo ? 'Buka Video YouTube?' : 'Buka Berkas Materi?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DetailMateriColors.textDark,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          isVideo
              ? 'Kamu akan diarahkan keluar aplikasi menuju YouTube / Browser untuk menonton video penjelasan materi ini.'
              : 'Kamu akan diarahkan keluar aplikasi menuju Browser / Pembaca Dokumen untuk membuka atau mengunduh $label.',
          style: const TextStyle(
            fontSize: 13,
            height: 1.5,
            color: DetailMateriColors.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: DetailMateriColors.textMuted,
            ),
            child: const Text(
              'Batal',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: Text(
              isVideo ? 'Buka YouTube' : 'Buka Berkas',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: DetailMateriColors.primaryPurple,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
