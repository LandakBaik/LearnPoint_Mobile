import 'package:flutter/material.dart';

// nama    : IDEA BRILIANTA
// nim     : E41251668
// kelompok: 2
// golongan: E

import 'widgets/materi_header_widget.dart';
import 'widgets/header_profile_widget.dart';
import '../models/student_profile_model.dart';
import 'widgets/materi_section.dart';


class Materimapel extends StatelessWidget {
  const Materimapel({super.key});
  static const studentProfile = StudentProfileModel(
    name: 'Abimanyu',
    gradeClass: 'Kelas VIII-A',
    schoolName: 'SMP Merdeka',
    initials: 'AP',
    hasNotification: true,
  );

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;

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
                child: HeaderProfileWidget(profile: studentProfile),
              ),

              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(
                  screenwidth * 0.04,
                  24,
                  screenwidth * 0.04,
                  0,
                ),
                child: const MateriHeaderWidget(),
              ),

              const MateriSectionWidget()
            ],
          ),
        ),
      ),
    );
  }
}
