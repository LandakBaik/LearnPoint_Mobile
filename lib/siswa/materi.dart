import 'package:flutter/material.dart';

import '../models/student_profile_model.dart';
import 'widgets/header_profile_widget.dart';
import 'widgets/inverted_top_curve_clipper.dart';
import 'widgets/subject_materi_card_widget.dart';
import '../models/materi_page.dart';

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
                child: HeaderProfileWidget(profile: studentProfile),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Materi Pembelajaran',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color(0xFF3D168F),
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                          Shadow(
                            color: Color(0x55000000),
                            offset: Offset(0, 7),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Temukan materi untuk belajarmu',
                        style: TextStyle(
                          fontSize: 15,
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
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari materi...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              // Daftar mata pelajaran
              Expanded(
                child: ClipPath(
                  clipper: InvertedTopCurveClipper(),
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
                    child: ListView.builder(
                      itemCount: subjek.length,
                      itemBuilder: (context, index) {
                        final sub = subjek[index];

                        return SubjectMateriCardWidget(
                          subject: sub,
                          imageUrl:
                              'https://images.unsplash.com/photo-1509228468518-180dd4864904?auto=format&fit=crop&w=1200&q=80',
                          elevation: index.isEven ? 2 : 0,
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
