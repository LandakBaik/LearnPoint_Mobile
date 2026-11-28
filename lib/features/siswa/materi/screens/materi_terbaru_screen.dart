import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:learnpoint_mobile/features/siswa/materi/data/materi_service.dart';
import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/features/siswa/materi/screens/detail_materi_screen.dart';

class MateriTerbaruScreen extends StatefulWidget {
  const MateriTerbaruScreen({super.key});

  @override
  State<MateriTerbaruScreen> createState() => _MateriTerbaruScreenState();
}

class _MateriTerbaruScreenState extends State<MateriTerbaruScreen> {
  List<MateriTerbaruItem> _materiList = [];

  bool _isLoading = true;
  String? _errorMessage;

  String _selectedSort = 'terbaru';

  static const Color primaryColor = Color(0xFF4F46E5);
  static const Color purpleHeaderStart = Color(0xFF7B4AE2);
  static const Color purpleHeaderMid = Color(0xFF6D3CE0);
  static const Color purpleHeaderEnd = Color(0xFF8154E8);
  static const Color darkColor = Color(0xFF1E1B4B);
  static const Color mutedColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  static const List<Map<String, String>> _sortOptions = [
    {'value': 'terbaru', 'label': 'Terbaru'},
    {'value': 'terlama', 'label': 'Terlama'},
  ];

  static const List<String> _months = [
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

  Future<void> _loadMateri() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final result = await MateriService.fetchMateriTerbaru();

      if (!mounted) return;

      setState(() {
        _materiList = result;
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

  List<MateriTerbaruItem> get _sortedMateri {
    final result = List<MateriTerbaruItem>.from(_materiList);

    result.sort((a, b) {
      final dateA = a.item.createdAtDate;
      final dateB = b.item.createdAtDate;

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      if (_selectedSort == 'terbaru') {
        return dateB.compareTo(dateA);
      }
      return dateA.compareTo(dateB);
    });

    return result;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Tanggal tidak tersedia';
    final day = date.day.toString().padLeft(2, '0');
    final month = _months[date.month - 1];
    return '$day $month ${date.year}';
  }

  void _openMateriDetail(MateriTerbaruItem entry) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailMateriPage(
          title: entry.item.judul,
          subject: entry.subject,
          duration: 'Materi Pembelajaran',
          materiItem: entry.item,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          _buildPurpleHeader(context),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 360;
                final horizontalPadding = isSmallScreen ? 16.0 : 20.0;

                return RefreshIndicator(
                  color: purpleHeaderStart,
                  onRefresh: _loadMateri,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      18,
                      horizontalPadding,
                      35,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSortDropdown(),
                        const SizedBox(height: 18),
                        _buildMateriList(isSmallScreen),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurpleHeader(BuildContext context) {
    final isSmallScreen = MediaQuery.sizeOf(context).width < 360;
    final materiCount = _materiList.length;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            purpleHeaderStart,
            purpleHeaderMid,
            purpleHeaderEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isSmallScreen ? 16 : 20,
            12,
            isSmallScreen ? 16 : 20,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBackButton(),
                  if (!_isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$materiCount Materi',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Materi Terbaru',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 22 : 25,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Daftar materi yang baru diunggah dalam 7 hari terakhir.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 12 : 13,
                  height: 1.45,
                  color: Colors.white.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: () => Navigator.maybePop(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chevron_left_rounded,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 2),
            Text(
              'Kembali',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Row(
      children: [
        const Icon(
          Icons.sort_rounded,
          size: 19,
          color: primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          'Urutkan:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: darkColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSort,
                isExpanded: true,
                isDense: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: mutedColor,
                  size: 20,
                ),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: darkColor,
                ),
                items: _sortOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option['value'],
                    child: Text(option['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedSort = value;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMateriList(bool isSmallScreen) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    final displayedMateri = _sortedMateri;

    if (displayedMateri.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: displayedMateri.map((entry) {
        return _buildMateriCard(entry: entry, isSmallScreen: isSmallScreen);
      }).toList(),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 45),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 45,
              color: Color(0xFF98A6B9),
            ),
            const SizedBox(height: 12),
            Text(
              'Gagal mengambil data materi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: mutedColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMateri,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 45),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              size: 32,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Belum Ada Materi Baru',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: darkColor,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Belum ada materi yang diunggah dalam 7 hari terakhir.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.6,
              color: mutedColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMateriCard({
    required MateriTerbaruItem entry,
    required bool isSmallScreen,
  }) {
    final materi = entry.item;
    final teacherName =
        materi.guru?.isNotEmpty == true ? materi.guru! : 'GURU PENGAMPU';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BARIS ATAS: MAPEL DAN JENIS MATERI
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      entry.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3730A3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EEFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  entry.typeLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: purpleHeaderStart,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // JUDUL MATERI
          Text(
            materi.judul,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isSmallScreen ? 15 : 16.5,
              fontWeight: FontWeight.w800,
              color: darkColor,
              height: 1.35,
            ),
          ),

          if (materi.hasDeskripsi) ...[
            const SizedBox(height: 6),
            Text(
              materi.deskripsi!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: mutedColor,
                height: 1.45,
              ),
            ),
          ],

          const SizedBox(height: 10),

          // GURU & BADGE BARU
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7FB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 13.5,
                      color: mutedColor,
                    ),
                    const SizedBox(width: 5),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 170),
                      child: Text(
                        teacherName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: mutedColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: darkColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Baru',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // TANGGAL UNGGAH
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 13.5,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Diunggah ${_formatDate(materi.createdAtDate)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: mutedColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // TOMBOL PELAJARI MATERI
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => _openMateriDetail(entry),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pelajari Materi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
