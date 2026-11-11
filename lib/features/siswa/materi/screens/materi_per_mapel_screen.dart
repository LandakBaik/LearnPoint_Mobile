import 'package:flutter/material.dart';

// nama    : IDEA BRILIANTA
// nim     : E41251668
// kelompok: 2
// golongan: E

import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/features/siswa/profile/models/student_profile_model.dart';
import 'package:learnpoint_mobile/features/siswa/profile/screens/akun_screen.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/screens/notifikasi_screen.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/widgets/dashboard_header_widget.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/materi_header_widget.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/materi_section.dart';

class Materimapel extends StatefulWidget {
  final VoidCallback? onBackTap;
  final MateriModel? subject;

  const Materimapel({
    super.key,
    this.onBackTap,
    this.subject,
  });

  static const studentProfile = StudentProfileModel(
    name: 'Abimanyu',
    gradeClass: 'Kelas VIII-A',
    schoolName: 'SMP Merdeka',
    initials: 'AP',
    hasNotification: true,
  );

  @override
  State<Materimapel> createState() => _MaterimapelState();
}

class _MaterimapelState extends State<Materimapel> {
  MapelDetailModel? _mapelDetail;

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final subjectName =
        _mapelDetail?.namaMapel ?? widget.subject?.materi ?? 'Mata Pelajaran';
    final description =
        _mapelDetail?.identitasLabel ?? widget.subject?.description ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF6336ED),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: DashboardHeaderWidget(
                  profile: Materimapel.studentProfile,
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
                        builder: (_) => const AkunScreen(
                          profile: Materimapel.studentProfile,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap:
                        widget.onBackTap ?? () => Navigator.maybePop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(
                  screenwidth * 0.04,
                  24,
                  screenwidth * 0.04,
                  0,
                ),
                child: MateriHeaderWidget(
                  subjectName: subjectName,
                  description: description,
                ),
              ),
              MateriSectionWidget(
                mapelId: widget.subject?.id,
                subjectName: subjectName,
                onMapelLoaded: (detail) {
                  setState(() {
                    _mapelDetail = detail;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
