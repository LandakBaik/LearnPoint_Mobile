import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:learnpoint_mobile/features/siswa/dashboard/screens/notifikasi_screen.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/widgets/dashboard_header_widget.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_database_helper.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_preferences_service.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_service.dart';
import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/features/siswa/materi/screens/materi_per_mapel_screen.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/materi_error_state_widget.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/subject_materi_card_widget.dart';
import 'package:learnpoint_mobile/features/siswa/profile/models/student_profile_model.dart';
import 'package:learnpoint_mobile/features/siswa/profile/providers/profile_provider.dart';

class Materi extends StatefulWidget {
  final VoidCallback? onBackTap;
  const Materi({super.key, this.onBackTap});

  @override
  State<Materi> createState() => _MateriState();
}

class _MateriState extends State<Materi> {
  List<MateriModel> _daftarMapel = [];
  Map<int, int> _completedPerMapel = {};
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ProfileProvider>().ensureLoaded();
    });
    _loadDaftarMapel();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDaftarMapel() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await MateriService.fetchDaftarMapelSiswa();
      if (!mounted) return;
      setState(() {
        _daftarMapel = result;
        _isLoading = false;
      });
      await _loadProgressPerMapel(result);
    } on MateriException catch (e) {
      if (!mounted) return;
      setState(() {
        _daftarMapel = [];
        _errorMessage = e.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProgressPerMapel(List<MateriModel> mapels) async {
    final completedKeys =
        (await MateriPreferencesService.getCompletedKeys()).toSet();
    final Map<int, int> counts = {};

    for (final mapel in mapels) {
      final mapelId = mapel.id;
      if (mapelId == null) continue;
      final cachedDetail =
          await MateriDatabaseHelper.instance.getCachedDetailMapel(mapelId);
      if (cachedDetail == null) continue;

      int count = 0;
      for (final m in cachedDetail.materis) {
        final keyById = MateriPreferencesService.resolveKey(
          id: m.id,
          subject: mapel.materi,
          title: m.judul,
        );
        final keyByTitle = MateriPreferencesService.resolveKey(
          subject: mapel.materi,
          title: m.judul,
        );
        if (completedKeys.contains(keyById) ||
            completedKeys.contains(keyByTitle)) {
          count++;
        }
      }
      counts[mapelId] = count;
    }

    if (!mounted) return;
    setState(() {
      _completedPerMapel = counts;
    });
  }

  List<MateriModel> get _filteredMapel {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _daftarMapel;

    return _daftarMapel.where((mapel) {
      final nameMatch = mapel.materi.toLowerCase().contains(query);
      final guruMatch = mapel.guru.any((g) => g.toLowerCase().contains(query));
      return nameMatch || guruMatch;
    }).toList();
  }

  StudentProfileModel _readProfile(BuildContext context) {
    try {
      return context.watch<ProfileProvider>().currentProfile;
    } on ProviderNotFoundException {
      return const StudentProfileModel.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final textScale = (screenWidth / 400).clamp(0.9, 1.1).toDouble();
    final profile = _readProfile(context);
    final studentName = profile.name.isNotEmpty ? profile.name : 'Siswa';
    final filtered = _filteredMapel;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          _buildHeader(context, studentName, textScale),
          const SizedBox(height: 36),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDaftarMapel,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding =
                      constraints.maxWidth < 360 ? 14.0 : 20.0;

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          14,
                        ),
                        child: Text(
                          'Mata pelajaran',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18.5 * textScale,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 64),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_errorMessage != null)
                        MateriErrorStateWidget(
                          message: _errorMessage!,
                          onRetry: _loadDaftarMapel,
                        )
                      else if (_daftarMapel.isEmpty)
                        MateriErrorStateWidget.empty(
                          message: 'Belum ada mata pelajaran untuk kelasmu.',
                          onRetry: _loadDaftarMapel,
                        )
                      else if (filtered.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 40,
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Mata pelajaran "$_searchQuery" tidak ditemukan.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14 * textScale,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...filtered.map((sub) {
                          final completedCount = sub.id != null
                              ? (_completedPerMapel[sub.id!] ?? 0)
                              : 0;
                          return SubjectMateriCardWidget(
                            subject: sub,
                            horizontalMargin: horizontalPadding,
                            completedCount: completedCount,
                            ontap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Materimapel(subject: sub),
                                ),
                              );
                              if (mounted && _daftarMapel.isNotEmpty) {
                                _loadProgressPerMapel(_daftarMapel);
                              }
                            },
                          );
                        }),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String studentName,
    double textScale,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF7B4AE2),
                Color(0xFF6D3CE0),
                Color(0xFF8154E8),
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
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 44),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardHeaderWidget(
                    onNotificationTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Selamat belajar, $studentName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13.5 * textScale,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mau belajar apa hari ini?',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 22 * textScale,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: -26,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E1B4B).withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14 * textScale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'Cari mata pelajaran atau guru...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5 * textScale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF7B4AE2),
                  size: 22,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
