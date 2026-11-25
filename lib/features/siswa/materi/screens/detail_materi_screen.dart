import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:url_launcher/url_launcher.dart';

import 'package:learnpoint_mobile/features/siswa/materi/data/materi_database_helper.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_preferences_service.dart';
import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/detail_materi/detail_materi_app_bar_widget.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/detail_materi/detail_materi_attachments_card_widget.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/detail_materi/detail_materi_colors.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/detail_materi/detail_materi_completion_button_widget.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/detail_materi/detail_materi_content_card_widget.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/detail_materi/detail_materi_dialogs.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/detail_materi/detail_materi_hero_banner_widget.dart';

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

  bool isCompleted = false;
  bool isBookmarked = false;
  bool isDownloaded = false;
  bool isDownloading = false;

  late final List<Map<String, String>> attachments = _buildAttachments();

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
      final confirm = await DetailMateriDialogs.showDeleteOfflineDialog(context);
      if (confirm == true) {
        await MateriDatabaseHelper.instance.deleteDownloadedMateri(item.id);
        if (!mounted) return;
        setState(() {
          isDownloaded = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File unduhan offline berhasil dihapus.'),
          ),
        );
      }
      return;
    }

    if (!item.hasFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Materi ini tidak memiliki berkas modul untuk diunduh.',
          ),
        ),
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
        backgroundColor: savedPath != null
            ? DetailMateriColors.successGreen
            : Colors.red,
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

    final confirmed = await DetailMateriDialogs.showOpenExternalUrlDialog(
      context,
      label: label,
      isVideo: isVideo,
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
    final item = widget.materiItem;

    return Scaffold(
      backgroundColor: DetailMateriColors.background,
      appBar: DetailMateriAppBarWidget(
        hasFile: item != null && item.hasFile,
        isDownloading: isDownloading,
        isDownloaded: isDownloaded,
        isBookmarked: isBookmarked,
        onBackTap: () => Navigator.maybePop(context),
        onToggleDownload: _handleToggleOfflineDownload,
        onToggleBookmark: _handleToggleBookmark,
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
                  DetailMateriHeroBannerWidget(
                    subject: widget.subject,
                    title: widget.title,
                    guruName: item?.guru,
                    publishedLabel: _publishedLabel,
                    isDownloaded: isDownloaded,
                  ),
                  const SizedBox(height: 18),
                  DetailMateriContentCardWidget(
                    deskripsi: item?.deskripsi,
                    hasDeskripsi: item?.hasDeskripsi ?? false,
                    publishedLabel: _publishedLabel,
                  ),
                  const SizedBox(height: 16),
                  DetailMateriAttachmentsCardWidget(
                    materiTitle: widget.title,
                    attachments: attachments,
                    hasVideo: item?.hasVideo ?? false,
                    youtubeUrl: item?.urlYoutube,
                    onOpenUrl: _openExternalUrl,
                  ),
                  const SizedBox(height: 20),
                  DetailMateriCompletionButtonWidget(
                    isCompleted: isCompleted,
                    onPressed: _handleToggleCompleted,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
