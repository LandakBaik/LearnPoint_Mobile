import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/widgets/dashboard_header_widget.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/models/ujian_model.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/screens/detail_ujian_screen.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/screens/hasil_ujian_screen.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/screens/soal_ujian_screen.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/services/ujian_api_service.dart';

const Color primaryBlue = Color(0xFF0757C9);
const Color darkText = Color(0xFF13233A);
const Color secondaryText = Color(0xFF596579);
const Color lightBlue = Color(0xFFEAF4FF);
const Color cardBlue = Color(0xFFF0F5FF);

class UjianScreen extends StatefulWidget {
  const UjianScreen({super.key});

  @override
  State<UjianScreen> createState() => _UjianScreenState();
}

class _UjianScreenState extends State<UjianScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<UjianItem> _ujians = [];
  bool _isLoading = true;
  String? _errorMessage;

  // 0 = Semua, 1 = Belum, 2 = Selesai
  int _selectedFilter = 0;
  bool _sortTerbaru = true;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadUjians();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUjians() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final result = await UjianApiService.getUjians();
      if (!mounted) return;
      setState(() {
        _ujians = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<UjianItem> get _filteredUjians {
    final query = _searchText.trim().toLowerCase();

    final list = _ujians.where((item) {
      if (_selectedFilter == 1 && item.sudahDikerjakan) return false;
      if (_selectedFilter == 2 && !item.sudahDikerjakan) return false;

      if (query.isNotEmpty) {
        final matchJudul = item.judul.toLowerCase().contains(query);
        final matchMapel = item.mapel.toLowerCase().contains(query);
        if (!matchJudul && !matchMapel) return false;
      }
      return true;
    }).toList();

    list.sort((a, b) {
      final dateA = DateTime.tryParse(a.waktuMulai ?? a.deadline ?? '');
      final dateB = DateTime.tryParse(b.waktuMulai ?? b.deadline ?? '');
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return _sortTerbaru ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });

    return list;
  }

  int get _totalBelum => _ujians.where((e) => !e.sudahDikerjakan).length;
  int get _totalSelesai => _ujians.where((e) => e.sudahDikerjakan).length;

  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return 'Sesuai Jadwal';
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return raw;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day ${months[dt.month - 1]} ${dt.year}, $hour:$minute WIB';
  }

  Future<void> _handleMulaiUjian(UjianItem item) async {
    // Jika siswa sudah pernah validasi token & sesi sedang berjalan/terkunci, langsung masuk
    if (item.sudahMulai && !item.sudahDikerjakan) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizStartPage(ujianId: item.id),
        ),
      );
      if (mounted) _loadUjians();
      return;
    }

    // Jika belum mulai, tampilkan dialog input token sesi
    final tokenController = TextEditingController();
    String? tokenError;
    bool isValidating = false;

    final berhasil = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.vpn_key_rounded, color: primaryBlue, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Masukkan Token Sesi',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: darkText),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.judul} (${item.mapel} • Sesi ${item.sesi})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: darkText),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Minta kode masuk (token) sesi ujian kepada guru pengawas untuk mulai mengerjakan.',
                    style: TextStyle(fontSize: 11.5, color: secondaryText, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: tokenController,
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5,
                      color: darkText,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Contoh: S1-AB12',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        letterSpacing: 0.5,
                        color: Color(0xFF94A3B8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryBlue, width: 1.8),
                      ),
                    ),
                  ),
                  if (tokenError != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFCDD2)),
                      ),
                      child: Text(
                        tokenError!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFFC62828),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isValidating ? null : () => Navigator.pop(dialogContext, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isValidating
                      ? null
                      : () async {
                          final kode = tokenController.text.trim();
                          if (kode.isEmpty) {
                            setDialogState(() {
                              tokenError = 'Token ujian wajib diisi.';
                            });
                            return;
                          }
                          setDialogState(() {
                            isValidating = true;
                            tokenError = null;
                          });
                          try {
                            await UjianApiService.validasiToken(
                              ujianId: item.id,
                              token: kode,
                            );
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext, true);
                            }
                          } catch (e) {
                            setDialogState(() {
                              isValidating = false;
                              tokenError = e.toString().replaceFirst('Exception: ', '');
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isValidating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Mulai Ujian', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            );
          },
        );
      },
    );

    tokenController.dispose();

    if (berhasil == true && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizStartPage(ujianId: item.id),
        ),
      );
      if (mounted) _loadUjians();
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayed = _filteredUjians;

    return Scaffold(
      backgroundColor: lightBlue,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                color: primaryBlue,
                onRefresh: _loadUjians,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(child: _buildPageTitle()),
                    SliverToBoxAdapter(child: _buildSearch()),
                    SliverToBoxAdapter(child: _buildFilter()),
                    SliverToBoxAdapter(child: _buildSummaryBanner()),
                    if (_isLoading)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 64),
                          child: Center(
                            child: CircularProgressIndicator(color: primaryBlue),
                          ),
                        ),
                      )
                    else if (_errorMessage != null)
                      SliverToBoxAdapter(child: _buildErrorState())
                    else if (displayed.isEmpty)
                      SliverToBoxAdapter(child: _buildEmptyState())
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildUjianCard(displayed[index]),
                          childCount: displayed.length,
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      decoration: const BoxDecoration(color: Color(0xFF080C24)),
      child: const DashboardHeaderWidget(),
    );
  }

  Widget _buildPageTitle() {
    final kelasLabel = _ujians.isNotEmpty && _ujians.first.kelas != '-'
        ? 'Kelas ${_ujians.first.kelas}'
        : 'Evaluasi CBT';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBEAFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.school_outlined, size: 13, color: Color(0xFF0874AD)),
                    const SizedBox(width: 5),
                    Text(
                      kelasLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0874AD),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'LearnPoint CBT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0874AD),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Halaman Ujian',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: darkText,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Pelajari kisi-kisi pada ujian terjadwal dan kerjakan ujian yang aktif',
            style: TextStyle(fontSize: 12, color: secondaryText, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Container(
        height: 43,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchText = value),
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF7C8799)),
            suffixIcon: _searchText.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchText = '');
                    },
                    icon: const Icon(Icons.close, size: 18, color: Color(0xFF7C8799)),
                  )
                : null,
            hintText: 'Cari judul ujian atau mata pelajaran...',
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF7C8799)),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilter() {
    final tabs = [
      'Semua (${_ujians.length})',
      'Belum ($_totalBelum)',
      'Selesai ($_totalSelesai)',
    ];

    return SizedBox(
      height: 40,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          for (int i = 0; i < tabs.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 7),
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: _selectedFilter == i ? primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: _selectedFilter == i ? Colors.white : const Color(0xFF39445A),
                    ),
                  ),
                ),
              ),
            ),
          GestureDetector(
            onTap: () => setState(() => _sortTerbaru = !_sortTerbaru),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDCE5F3)),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  const Icon(Icons.swap_vert, size: 15, color: primaryBlue),
                  const SizedBox(width: 4),
                  Text(
                    _sortTerbaru ? 'Terbaru' : 'Terlama',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBanner() {
    final aktifCount = _ujians
        .where((e) => !e.sudahDikerjakan && e.status == 'published')
        .length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFD5E1FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STATUS EVALUASI',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: primaryBlue,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  aktifCount > 0
                      ? '$aktifCount Ujian Tersedia Sekarang'
                      : 'Tidak Ada Ujian Berlangsung',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Total ${_ujians.length} ujian • $_totalSelesai selesai • $_totalBelum belum selesai',
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: secondaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer_outlined, color: primaryBlue, size: 25),
          ),
        ],
      ),
    );
  }

  Widget _buildUjianCard(UjianItem item) {
    final bool isCompleted = item.sudahDikerjakan;
    final bool isScheduled = !isCompleted && item.status == 'scheduled';
    final bool isExpired = !isCompleted && item.status == 'completed';
    final bool isActive = !isCompleted && item.status == 'published';

    final String typeTag = item.jenisUjian == 'remidi'
        ? 'REMIDI'
        : (item.jenisUjian == 'susulan' ? 'SUSULAN' : 'UJIAN');

    final Color iconColor = isCompleted
        ? const Color(0xFF00A875)
        : (isScheduled
            ? const Color(0xFF0088B5)
            : (isExpired ? const Color(0xFF64748B) : const Color(0xFFFF5C5C)));

    final Color iconBg = isCompleted
        ? const Color(0xFFBFFFE7)
        : (isScheduled
            ? const Color(0xFFD4F0FF)
            : (isExpired ? const Color(0xFFE2E8F0) : const Color(0xFFFFD9D9)));

    final String statusText = isCompleted
        ? (item.tampilkanNilai && item.nilaiSiswa != null
            ? 'Nilai: ${item.nilaiSiswa!.toStringAsFixed(0)}'
            : 'Selesai')
        : (isScheduled
            ? 'Terjadwal'
            : (isExpired
                ? 'Waktu Habis'
                : (item.sudahMulai ? 'Sedang Dikerjakan' : 'Tersedia')));

    final Color statusBg = isCompleted
        ? const Color(0xFFE7F7F1)
        : (isScheduled
            ? const Color(0xFFFFF4E0)
            : (isExpired ? const Color(0xFFF1F5F9) : const Color(0xFFDDEBFF)));

    final Color statusFg = isCompleted
        ? const Color(0xFF007A58)
        : (isScheduled
            ? const Color(0xFFB45309)
            : (isExpired ? const Color(0xFF64748B) : primaryBlue));

    final String buttonText = isCompleted
        ? 'Lihat Hasil'
        : (isScheduled
            ? 'Lihat Detail'
            : (isExpired
                ? 'Detail'
                : (item.sudahMulai ? 'Lanjutkan' : 'Mulai Ujian')));

    final IconData buttonIcon = isCompleted
        ? Icons.bar_chart_rounded
        : (isActive ? Icons.play_arrow_rounded : Icons.info_outline_rounded);

    final String bottomInfo = isCompleted
        ? 'Selesai pada ${_formatDateTime(item.waktuSelesai)}'
        : (isScheduled
            ? 'Mulai: ${_formatDateTime(item.waktuMulai)}'
            : 'Batas: ${_formatDateTime(item.deadline)}');

    final Color bottomColor = isCompleted
        ? const Color(0xFF007A58)
        : (isScheduled ? const Color(0xFF0072A8) : const Color(0xFFDC2626));

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailUjianPage(ujianId: item.id),
          ),
        );
        if (mounted) _loadUjians();
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 7),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.task_alt_rounded
                        : (isScheduled ? Icons.event_note_rounded : Icons.assignment_outlined),
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              typeTag,
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: iconColor,
                              ),
                            ),
                          ),
                          Text(
                            '${item.mapel} • Kelas ${item.kelas} • Sesi ${item.sesi}',
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: secondaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.judul,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: darkText,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
              decoration: BoxDecoration(
                color: cardBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _infoItem(
                          Icons.quiz_outlined,
                          '${item.totalSoal} Butir Soal',
                        ),
                      ),
                      Expanded(
                        child: _infoItem(
                          Icons.access_time_rounded,
                          '${item.durasiMenit} Menit • KKM ${item.kkm.toStringAsFixed(0)}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle_outline
                            : (isScheduled ? Icons.calendar_month_outlined : Icons.event_busy_outlined),
                        size: 15,
                        color: bottomColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          bottomInfo,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: bottomColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCompleted ? Icons.verified_outlined : Icons.circle,
                        size: isCompleted ? 14 : 7,
                        color: statusFg,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusFg,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 35,
                  child: TextButton(
                    onPressed: () async {
                      if (isCompleted) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HasilUjianPage(ujianId: item.id),
                          ),
                        );
                        if (mounted) _loadUjians();
                      } else if (isActive) {
                        await _handleMulaiUjian(item);
                      } else {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailUjianPage(ujianId: item.id),
                          ),
                        );
                        if (mounted) _loadUjians();
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: isExpired ? const Color(0xFFE2E8F0) : primaryBlue,
                      foregroundColor: isExpired ? const Color(0xFF475569) : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          buttonText,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 5),
                        Icon(buttonIcon, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: primaryBlue),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              color: secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 46, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          const Text(
            'Gagal memuat daftar ujian',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: darkText),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: secondaryText),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUjians,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 44),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 44, color: Color(0xFF94A3B8)),
          SizedBox(height: 12),
          Text(
            'Belum Ada Ujian',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: darkText),
          ),
          SizedBox(height: 6),
          Text(
            'Ujian yang dijadwalkan atau diterbitkan oleh guru akan muncul di halaman ini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: secondaryText, height: 1.5),
          ),
        ],
      ),
    );
  }
}