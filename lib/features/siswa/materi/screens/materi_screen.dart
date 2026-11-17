import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/features/siswa/materi/screens/materi_per_mapel_screen.dart';
import 'package:learnpoint_mobile/features/siswa/profile/screens/akun_screen.dart';
import 'package:learnpoint_mobile/features/siswa/profile/models/student_profile_model.dart';
import 'package:learnpoint_mobile/core/widgets/inverted_top_curve_clipper.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/subject_materi_card_widget.dart';
import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_service.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/materi_error_state_widget.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/screens/notifikasi_screen.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/widgets/dashboard_header_widget.dart';

class Materi extends StatefulWidget {
  final VoidCallback? onBackTap;
  const Materi({super.key, this.onBackTap});

  // Dummy Profile Data
  static const studentProfile = StudentProfileModel(
    name: 'Abimanyu',
    gradeClass: 'Kelas VIII-A',
    schoolName: 'SMP Merdeka',
    initials: 'AP',
    hasNotification: true,
  );

  @override
  State<Materi> createState() => _MateriState();
}

class _MateriState extends State<Materi> {
  List<MateriModel> _daftarMapel = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDaftarMapel();
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
    } on MateriException catch (e) {
      if (!mounted) return;
      setState(() {
        _daftarMapel = [];
        _errorMessage = e.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final textScale = (screenWidth / 400).clamp(0.9, 1.1).toDouble();
    final filtered = _daftarMapel;

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color.fromARGB(255, 114, 61, 237),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: DashboardHeaderWidget(
                  profile: Materi.studentProfile,
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
                        builder: (_) =>
                            const AkunScreen(profile: Materi.studentProfile),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Text(
                          'Mata Pelajaran',
                          style: TextStyle(
                            fontSize: 30 * textScale,
                            fontWeight: FontWeight.w900,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = const Color(0xB32C2C2C),
                          ),
                        ),
                        Text(
                          'Mata Pelajaran',
                          style: TextStyle(
                            fontSize: 30 * textScale,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Pilih mata pelajaran untuk melihat materi, tugas, dan ujian',
                        style: TextStyle(
                          fontSize: 15 * textScale,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Daftar mata pelajaran
              Expanded(
                child: ClipPath(
                  clipper: const InvertedTopCurveClipper(
                    cornerRadius: 15,
                    curveDepth: 20,
                    centerX: 0.5,
                    curveHalfWidth: 0.52,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.fromLTRB(0, 45, 0, 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0),
                      ),
                    ),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: _loadDaftarMapel,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final cardHorizontalMargin =
                                    constraints.maxWidth < 360 ? 12.0 : 20.0;

                                if (_errorMessage != null) {
                                  return ListView(
                                    children: [
                                      MateriErrorStateWidget(
                                        message: _errorMessage!,
                                        onRetry: _loadDaftarMapel,
                                      ),
                                    ],
                                  );
                                }

                                if (filtered.isEmpty) {
                                  return ListView(
                                    children: [
                                      MateriErrorStateWidget.empty(
                                        message: 'Belum ada mata pelajaran untuk kelasmu.',
                                        onRetry: _loadDaftarMapel,
                                      ),
                                    ],
                                  );
                                }

                                return ListView.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final sub = filtered[index];

                                    return SubjectMateriCardWidget(
                                      subject: sub,
                                      imageUrl: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?auto=format&fit=crop&w=1200&q=80',
                                      elevation: index.isEven ? 2 : 0,
                                      horizontalMargin: cardHorizontalMargin,
                                      ontap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                Materimapel(subject: sub),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
