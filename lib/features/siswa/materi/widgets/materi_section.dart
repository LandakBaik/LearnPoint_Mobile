import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_preferences_service.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_service.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/materi_error_state_widget.dart';
import 'package:learnpoint_mobile/features/siswa/materi/screens/detail_materi_screen.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/widgets/tugas_section.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/models/ujian_model.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/screens/detail_ujian_screen.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/screens/soal_ujian_screen.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/screens/hasil_ujian_screen.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/services/ujian_api_service.dart';

class MateriSectionWidget extends StatefulWidget {
  final int? mapelId;
  final String subjectName;
  final ValueChanged<MapelDetailModel>? onMapelLoaded;

  const MateriSectionWidget({
    super.key,
    this.mapelId,
    this.subjectName = 'Matematika',
    this.onMapelLoaded,
  });

  @override
  State<MateriSectionWidget> createState() => _MateriSectionWidgetState();
}

class _MateriSectionWidgetState extends State<MateriSectionWidget> {
  int selectedIndex = 0;
  Set<String> completedKeys = {};
  Set<String> bookmarkedKeys = {};

  List<MateriItemModel> apiMateriList = [];
  bool isLoadingApi = false;
  String? apiErrorMessage;

  List<UjianItem> apiUjianList = [];
  bool isLoadingUjian = false;
  String? ujianErrorMessage;

  final List<String> tabs = ['Materi', 'Tugas', 'Ujian'];

  @override
  void initState() {
    super.initState();
    _loadProgressStates();
    _loadMateriFromApi();
    _loadUjianFromApi();
  }

  Future<void> _loadProgressStates() async {
    final completed = await MateriPreferencesService.getCompletedKeys();
    final bookmarked = await MateriPreferencesService.getBookmarkedKeys();
    if (!mounted) return;
    setState(() {
      completedKeys = completed.toSet();
      bookmarkedKeys = bookmarked.toSet();
    });
  }

  Future<void> _loadMateriFromApi() async {
    if (widget.mapelId == null) {
      setState(() {
        apiErrorMessage = 'Mata pelajaran tidak valid.';
      });
      return;
    }
    setState(() {
      isLoadingApi = true;
      apiErrorMessage = null;
    });
    try {
      final detail = await MateriService.fetchDetailMapelSiswa(widget.mapelId!);
      if (!mounted) return;
      setState(() {
        apiMateriList = detail.materis;
        isLoadingApi = false;
      });
      widget.onMapelLoaded?.call(detail);
    } on MateriException catch (e) {
      if (!mounted) return;
      setState(() {
        apiMateriList = [];
        apiErrorMessage = e.message;
        isLoadingApi = false;
      });
    }
  }

  Future<void> _loadUjianFromApi() async {
    if (widget.mapelId == null) {
      setState(() {
        ujianErrorMessage = 'Mata pelajaran tidak valid.';
      });
      return;
    }
    setState(() {
      isLoadingUjian = true;
      ujianErrorMessage = null;
    });
    try {
      final ujians = await UjianApiService.getUjiansByMapel(widget.mapelId!);
      if (!mounted) return;
      setState(() {
        apiUjianList = ujians;
        isLoadingUjian = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        apiUjianList = [];
        ujianErrorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoadingUjian = false;
      });
    }
  }

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
    const Color primaryBlue = Color(0xFF0757C9);
    const Color darkText = Color(0xFF13233A);
    const Color secondaryText = Color(0xFF596579);

    if (item.sudahMulai && !item.sudahDikerjakan) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuizStartPage(ujianId: item.id)),
      );
      if (mounted) _loadUjianFromApi();
      return;
    }

    final tokenController = TextEditingController();
    String? tokenError;
    bool isValidating = false;

    final berhasil = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.vpn_key_rounded, color: primaryBlue, size: 22),
              SizedBox(width: 8),
              Expanded(
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
                '${item.judul} (Sesi ${item.sesi})',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: darkText),
              ),
              const SizedBox(height: 6),
              const Text(
                'Masukkan kode token dari guru pengawas untuk mulai mengerjakan ujian.',
                style: TextStyle(fontSize: 11.5, color: secondaryText, height: 1.4),
              ),
              const SizedBox(height: 12),
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
                  hintStyle: const TextStyle(fontSize: 13, letterSpacing: 0.5),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (tokenError != null) ...[
                const SizedBox(height: 8),
                Text(
                  tokenError!,
                  style: const TextStyle(fontSize: 11.5, color: Colors.red, fontWeight: FontWeight.w600),
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
                        setDialogState(() => tokenError = 'Token ujian wajib diisi.');
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
                        if (dialogContext.mounted) Navigator.pop(dialogContext, true);
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
        ),
      ),
    );

    tokenController.dispose();

    if (berhasil == true && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuizStartPage(ujianId: item.id)),
      );
      if (mounted) _loadUjianFromApi();
    }
  }

  String get _headerTitle {
    switch (selectedIndex) {
      case 1:
        return 'Daftar Tugas';
      case 2:
        return 'Daftar Ujian';
      default:
        return 'Daftar Materi';
    }
  }

  String get _headerSubtitle {
    switch (selectedIndex) {
      case 1:
        return 'Pantau tenggat waktu dan kumpulkan tugasmu tepat waktu';
      case 2:
        return 'Uji pemahamanmu melalui ujian yang tersedia';
      default:
        return 'Pilih materi yang ingin kamu pelajari';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.sizeOf(context).width < 360;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _headerTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF28233E),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            child: Text(
              _headerSubtitle,
              style: const TextStyle(color: Colors.grey),
            ),
          ),

          // Tab pilihan tipe: Materi, Tugas, Ujian
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                final label = index == 2 && apiUjianList.isNotEmpty
                    ? '${tabs[index]} (${apiUjianList.length})'
                    : tabs[index];

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6336ED)
                            : const Color(0xFFF1EEFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6336ED),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: _buildSelectedTabContent(isSmallScreen),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTabContent(bool isSmallScreen) {
    if (selectedIndex == 1) {
      return TugasSection(
        mapelId: widget.mapelId,
        subjectName: widget.subjectName,
      );
    } else if (selectedIndex == 2) {
      return _buildUjianList();
    }

    return _buildMateriGrid();
  }

  Widget _buildMateriGrid() {
    if (isLoadingApi) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (apiErrorMessage != null) {
      return Center(
        child: MateriErrorStateWidget(
          message: apiErrorMessage!,
          onRetry: _loadMateriFromApi,
        ),
      );
    }

    if (apiMateriList.isEmpty) {
      return Center(
        child: MateriErrorStateWidget.empty(
          message: 'Guru belum mengunggah materi untuk mata pelajaran ini.',
          onRetry: _loadMateriFromApi,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: apiMateriList.length,
      itemBuilder: (context, index) {
        final MateriItemModel apiItem = apiMateriList[index];
        final String title = apiItem.judul;

        final itemKey = MateriPreferencesService.getMateriKey(
          widget.subjectName,
          title,
          id: apiItem.id,
        );
        final oldItemKey = MateriPreferencesService.getMateriKey(
          widget.subjectName,
          title,
        );
        final isCompleted =
            completedKeys.contains(itemKey) ||
            completedKeys.contains(oldItemKey);
        final isBookmarked =
            bookmarkedKeys.contains(itemKey) ||
            bookmarkedKeys.contains(oldItemKey);

        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailMateriPage(
                  title: title,
                  subject: widget.subjectName,
                  materiItem: apiItem,
                ),
              ),
            );
            _loadProgressStates();
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFF6336ED),
                      size: 32,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (apiItem.isDownloaded)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.download_done_rounded,
                              color: Color(0xFF10B981),
                              size: 18,
                            ),
                          ),
                        if (isBookmarked)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.bookmark_rounded,
                              color: Color(0xFF6336ED),
                              size: 18,
                            ),
                          ),
                        if (isCompleted)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF10B981),
                            size: 18,
                          ),
                      ],
                    ),
                  ],
                ),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF28233E),
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF6336ED),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUjianList() {
    if (isLoadingUjian) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (ujianErrorMessage != null) {
      return Center(
        child: MateriErrorStateWidget(
          message: ujianErrorMessage!,
          onRetry: _loadUjianFromApi,
        ),
      );
    }

    if (apiUjianList.isEmpty) {
      return Center(
        child: MateriErrorStateWidget.empty(
          message: 'Belum ada ujian yang dijadwalkan untuk mata pelajaran ini.',
          onRetry: _loadUjianFromApi,
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < apiUjianList.length; i++) ...[
          _buildUjianCardFromApi(apiUjianList[i]),
          if (i < apiUjianList.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildUjianCardFromApi(UjianItem item) {
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
                : (item.sudahMulai ? 'Sedang Dikerjakan' : 'Belum dikerjakan')));

    final Color statusBg = isCompleted
        ? const Color(0xFFE7F7F1)
        : (isScheduled
            ? const Color(0xFFE4EDFA)
            : (isExpired ? const Color(0xFFF1F5F9) : const Color(0xFFDDEBFF)));

    final String buttonText = isCompleted
        ? 'Lihat Hasil'
        : (isActive
            ? (item.sudahMulai ? 'Lanjutkan' : 'Mulai Ujian')
            : 'Lihat Detail');

    final IconData buttonIcon = isCompleted
        ? Icons.check
        : (isActive ? Icons.play_arrow : Icons.info_outline);

    final String bottomInfo = isCompleted
        ? 'Selesai pada ${_formatDateTime(item.waktuSelesai)}'
        : (isScheduled
            ? 'Jadwal: ${_formatDateTime(item.waktuMulai)}'
            : 'Batas: ${_formatDateTime(item.deadline)}');

    final Color bottomColor = isCompleted
        ? const Color(0xFF007A58)
        : (isScheduled ? const Color(0xFF0072A8) : Colors.red);

    return _buildQuizCard(
      item: item,
      type: typeTag,
      subject: item.mapel.isNotEmpty ? item.mapel : widget.subjectName,
      grade: 'Kelas ${item.kelas} • Sesi ${item.sesi}',
      title: item.judul,
      icon: isCompleted
          ? Icons.insights_outlined
          : (isScheduled ? Icons.assignment_outlined : Icons.quiz_outlined),
      iconColor: iconColor,
      iconBackground: iconBg,
      info1: '${item.totalSoal} Butir Soal',
      info2: '${item.durasiMenit} Menit • KKM ${item.kkm.toStringAsFixed(0)}',
      infoIcon1: isCompleted ? Icons.check_circle_outline : Icons.quiz_outlined,
      infoIcon2: Icons.access_time,
      bottomInfo: bottomInfo,
      bottomIcon: isCompleted
          ? Icons.check_circle_outline
          : (isScheduled ? Icons.calendar_month_outlined : Icons.event_busy_outlined),
      bottomColor: bottomColor,
      status: statusText,
      statusColor: statusBg,
      buttonText: buttonText,
      buttonIcon: buttonIcon,
      buttonEnabled: true,
      completed: isCompleted,
    );
  }

  Widget _buildQuizCard({
    required UjianItem item,
    required String type,
    required String subject,
    required String grade,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String info1,
    required String info2,
    required IconData infoIcon1,
    required IconData infoIcon2,
    required String bottomInfo,
    required IconData bottomIcon,
    required Color bottomColor,
    required String status,
    required Color statusColor,
    required String buttonText,
    required IconData buttonIcon,
    required bool buttonEnabled,
    bool completed = false,
  }) {
    const Color primaryBlue = Color(0xFF0757C9);
    const Color darkText = Color(0xFF13233A);
    const Color secondaryText = Color(0xFF596579);
    const Color cardBlue = Color(0xFFF0F5FF);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE1E6EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 3,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: iconBackground,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: iconColor,
                            ),
                          ),
                        ),
                        Text(
                          '$subject • $grade',
                          style: const TextStyle(
                            fontSize: 9,
                            color: secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
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
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
            decoration: BoxDecoration(
              color: cardBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _infoItem(infoIcon1, info1)),
                    Expanded(child: _infoItem(infoIcon2, info2)),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Icon(bottomIcon, size: 15, color: bottomColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        bottomInfo,
                        style: TextStyle(
                          fontSize: 9,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      completed ? Icons.visibility_outlined : Icons.circle,
                      size: completed ? 14 : 7,
                      color: completed
                          ? const Color(0xFF007A58)
                          : const Color(0xFF6D778A),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: completed
                            ? const Color(0xFF007A58)
                            : const Color(0xFF596579),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (buttonText.isNotEmpty)
                SizedBox(
                  height: 34,
                  child: TextButton(
                    onPressed: buttonEnabled
                        ? () async {
                            if (completed) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HasilUjianPage(ujianId: item.id),
                                ),
                              );
                            } else if (buttonText == 'Mulai Ujian' ||
                                buttonText == 'Lanjutkan') {
                              await _handleMulaiUjian(item);
                            } else {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailUjianPage(ujianId: item.id),
                                ),
                              );
                            }
                            if (mounted) _loadUjianFromApi();
                          }
                        : null,
                    style: TextButton.styleFrom(
                      backgroundColor: buttonEnabled
                          ? primaryBlue
                          : const Color(0xFFD7E5FF),
                      foregroundColor: buttonEnabled
                          ? Colors.white
                          : primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          buttonText,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: buttonEnabled ? Colors.white : primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          buttonIcon,
                          size: 16,
                          color: buttonEnabled ? Colors.white : primaryBlue,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF0757C9)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF596579),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}