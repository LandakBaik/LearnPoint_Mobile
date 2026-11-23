import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// nama    : IDEA BRILIANTA
// nim     : E41251668
// kelompok: 2
// golongan: E

import 'package:learnpoint_mobile/features/siswa/dashboard/screens/notifikasi_screen.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/widgets/dashboard_header_widget.dart';
import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
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

  @override
  State<Materimapel> createState() => _MaterimapelState();
}

class _MaterimapelState extends State<Materimapel> {
  MapelDetailModel? _mapelDetail;

  String? get _kelasLabel {
    final namaKelas = _mapelDetail?.namaKelas?.trim();
    if (namaKelas == null || namaKelas.isEmpty) return null;
    return namaKelas.toLowerCase().startsWith('kelas')
        ? namaKelas
        : 'Kelas $namaKelas';
  }

  String get _subtitleDescription {
    final parts = <String>[];
    final guruList = widget.subject?.guru ?? const [];
    if (guruList.isNotEmpty) {
      parts.add('Guru: ${guruList.join(', ')}');
    }
    final semester = _mapelDetail?.semester?.trim();
    if (semester != null && semester.isNotEmpty) {
      parts.add(
        semester.toLowerCase().startsWith('semester')
            ? semester
            : 'Semester $semester',
      );
    }
    final tahun = _mapelDetail?.tahunAjaran?.trim();
    if (tahun != null && tahun.isNotEmpty) {
      parts.add(tahun);
    }
    if (parts.isEmpty) {
      return widget.subject?.description ?? '';
    }
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final subjectName =
        _mapelDetail?.namaMapel ?? widget.subject?.materi ?? 'Mata Pelajaran';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
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
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
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
                          const SizedBox(height: 14),
                          InkWell(
                            onTap: widget.onBackTap ??
                                () => Navigator.maybePop(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.chevron_left_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Mata pelajaran',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
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
                  bottom: -68,
                  child: MateriHeaderWidget(
                    subjectName: subjectName,
                    description: _subtitleDescription,
                    kelasLabel: _kelasLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 84),
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
    );
  }
}
