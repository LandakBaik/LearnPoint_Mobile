import 'package:flutter/material.dart';

import 'quizPerMapel.dart';
import 'changepass.dart';
import 'notifikasi.dart';
import '../models/student_profile_model.dart';
import '../models/materi_page.dart';
import 'widgets/dashboard_header_widget.dart';
import 'widgets/quiz_parallax_background_widget.dart';
import 'widgets/quiz_top_decoration_widget.dart';
import 'widgets/quiz_subject_list_section_widget.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> with SingleTickerProviderStateMixin {
  // Dummy Profile Data
  static const studentProfile = StudentProfileModel(
    name: 'Abimanyu',
    gradeClass: 'Kelas VIII-A',
    schoolName: 'SMP Merdeka',
    initials: 'AP',
    hasNotification: true,
  );

  // Menyimpan perubahan posisi scroll
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0.0);

  // Controller untuk animasi container list mapel menjulang ke atas melebihi batas layar
  late final AnimationController _surgeUpController;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _surgeUpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _scrollOffset.dispose();
    _surgeUpController.dispose();
    super.dispose();
  }

  Future<void> _handleSubjectTap(MateriModel subject) async {
    if (_isTransitioning) return;

    setState(() {
      _isTransitioning = true;
    });

    // 1. Container pembungkus list mapel menjulang ke atas melebihi batas atas layar
    await _surgeUpController.forward(from: 0.0);

    if (!mounted) return;

    // 2. Pindah ke QuizPerMapel dengan durasi lambat & mulus (1150ms)
    //    sehingga Hero planet bergerak pelan ke tengah layar
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 1150),
        reverseTransitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) =>
            QuizPerMapel(subject: subject),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: child,
          );
        },
      ),
    );

    // 3. Kembalikan container seperti semula saat kembali dari QuizPerMapel
    if (mounted) {
      await _surgeUpController.reverse();
      if (mounted) {
        setState(() {
          _isTransitioning = false;
        });
      }
    }
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
                AnimatedBuilder(
                  animation: _surgeUpController,
                  builder: (context, headerChild) {
                    final t = Curves.easeInOutCubic.transform(
                      _surgeUpController.value,
                    );
                    return Opacity(
                      opacity: (1.0 - t * 2.0).clamp(0.0, 1.0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: (1.0 - t).clamp(0.0, 1.0),
                        child: headerChild,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: DashboardHeaderWidget(
                      profile: studentProfile,
                      onNotificationTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const NotificationScreen(),
                          ),
                        );
                      },
                      onProfileTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const Changepass(),
                          ),
                        );
                      },
                    ),
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
                        SliverToBoxAdapter(
                          child: AnimatedBuilder(
                            animation: _surgeUpController,
                            builder: (context, child) {
                              // Saat container menjulang ke atas, dekorasi mengecil tingginya
                              // sehingga body (container putih list mapel) terdorong naik melewati batas atas layar
                              final t = Curves.easeInOutCubic.transform(
                                _surgeUpController.value,
                              );
                              return Opacity(
                                opacity: (1.0 - t * 1.8).clamp(0.0, 1.0),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  heightFactor: (1.0 - t).clamp(0.0, 1.0),
                                  child: child,
                                ),
                              );
                            },
                            child: const QuizTopDecorationWidget(),
                          ),
                        ),
                      ],
                      // Daftar mata pelajaran / kuis
                      body: AnimatedBuilder(
                        animation: _surgeUpController,
                        builder: (context, child) {
                          final t = Curves.easeInOutCubic.transform(
                            _surgeUpController.value,
                          );
                          // Dorong container putih melampaui batas atas layar (-90px)
                          return Transform.translate(
                            offset: Offset(0, -90.0 * t),
                            child: child,
                          );
                        },
                        child: QuizSubjectListSectionWidget(
                          subjects: subjek,
                          onSubjectTap: _handleSubjectTap,
                        ),
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
