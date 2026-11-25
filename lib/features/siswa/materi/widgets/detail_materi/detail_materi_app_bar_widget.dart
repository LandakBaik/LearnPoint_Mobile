import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/detail_materi/detail_materi_colors.dart';

class DetailMateriAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final bool hasFile;
  final bool isDownloading;
  final bool isDownloaded;
  final bool isBookmarked;
  final VoidCallback onBackTap;
  final VoidCallback onToggleDownload;
  final VoidCallback onToggleBookmark;

  const DetailMateriAppBarWidget({
    super.key,
    required this.hasFile,
    required this.isDownloading,
    required this.isDownloaded,
    required this.isBookmarked,
    required this.onBackTap,
    required this.onToggleDownload,
    required this.onToggleBookmark,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: DetailMateriColors.textDark,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: onBackTap,
      ),
      title: const Text(
        'Detail Materi',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
      actions: [
        if (hasFile)
          IconButton(
            onPressed: isDownloading ? null : onToggleDownload,
            icon: isDownloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: DetailMateriColors.primaryPurple,
                    ),
                  )
                : Icon(
                    isDownloaded
                        ? Icons.download_done_rounded
                        : Icons.download_for_offline_outlined,
                    color: isDownloaded
                        ? DetailMateriColors.successGreen
                        : DetailMateriColors.textDark,
                  ),
            tooltip: isDownloaded
                ? 'Tersimpan Offline (Klik untuk hapus)'
                : 'Download untuk Offline',
          ),
        IconButton(
          onPressed: onToggleBookmark,
          icon: Icon(
            isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            color: isBookmarked
                ? DetailMateriColors.primaryPurple
                : DetailMateriColors.textDark,
          ),
          tooltip: 'Simpan Materi',
        ),
        const SizedBox(width: 4),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: Color(0xFFE2E8F0)),
      ),
    );
  }
}
