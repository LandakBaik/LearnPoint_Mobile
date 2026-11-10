import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_preferences_service.dart';

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
  int selectedSubBabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedProgress();
  }

  Future<void> _loadSavedProgress() async {
    final savedSubBab = await MateriPreferencesService.getLastSubBab(
      subject: widget.subject,
      title: widget.title,
    );
    final completed = await MateriPreferencesService.isCompleted(
      subject: widget.subject,
      title: widget.title,
    );
    final bookmarked = await MateriPreferencesService.isBookmarked(
      subject: widget.subject,
      title: widget.title,
    );

    if (!mounted) return;
    setState(() {
      if (savedSubBab >= 0 && savedSubBab < subChapters.length) {
        selectedSubBabIndex = savedSubBab;
      }
      isCompleted = completed;
      isBookmarked = bookmarked;
    });

    // Catat materi ini sebagai materi terakhir yang dibuka
    await MateriPreferencesService.saveLastSubBab(
      subject: widget.subject,
      title: widget.title,
      subBabIndex: selectedSubBabIndex,
    );
  }

  Future<void> _updateSubBabIndex(int newIndex) async {
    setState(() {
      selectedSubBabIndex = newIndex;
    });
    await MateriPreferencesService.saveLastSubBab(
      subject: widget.subject,
      title: widget.title,
      subBabIndex: newIndex,
    );
  }

  Future<void> _handleToggleBookmark() async {
    final newState = await MateriPreferencesService.toggleBookmark(
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

  late final List<Map<String, dynamic>> subChapters = _buildSubChapters();

  List<Map<String, dynamic>> _buildSubChapters() {
    final apiDesc = widget.materiItem?.deskripsi;
    if (apiDesc != null && apiDesc.trim().isNotEmpty) {
      return [
        {
          'title': '1. Uraian Materi (${widget.title})',
          'duration': widget.duration,
          'content': apiDesc,
          'keyPoints': [
            if (widget.materiItem?.guru != null &&
                widget.materiItem!.guru!.isNotEmpty)
              'Pengampu: ${widget.materiItem!.guru}',
            'Pelajari uraian materi dan unduh modul lampiran di bawah untuk penjelasan lengkap.',
          ],
        },
      ];
    }

    return [
      {
        'title': '1. Pengertian & Konsep Dasar',
        'duration': '5 Menit',
        'content':
            'Persamaan Linear Satu Variabel (PLSV) adalah kalimat terbuka yang dihubungkan oleh tanda sama dengan (=) dan hanya mempunyai satu variabel berpangkat satu.\n\nBentuk umum dari Persamaan Linear Satu Variabel adalah:\nax + b = c\n\nDengan keterangan:\n• a ≠ 0\n• x disebut variabel (peubah)\n• a disebut koefisien dari variabel x\n• b dan c disebut konstanta',
        'keyPoints': [
          'Kalimat terbuka adalah kalimat yang belum dapat ditentukan nilai kebenarannya (benar atau salah).',
          'Variabel adalah simbol/lambang yang mewakili sembarang anggota suatu himpunan semesta.',
          'Himpunan penyelesaian adalah himpunan semua pengganti variabel yang membuat persamaan menjadi pernyataan bernilai benar.',
        ],
      },
      {
        'title': '2. Sifat-Sifat Kesetaraan (Ekuivalen)',
        'duration': '5 Menit',
        'content':
            'Dua persamaan atau lebih dikatakan ekuivalen (setara) jika mempunyai himpunan penyelesaian yang sama. Untuk mencari penyelesaian dari suatu persamaan, kita dapat menggunakan sifat-sifat berikut:\n\n1. Kedua ruas ditambah atau dikurangi dengan bilangan yang sama.\n2. Kedua ruas dikalikan atau dibagi dengan bilangan bukan nol yang sama.',
        'keyPoints': [
          'Penjumlahan/pengurangan kedua ruas tidak mengubah nilai kebenaran persamaan.',
          'Perkalian/pembagian dengan bilangan bulat positif maupun negatif tetap mempertahankan kesetaraan.',
          'Tujuan utama operasi ini adalah mengisolasi variabel x di satu ruas.',
        ],
      },
      {
        'title': '3. Contoh Soal & Pembahasan',
        'duration': '5 Menit',
        'content':
            'Contoh Soal:\nTentukan himpunan penyelesaian dari persamaan 3x - 5 = 10 untuk x anggota bilangan bulat!\n\nLangkah Penyelesaian:\n1. Tambahkan kedua ruas dengan 5:\n   3x - 5 + 5 = 10 + 5\n   3x = 15\n\n2. Bagi kedua ruas dengan 3:\n   3x / 3 = 15 / 3\n   x = 5\n\nJadi, himpunan penyelesaiannya adalah {5}.',
        'keyPoints': [
          'Selalu periksa kembali jawaban dengan mensubstitusikan nilai x ke persamaan awal.',
          '3(5) - 5 = 15 - 5 = 10 (Terbukti benar).',
        ],
      },
    ];
  }

  late final List<Map<String, String>> attachments = _buildAttachments();

  List<Map<String, String>> _buildAttachments() {
    final item = widget.materiItem;
    if (item != null &&
        item.fileMateri != null &&
        item.fileMateri!.trim().isNotEmpty) {
      final fileName = item.fileMateri!.split('/').last;
      return [
        {
          'title': 'Modul Materi (${widget.title})',
          'filename': fileName,
          'size': 'Berkas Server',
          'url': item.fileUrl ?? item.fileMateri!,
        },
      ];
    }

    return [
      {
        'title': 'Modul Lengkap Materi (PDF)',
        'filename': 'Modul_Pembelajaran_Bab_1.pdf',
        'size': '2.4 MB',
        'type': 'pdf',
      },
      {
        'title': 'Ringkasan Rumus & Latihan Mandiri',
        'filename': 'Ringkasan_Rumus_dan_Latihan.pdf',
        'size': '1.1 MB',
        'type': 'pdf',
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
                  _buildBreadcrumb(),
                  const SizedBox(height: 16),
                  _buildHeroBanner(),
                  const SizedBox(height: 18),
                  _buildChapterSelector(),
                  const SizedBox(height: 16),
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

  Widget _buildBreadcrumb() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 7,
      runSpacing: 8,
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, size: 15, color: textMuted),
                SizedBox(width: 6),
                Text(
                  'Kembali',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Icon(Icons.chevron_right, size: 16, color: Color(0xFFCBD5E1)),
        Text(
          widget.subject,
          style: const TextStyle(
            fontSize: 12,
            color: textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Icon(Icons.chevron_right, size: 16, color: Color(0xFFCBD5E1)),
        Flexible(
          child: Text(
            widget.title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: primaryPurple,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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
                            Icons.access_time_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.duration,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                  '${widget.semester} • Kurikulum Merdeka',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                // Video / Interactive Preview Area
                InkWell(
                  onTap: () {
                    final ytUrl = widget.materiItem?.urlYoutube;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ytUrl != null && ytUrl.isNotEmpty
                              ? 'Membuka video: $ytUrl'
                              : 'Memutar video pembelajaran...',
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: primaryPurple,
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
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Visualisasi konsep ${widget.title}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.open_in_new_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle('SUB-BAB MATERI'),
            Text(
              '${selectedSubBabIndex + 1} dari ${subChapters.length} Bagian',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: primaryPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: subChapters.length,
            itemBuilder: (context, index) {
              final isSelected = selectedSubBabIndex == index;
              final chapter = subChapters[index];

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => _updateSubBabIndex(index),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryPurple : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? primaryPurple
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      chapter['title'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : textDark,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialContentCard() {
    final activeChapter = subChapters[selectedSubBabIndex];
    final List<String> keyPoints =
        (activeChapter['keyPoints'] as List<dynamic>).cast<String>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  activeChapter['title'] as String,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: lightPurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  activeChapter['duration'] as String,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: primaryPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),
          _sectionTitle('URAIAN MATERI'),
          const SizedBox(height: 10),
          Text(
            activeChapter['content'] as String,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.75,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE9E3FF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: primaryPurple,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Poin Penting untuk Diingat',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: primaryPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...keyPoints.map(
                  (point) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: primaryPurple,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            point,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: selectedSubBabIndex > 0
                    ? () => _updateSubBabIndex(selectedSubBabIndex - 1)
                    : null,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text(
                  'Sebelumnya',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: primaryPurple,
                ),
              ),
              TextButton.icon(
                onPressed: selectedSubBabIndex < subChapters.length - 1
                    ? () => _updateSubBabIndex(selectedSubBabIndex + 1)
                    : null,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text(
                  'Selanjutnya',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: primaryPurple,
                ),
              ),
            ],
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
                child: Row(
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
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Mengunduh ${file['filename']}...'),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.download_rounded,
                        color: primaryPurple,
                      ),
                      tooltip: 'Unduh berkas',
                    ),
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
          isCompleted
              ? Icons.check_circle_rounded
              : Icons.task_alt_rounded,
          size: 19,
        ),
        label: Text(
          isCompleted ? 'Materi Selesai Dipelajari' : 'Tandai Selesai Dipelajari',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isCompleted ? const Color(0xFF10B981) : primaryPurple,
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
