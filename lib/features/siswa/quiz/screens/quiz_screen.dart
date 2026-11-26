import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/features/siswa/dashboard/screens/notifikasi_screen.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/widgets/dashboard_header_widget.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_service.dart';
import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/screens/quiz_per_mapel_loading_screen.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_parallax_background_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_subject_list_section_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_top_decoration_widget.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  // Menyimpan perubahan posisi scroll
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0.0);

  // Mencegah tap ganda selama transisi berlangsung
  bool _isTransitioning = false;

  // Data mapel dari API (tanpa data dummy)
  List<MateriModel> _subjects = const [];
  bool _isLoadingSubjects = true;
  String? _subjectsError;

  @override
  void initState() {
    super.initState();
    _loadSubjectsFromApi();
  }

  Future<void> _loadSubjectsFromApi() async {
    setState(() {
      _isLoadingSubjects = true;
      _subjectsError = null;
    });
    try {
      final apiSubjects = await MateriService.fetchDaftarMapelSiswa();
      if (!mounted) return;
      setState(() {
        _subjects = apiSubjects;
        _isLoadingSubjects = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _subjectsError =
            'Gagal memuat daftar mata pelajaran.\nPeriksa koneksi internet kamu.';
        _isLoadingSubjects = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollOffset.dispose();
    super.dispose();
  }

  Future<void> _handleSubjectTap(MateriModel subject) async {
    if (_isTransitioning) return;
    _isTransitioning = true;

    // Slide ke layar loading. Layar loading menutupi proses pemuatan data
    // & aset, lalu otomatis diganti dengan QuizPerMapel setelah selesai.
    await Navigator.of(context).push(
      quizSlideRoute<void>(QuizPerMapelLoadingScreen(subject: subject)),
    );

    _isTransitioning = false;
  }

  @override
  Widget build(BuildContext context) {
    // Tinggi pas dari atas sampai menyentuh lengkungan border radius container putih list mapel
    // (Header ~104 + QuizTopDecorationWidget 298 + curveDepth 25 = 427)
    const double topBgHeight = 427.0;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Layer Background Parallax
            QuizParallaxBackgroundWidget(
              topBgHeight: topBgHeight,
              scrollOffset: _scrollOffset,
            ),

            // 2. Layer Konten Utama
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                  child: DashboardHeaderWidget(
                    onNotificationTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                ),

                Expanded(
                  child: NotificationListener<ScrollUpdateNotification>(
                    onNotification: (notification) {
                      final delta = notification.scrollDelta ?? 0.0;
                      _scrollOffset.value = (_scrollOffset.value + delta).clamp(
                        0.0,
                        1000.0,
                      );
                      return false;
                    },
                    child: NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) => [
                        const SliverToBoxAdapter(
                          child: QuizTopDecorationWidget(),
                        ),
                      ],
                      // Daftar mata pelajaran / kuis
                      body: QuizSubjectListSectionWidget(
                        subjects: _subjects,
                        isLoading: _isLoadingSubjects,
                        errorMessage: _subjectsError,
                        onRetry: _loadSubjectsFromApi,
                        onSubjectTap: _handleSubjectTap,
                      ),
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
}
