import 'package:flutter/material.dart';

// nama    : IDEA BRILIANTA
// nim     : E41251668
// kelompok: 2
// golongan: E

import 'materimapel.dart';
import 'changepass.dart';
import '../models/student_profile_model.dart';
import 'widgets/header_profile_widget.dart';
import 'widgets/inverted_top_curve_clipper.dart';
import 'widgets/subject_materi_card_widget.dart';
import '../models/materi_page.dart';
import 'notifikasi.dart';

class Materi extends StatelessWidget {
  const Materi({super.key});
  // Dummy Profile Data
  static const studentProfile = StudentProfileModel(
    name: 'Abimanyu',
    gradeClass: 'Kelas VIII-A',
    schoolName: 'SMP Merdeka',
    initials: 'AP',
    hasNotification: true,
  );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final textScale = (screenWidth / 400).clamp(0.9, 1.1).toDouble();

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
                child: HeaderProfileWidget(
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
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Text(
                          'Materi Pembelajaran',
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
                          'Materi Pembelajaran',
                          style: TextStyle(
                            fontSize: 30 * textScale,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Temukan materi untuk belajarmu',
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

              // Search
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari materi...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),

              // Daftar mata pelajaran
              Expanded(
                child: ClipPath(
                  clipper: InvertedTopCurveClipper(
                    cornerRadius: 15,
                    curveDepth: 20,
                    centerX: 0.5,
                    curveHalfWidth: 0.42,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.fromLTRB(0, 45, 0, 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35.0), // Atas kiri
                        topRight: Radius.circular(35.0),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cardHorizontalMargin = constraints.maxWidth < 360
                            ? 12.0
                            : 20.0;

                        return ListView.builder(
                          itemCount: subjek.length,
                          itemBuilder: (context, index) {
                            final sub = subjek[index];

                            return SubjectMateriCardWidget(
                              subject: sub,
                              imageUrl: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?auto=format&fit=crop&w=1200&q=80',
                              elevation: index.isEven ? 2 : 0,
                              horizontalMargin: cardHorizontalMargin,
                              ontap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Materimapel(),
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
            ],
          ),
        ),
      ),
    );
  }
}
