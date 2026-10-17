import 'package:flutter/material.dart';

import 'materimapel.dart';
import 'changepass.dart';
import '../models/student_profile_model.dart';
import 'widgets/dashboard_header_widget.dart';
import 'widgets/inverted_top_curve_clipper.dart';
import 'widgets/subject_materi_card_widget.dart';
import '../models/materi_page.dart';
import 'notifikasi.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
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

              Center(
                child: SizedBox(
                  height: 100,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lingkaran Kiri (Paling Bawah)
                      Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Lingkaran Tengah (Paling Atas)
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Lingkaran Kanan (Agak di bawahnya)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3 Star IconButtons di sebelah kiri (dengan Align agar tetap di kiri)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical:8),
                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.star_rounded, color: Colors.white, size: 28),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.star_rounded, color: Colors.white, size: 28),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.star_rounded, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ),
              ),

              // Daftar mata pelajaran / kuis
              Expanded(
                child: ClipPath(
                  clipper: InvertedTopCurveClipper(
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cardHorizontalMargin = constraints.maxWidth < 360
                            ? 12.0
                            : 20.0;

                        return ListView.builder(
                          itemCount: subjek.length,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            final sub = subjek[index];
                            final isCircleOnLeft = index % 2 == 0;

                            // Widget Lingkaran Polos Warna
                            final circleWidget = Container(
                              width: 158,
                              height: 158,
                              decoration: BoxDecoration(
                                color: sub.iconColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: sub.iconColor.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            );

                            final textWidget = Expanded(
                              child: Column(
                                crossAxisAlignment: isCircleOnLeft
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    sub.materi,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C2C2C),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    sub.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );

                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: cardHorizontalMargin,
                                vertical: 8,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                // color: sub.color,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const Materimapel(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Row(
                                  children: isCircleOnLeft
                                      ? [
                                          circleWidget,
                                          const SizedBox(width: 16),
                                          textWidget,
                                        ]
                                      : [
                                          textWidget,
                                          const SizedBox(width: 16),
                                          circleWidget,
                                        ],
                                ),
                              ),
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

