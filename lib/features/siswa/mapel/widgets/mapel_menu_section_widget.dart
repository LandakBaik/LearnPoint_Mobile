import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnpoint_mobile/features/siswa/mapel/widgets/mapel_skeleton_widget.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_preferences_service.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_service.dart';
import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/materi_list_section_widget.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/services/task_api_service.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/widgets/tugas_section.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/models/ujian_model.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/services/ujian_api_service.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/widgets/ujian_section_widget.dart';

class MapelMenuSectionWidget extends StatefulWidget {
  final int? mapelId;
  final String subjectName;
  final ValueChanged<MapelDetailModel>? onMapelLoaded;

  const MapelMenuSectionWidget({
    super.key,
    this.mapelId,
    this.subjectName = 'Matematika',
    this.onMapelLoaded,
  });

  @override
  State<MapelMenuSectionWidget> createState() => MapelMenuSectionWidgetState();
}

class MapelMenuSectionWidgetState extends State<MapelMenuSectionWidget> {
  final GlobalKey<TugasSectionState> _tugasSectionKey =
      GlobalKey<TugasSectionState>();

  Future<void> refresh() async {
    await Future.wait([
      _loadProgressStates(),
      _loadMateriFromApi(),
      _loadUjianFromApi(),
      _loadTugasCountFromApi(),
      if (_tugasSectionKey.currentState != null)
        _tugasSectionKey.currentState!.refresh(),
    ]);
  }
  int selectedIndex = 0;
  Set<String> completedKeys = {};
  Set<String> bookmarkedKeys = {};

  List<MateriItemModel> apiMateriList = [];
  bool isLoadingApi = false;
  String? apiErrorMessage;

  List<UjianItem> apiUjianList = [];
  bool isLoadingUjian = false;
  String? ujianErrorMessage;

  int _totalTugasCount = 0;
  int _activeTugasCount = 0;
  bool _isLoadingTugas = true;

  final List<String> tabs = ['Materi', 'Tugas', 'Ujian'];

  @override
  void initState() {
    super.initState();
    _loadProgressStates();
    _loadMateriFromApi();
    _loadUjianFromApi();
    _loadTugasCountFromApi();
  }

  Future<void> _loadTugasCountFromApi() async {
    try {
      final tasks = await TaskApiService.getTasks();
      if (!mounted) return;
      final filtered = tasks.where((t) {
        final tMapelId = t['mapel_id']?.toString();
        final tMapelName = (t['mapel'] ?? '').toString().toLowerCase().trim();
        if (widget.mapelId != null && tMapelId != null) {
          return tMapelId == widget.mapelId.toString();
        }
        return tMapelName == widget.subjectName.toLowerCase().trim();
      }).toList();

      final activeCount = filtered.where((t) {
        final submitted = t['is_submitted'];
        return !(submitted == true ||
            submitted == 1 ||
            submitted == '1' ||
            submitted?.toString().toLowerCase() == 'true');
      }).length;

      setState(() {
        _totalTugasCount = filtered.length;
        _activeTugasCount = activeCount;
        _isLoadingTugas = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingTugas = false;
      });
    }
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

  int get _completedMateriCount {
    int count = 0;
    for (final apiItem in apiMateriList) {
      final itemKey = MateriPreferencesService.getMateriKey(
        widget.subjectName,
        apiItem.judul,
        id: apiItem.id,
      );
      final oldItemKey = MateriPreferencesService.getMateriKey(
        widget.subjectName,
        apiItem.judul,
      );
      if (completedKeys.contains(itemKey) ||
          completedKeys.contains(oldItemKey)) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final totalMateri = apiMateriList.length;
    final completedMateri = _completedMateriCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3 Stat Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  value: '$completedMateri/$totalMateri',
                  label: 'Materi selesai',
                  isLoading: isLoadingApi,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  value: '$_activeTugasCount',
                  label: 'Tugas aktif',
                  isLoading: _isLoadingTugas,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  value: '${apiUjianList.length}',
                  label: 'Ujian',
                  isLoading: isLoadingUjian,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          Text(
            _headerTitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _headerSubtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),

          // Segmented Tab Bar: Materi, Tugas, Ujian
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF2F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final isSelected = selectedIndex == index;
                final count = index == 0
                    ? totalMateri
                    : (index == 1 ? _totalTugasCount : apiUjianList.length);

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tabs[index],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.22)
                                  : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$count',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 18),
          _buildSelectedTabContent(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: ShimmerBone(width: 40, height: 18, radius: 6),
            )
          else
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    if (selectedIndex == 1) {
      return TugasSection(
        key: _tugasSectionKey,
        mapelId: widget.mapelId,
        subjectName: widget.subjectName,
      );
    } else if (selectedIndex == 2) {
      return UjianSectionWidget(
        subjectName: widget.subjectName,
        ujianList: apiUjianList,
        isLoading: isLoadingUjian,
        errorMessage: ujianErrorMessage,
        onRetry: _loadUjianFromApi,
        onRefreshNeeded: () {
          if (mounted) _loadUjianFromApi();
        },
      );
    }

    return MateriListSectionWidget(
      subjectName: widget.subjectName,
      materiList: apiMateriList,
      completedKeys: completedKeys,
      isLoading: isLoadingApi,
      errorMessage: apiErrorMessage,
      onRetry: _loadMateriFromApi,
      onMateriOpened: _loadProgressStates,
    );
  }
}
