import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:url_launcher/url_launcher.dart';

import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_preferences_service.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_database_helper.dart';

// nama    : IDEA BRILIANTA
// nim     : E41251668
// kelompok: 2
// golongan: E

class DetailMateriPage extends StatefulWidget {
  final String title;
  final String subject;
  final String semester;
  final String duration;
  final MateriItemModel? materiItem;

  const DetailMateriPage({
    super.key,
    this.title = 'Persamaan Linear Satu Variabel',
    this.subject = 'Matematika',
    this.semester = 'Semester 1 • Kelas VIII',
    this.duration = '15 Menit',
    this.materiItem,
  });

  @override
  State<DetailMateriPage> createState() => _DetailMateriPageState();
}

class _DetailMateriPageState extends State<DetailMateriPage> {
  static const Color primaryPurple = Color(0xFF6336ED);
  static const Color lightPurple = Color(0xFFF1EEFF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  bool isCompleted = false;
  bool isBookmarked = false;
  bool isDownloaded = false;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedProgress();
  }

  Future<void> _loadSavedProgress() async {
    final materiId = widget.materiItem?.id;
    final completed = await MateriPreferencesService.isCompleted(
      id: materiId,
      subject: widget.subject,
      title: widget.title,
    );
    final bookmarked = await MateriPreferencesService.isBookmarked(
      id: materiId,
      subject: widget.subject,
      title: widget.title,
    );
    final downloaded = materiId != null
        ? await MateriDatabaseHelper.instance.isMateriDownloaded(materiId)
        : false;

    if (!mounted) return;
    setState(() {
      isCompleted = completed;
      isBookmarked = bookmarked;
      isDownloaded = downloaded;
    });

    // Catat materi ini sebagai materi terakhir yang dibuka
    await MateriPreferencesService.saveLastSubBab(
      id: materiId,
      subject: widget.subject,
      title: widget.title,
      guru: widget.materiItem?.guru,
      deskripsi: widget.materiItem?.deskripsi,
      urlYoutube: widget.materiItem?.urlYoutube,
      fileMateri: widget.materiItem?.fileMateri,
      fileUrl: widget.materiItem?.fileUrl,
      subBabIndex: 0,
    );
  }

  Future<void> _handleToggleOfflineDownload() async {
    final item = widget.materiItem;
    if (item == null) return;

    if (isDownloaded) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Hapus Unduhan Offline?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Materi ini tidak akan tersedia secara offline lagi jika file dihapus.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Hapus'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await MateriDatabaseHelper.instance.deleteDownloadedMateri(item.id);
        if (!mounted) return;
        setState(() {
          isDownloaded = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File unduhan offline berhasil dihapus.')),
        );
      }
      return;
    }

    if (!item.hasFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Materi ini tidak memiliki berkas modul untuk diunduh.')),
      );
      return;
    }

    setState(() {
      isDownloading = true;
    });

    final savedPath = await MateriDatabaseHelper.instance.downloadMateriFile(
      materiId: item.id,
      fileUrl: item.fileUrl!,
      fileName: item.fileName ?? 'modul_materi.pdf',
    );

    if (!mounted) return;
    setState(() {
      isDownloading = false;
      isDownloaded = savedPath != null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          savedPath != null
              ? 'Materi & modul berhasil disimpan untuk mode offline! ✅'
              : 'Gagal mengunduh berkas offline. Periksa koneksi internet.',
        ),
        backgroundColor: savedPath != null ? const Color(0xFF10B981) : Colors.red,
      ),
    );
  }

  Future<void> _handleToggleBookmark() async {
    final newState = await MateriPreferencesService.toggleBookmark(
      id: widget.materiItem?.id,
      subject: widget.subject,
      title: widget.title,
    );
    if (!mounted) return;
    setState(() {
      isBookmarked = newState;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBookmarked
              ? 'Materi disimpan ke daftar bacaan.'
              : 'Materi dihapus dari daftar bacaan.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleToggleCompleted() async {
    final newState = await MateriPreferencesService.toggleCompleted(
      id: widget.materiItem?.id,
      subject: widget.subject,
      title: widget.title,
    );
    if (!mounted) return;
    setState(() {
      isCompleted = newState;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCompleted
              ? 'Selamat! Materi telah ditandai selesai dipelajari.'
              : 'Status selesai dibatalkan.',
        ),
      ),
    );
  }

  static const List<String> _namaBulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Contoh: "10 Nov 2026"
  String? get _publishedLabel {
    final d = widget.materiItem?.createdAtDate;
    if (d == null) return null;
    return '${d.day} ${_namaBulan[d.month - 1]} ${d.year}';
  }

  /// Menampilkan pop-up konfirmasi sebelum membuka aplikasi eksternal
  /// (YouTube / Browser / PDF Reader), lalu membuka link jika disetujui.
  Future<void> _openExternalUrl(
    String label,
    String rawUrl, {
    bool isVideo = false,
  }) async {
    final trimmed = rawUrl.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) {
      _showUrlSnackBar('URL $label tidak valid', trimmed);
      return;
    }

    final confirmed = await showDialog<bool>(
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
                    : const Color(0xFFF1EEFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isVideo
                    ? Icons.play_circle_fill_rounded
                    : Icons.open_in_new_rounded,
                color: isVideo ? const Color(0xFFDC2626) : primaryPurple,
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
                  color: textDark,
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
            color: textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(foregroundColor: textMuted),
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
              backgroundColor: primaryPurple,
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

    if (confirmed != true || !mounted) return;

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        _showUrlSnackBar('Gagal membuka $label', trimmed);
      }
    } catch (_) {
      if (!mounted) return;
      _showUrlSnackBar('Gagal membuka $label', trimmed);
    }
  }

  void _showUrlSnackBar(String label, String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label:\n$url'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'SALIN',
          onPressed: () => Clipboard.setData(ClipboardData(text: url)),
        ),
      ),
    );
  }

  late final List<Map<String, String>> attachments = _buildAttachments();

  List<Map<String, String>> _buildAttachments() {
    final item = widget.materiItem;
    if (item == null || !item.hasFile) return [];

    return [
      {
        'title': 'Modul Materi',
        'filename': item.fileName ?? 'berkas',
        'size': 'Berkas Server',
        'url': item.fileUrl!,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Detail Materi',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        actions: [
          if (widget.materiItem != null && widget.materiItem!.hasFile)
            IconButton(
              onPressed: isDownloading ? null : _handleToggleOfflineDownload,
              icon: isDownloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: primaryPurple),
                    )
                  : Icon(
                      isDownloaded
                          ? Icons.download_done_rounded
                          : Icons.download_for_offline_outlined,
                      color: isDownloaded ? const Color(0xFF10B981) : textDark,
                    ),
              tooltip: isDownloaded ? 'Tersimpan Offline (Klik untuk hapus)' : 'Download untuk Offline',
            ),
          IconButton(
            onPressed: _handleToggleBookmark,
            icon: Icon(
              isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isBookmarked ? primaryPurple : textDark,
            ),
            tooltip: 'Simpan Materi',
          ),
          const SizedBox(width: 4),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeroBanner(),
                  const SizedBox(height: 18),
                  _buildMaterialContentCard(),
                  const SizedBox(height: 16),
                  _buildAttachmentsCard(),
                  const SizedBox(height: 20),
                  _buildCompletionButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6336ED), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1509228468518-180dd4864904?auto=format&fit=crop&w=1200&q=80',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.18),
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.menu_book_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.subject.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_publishedLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.event_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _publishedLabel!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isDownloaded) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF10B981), width: 1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 13, color: Colors.white),
                            SizedBox(width: 5),
                            Text(
                              'OFFLINE READY',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.materiItem?.guru != null
                      ? 'Pengampu: ${widget.materiItem!.guru}'
                      : widget.subject,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialContentCard() {
    final item = widget.materiItem;
    final deskripsi = item?.hasDeskripsi ?? false
        ? item!.deskripsi!
        : 'Guru belum menambahkan uraian deskripsi untuk materi ini. '
            'Silakan tonton video atau unduh modul lampiran di bawah (jika tersedia).';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('DESKRIPSI MATERI'),
              if (_publishedLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: lightPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 11,
                        color: primaryPurple,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _publishedLabel!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Text(
            deskripsi,
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('MODUL & BERKAS UNDUHAN'),
          const SizedBox(height: 12),
          if (attachments.isEmpty)
            const Text(
              'Tidak ada berkas lampiran untuk materi ini.',
              style: TextStyle(fontSize: 12, color: textMuted),
            ),
          ...attachments.map(
            (file) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Column(
                    children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_outlined,
                        color: Color(0xFFE11D48),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file['title']!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${file['filename']} • ${file['size']}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _openExternalUrl(
                        'berkas ${file['filename']}',
                        file['url']!,
                      ),
                      icon: const Icon(
                        Icons.download_rounded,
                        color: primaryPurple,
                      ),
                      tooltip: 'Unduh berkas',
                    ),
                  ],
                ),
                if (widget.materiItem?.hasVideo ?? false) ...[
                  const SizedBox(height: 18),
                  // Video / Interactive Preview Area
                  InkWell(
                    onTap: () => _openExternalUrl(
                      'video YouTube',
                      widget.materiItem!.urlYoutube!,
                      isVideo: true,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: primaryPurple.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: primaryPurple.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: primaryPurple,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tonton Video Penjelasan',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: primaryPurple,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Visualisasi konsep ${widget.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: primaryPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.open_in_new_rounded,
                            color: primaryPurple.withValues(alpha: 0.7),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                    ],
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleToggleCompleted,
        icon: Icon(
          isCompleted ? Icons.check_circle_rounded : Icons.task_alt_rounded,
          size: 19,
        ),
        label: Text(
          isCompleted
              ? 'Materi Selesai Dipelajari'
              : 'Tandai Selesai Dipelajari',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted
              ? const Color(0xFF10B981)
              : primaryPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
