import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_service.dart';
import 'package:learnpoint_mobile/features/siswa/materi/screens/detail_materi_screen.dart';
import 'package:learnpoint_mobile/features/siswa/mapel/screens/mapel_screen.dart';

class MateriDashboardWidget extends StatefulWidget {
  const MateriDashboardWidget({super.key});

  @override
  State<MateriDashboardWidget> createState() => _MateriDashboardWidgetState();
}

class _MateriDashboardWidgetState extends State<MateriDashboardWidget> {
  int _currentMateriIndex = 0;

  List<_DashboardMateri> _materiList = [];

  bool _isLoading = true;
  String? _errorMessage;

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

  @override
  void initState() {
    super.initState();
    _loadMateri();
  }

  // ============================================================
  // MENGAMBIL MATERI DARI API
  // ============================================================

  Future<void> _loadMateri() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Ambil seluruh mata pelajaran milik siswa.
      final mapels = await MateriService.fetchDaftarMapelSiswa();

      // 2. Ambil detail materi dari setiap mata pelajaran.
      final validMapels = mapels.where((mapel) => mapel.id != null).toList();

      final detailLists = await Future.wait<List<_DashboardMateri>>(
        validMapels.map((mapel) async {
          final detail = await MateriService.fetchDetailMapelSiswa(mapel.id!);

          return detail.materis.map((materi) {
            return _DashboardMateri(subject: mapel.materi, item: materi);
          }).toList();
        }),
      );

      // 3. Gabungkan seluruh materi.
      final allMateri = detailLists.expand((materiList) => materiList).toList();

      // 4. Filter materi dalam 7 hari terakhir.
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final filteredMateri = allMateri.where((materi) {
        final uploadedAt = materi.item.createdAtDate;

        // Tanggal kosong atau format tidak valid tidak ditampilkan.
        if (uploadedAt == null) return false;

        // Hanya materi dalam rentang 7 hari terakhir.
        return !uploadedAt.isBefore(sevenDaysAgo) && !uploadedAt.isAfter(now);
      }).toList();

      // 5. Urutkan dari materi terbaru.
      filteredMateri.sort((a, b) {
        return b.item.createdAtDate!.compareTo(a.item.createdAtDate!);
      });

      if (!mounted) return;

      setState(() {
        _materiList = filteredMateri;
        _currentMateriIndex = 0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e is MateriException
            ? e.message
            : 'Gagal memuat materi. Silakan coba lagi.';
      });
    }
  }

  // ============================================================
  // NAVIGASI MATERI
  // ============================================================

  void _nextMateri() {
    if (_currentMateriIndex < _materiList.length - 1) {
      setState(() {
        _currentMateriIndex++;
      });
    }
  }

  void _previousMateri() {
    if (_currentMateriIndex > 0) {
      setState(() {
        _currentMateriIndex--;
      });
    }
  }

  // ============================================================
  // TEXT STYLE
  // ============================================================

  TextStyle _textStyle({
    double fontSize = 13,
    Color color = const Color(0xFF1E1B4B),
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }

  // ============================================================
  // FORMAT TANGGAL
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day} ${_namaBulan[date.month - 1]} ${date.year}';
  }

  // ============================================================
  // JENIS MATERI
  // ============================================================

  String _getMateriType(MateriItemModel materi) {
    if (materi.hasVideo && materi.hasFile) {
      return 'Video & PDF Rangkuman';
    }

    if (materi.hasVideo) {
      return 'Video Pembelajaran';
    }

    if (materi.hasFile) {
      return 'Modul PDF';
    }

    return 'Materi Pembelajaran';
  }

  // ============================================================
  // BUKA DETAIL MATERI
  // ============================================================

  void _openMateri(_DashboardMateri materi) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailMateriPage(
          title: materi.item.judul,
          subject: materi.subject,
          duration: 'Materi Pembelajaran',
          materiItem: materi.item,
        ),
      ),
    );
  }

  // ============================================================
  // LIHAT SEMUA MATERI
  // ============================================================

  void _openAllMateri() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const MapelScreen()));
  }

  // ============================================================
  // WIDGET STATUS
  // ============================================================

  Widget _buildStatusWidget({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: const Color(0xFF818CF8)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: _textStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: _textStyle(fontSize: 12, color: const Color(0xFF6B7280)),
          ),
          if (action != null) ...[const SizedBox(height: 14), action],
        ],
      ),
    );
  }

  // ============================================================
  // HEADER SECTION
  // ============================================================

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Materi Baru Minggu Ini',
                style: _textStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ).copyWith(letterSpacing: -0.3),
              ),
              const SizedBox(height: 2),
              Text(
                'Diunggah guru untuk bahan ujian',
                style: _textStyle(fontSize: 13, color: const Color(0xFF5B6275)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: _openAllMateri,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Lihat Semua ›',
              style: _textStyle(
                fontSize: 13,
                color: const Color(0xFF4F46E5),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CARD MATERI
  // ============================================================

  Widget _buildMateriCard(_DashboardMateri currentMateri, int safeIndex) {
    final materi = currentMateri.item;
    final uploadedAt = materi.createdAtDate;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;

        if (velocity < -200) {
          _nextMateri();
        } else if (velocity > 200) {
          _previousMateri();
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: Container(
          key: ValueKey('${currentMateri.subject}_${materi.id}'),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ILLUSTRATION HEADER
              Container(
                height: 150,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFDBEAFE), Color(0xFFCCFBF1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // ICON PARU-PARU
                    Center(
                      child: CustomPaint(
                        size: const Size(64, 64),
                        painter: _LungsIconPainter(
                          color: const Color(0xFF0F5F57),
                        ),
                      ),
                    ),

                    // BADGE MAPEL
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          currentMateri.subject,
                          style: _textStyle(
                            fontSize: 12,
                            color: const Color(0xFF0F5F57),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    // BADGE BARU
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1B4B),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Baru',
                          style: _textStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // MATERI DETAILS
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TIPE MATERI
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getMateriType(materi),
                        style: _textStyle(
                          fontSize: 12,
                          color: const Color(0xFF3730A3),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // JUDUL
                    Text(
                      materi.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _textStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // NAMA GURU
                    Text(
                      materi.guru?.isNotEmpty == true
                          ? materi.guru!
                          : 'Guru belum tersedia',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _textStyle(
                        fontSize: 13,
                        color: const Color(0xFF5B6275),
                      ),
                    ),

                    if (uploadedAt != null) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Diunggah ${_formatDate(uploadedAt)}',
                            style: _textStyle(
                              fontSize: 11,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 14),

                    // BUTTON PELAJARI
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => _openMateri(currentMateri),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEF2FF),
                          foregroundColor: const Color(0xFF4F46E5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          textStyle: _textStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Pelajari Materi'),
                      ),
                    ),
                  ],
                ),
              ),

              // PAGINATION
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildPagination(safeIndex, _materiList.length),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DOT DAN TOMBOL NAVIGASI
  // ============================================================

  Widget _buildPagination(int currentIndex, int totalMateri) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // DOT INDICATOR
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(totalMateri, (index) {
                final isActive = index == currentIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 6),
                  width: isActive ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF4F46E5)
                        : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // BUTTON PREVIOUS DAN NEXT
        Row(
          children: [
            _buildNavigationButton(
              isEnabled: currentIndex > 0,
              icon: Icons.chevron_left_rounded,
              onTap: _previousMateri,
            ),
            const SizedBox(width: 8),
            _buildNavigationButton(
              isEnabled: currentIndex < totalMateri - 1,
              icon: Icons.chevron_right_rounded,
              onTap: _nextMateri,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationButton({
    required bool isEnabled,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : const Color(0xFF9CA3AF),
          size: 22,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final hasMateri = _materiList.isNotEmpty;

    final safeIndex = hasMateri
        ? _currentMateriIndex.clamp(0, _materiList.length - 1)
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),

        const SizedBox(height: 12),

        // LOADING
        if (_isLoading)
          _buildStatusWidget(
            icon: Icons.menu_book_outlined,
            title: 'Memuat materi...',
            subtitle: 'Sedang mengambil materi terbaru.',
          )
        // ERROR
        else if (_errorMessage != null)
          _buildStatusWidget(
            icon: Icons.cloud_off_outlined,
            title: 'Gagal memuat materi',
            subtitle: _errorMessage!,
            action: TextButton.icon(
              onPressed: _loadMateri,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          )
        // BELUM ADA MATERI
        else if (!hasMateri)
          _buildStatusWidget(
            icon: Icons.menu_book_outlined,
            title: 'Belum ada materi baru',
            subtitle: 'Belum ada materi yang diunggah dalam 7 hari terakhir.',
          )
        // CARD MATERI
        else
          _buildMateriCard(_materiList[safeIndex], safeIndex),
      ],
    );
  }
}

// ============================================================
// MODEL KHUSUS UNTUK CARD DASHBOARD
// ============================================================

class _DashboardMateri {
  final String subject;
  final MateriItemModel item;

  const _DashboardMateri({required this.subject, required this.item});
}

// ============================================================
// CUSTOM PAINTER ICON
// ============================================================

class _LungsIconPainter extends CustomPainter {
  final Color color;

  _LungsIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scaleX = size.width / 24.0;
    final scaleY = size.height / 24.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // Trachea
    canvas.drawLine(const Offset(12, 3), const Offset(12, 10), paint);

    // Left lung
    final leftPath = Path()
      ..moveTo(12, 10)
      ..cubicTo(10, 10, 9, 11, 8, 13)
      ..cubicTo(5, 13, 5, 16, 5, 18)
      ..cubicTo(5, 19.5, 7, 20.5, 10, 19)
      ..cubicTo(11, 18, 12, 15, 12, 13);

    canvas.drawPath(leftPath, paint);

    // Right lung
    final rightPath = Path()
      ..moveTo(12, 10)
      ..cubicTo(14, 10, 15, 11, 16, 13)
      ..cubicTo(19, 13, 19, 16, 19, 18)
      ..cubicTo(19, 19.5, 17, 20.5, 14, 19)
      ..cubicTo(13, 18, 12, 15, 12, 13);

    canvas.drawPath(rightPath, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LungsIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
