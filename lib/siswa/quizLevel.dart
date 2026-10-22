import 'package:flutter/material.dart';

import 'changepass.dart';
import 'notifikasi.dart';
import '../models/student_profile_model.dart';
import '../models/quiz_per_mapel.dart';
import '../models/quiz_level_model.dart';
import 'widgets/dashboard_header_widget.dart';

class QuizLevel extends StatefulWidget {
  final QuizPerMapelM? themeItem;

  const QuizLevel({
    super.key,
    this.themeItem,
  });

  @override
  State<QuizLevel> createState() => _QuizLevelState();
}

class _QuizLevelState extends State<QuizLevel> {
  static const studentProfile = StudentProfileModel(
    name: 'Abimanyu',
    gradeClass: 'Kelas VIII-A',
    schoolName: 'SMP Merdeka',
    initials: 'AP',
    hasNotification: true,
  );

  // Jarak vertikal antar node level
  static const double _verticalStep = 135.0;
  static const double _topBottomPadding = 100.0;

  @override
  Widget build(BuildContext context) {
    final themeTitle = widget.themeItem?.title ?? 'Geometri';
    final themeColor = widget.themeItem?.color ?? const Color(0xFF4338CA);

    final totalMapHeight =
        (quizLevels.length - 1) * _verticalStep + (_topBottomPadding * 2);

    return Scaffold(
      backgroundColor: const Color(0xFF4338CA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Atas
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

            // Baris Tombol Kembali & Nama Tema Quiz
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              child: Row(
                children: [
                  if (Navigator.of(context).canPop())
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
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
                  Expanded(
                    child: Text(
                      'Peta Level - $themeTitle',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 2. Konten Utama Peta Level (Polos, siap diberi background nanti)
            Expanded(
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9), // Warna dasar polos peta
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final mapWidth = constraints.maxWidth;

                    // Hitung titik koordinat pusat setiap lingkaran (dari bawah ke atas)
                    final List<Offset> nodeOffsets = List.generate(
                      quizLevels.length,
                      (index) {
                        final node = quizLevels[index];
                        final dx = mapWidth * node.xFactor;
                        final dy =
                            totalMapHeight - _topBottomPadding - (index * _verticalStep);
                        return Offset(dx, dy);
                      },
                    );

                    final bgTileHeight = mapWidth * (16 / 9);
                    final tileCount =
                        (totalMapHeight / bgTileHeight).ceil() + 1;

                    return SingleChildScrollView(
                      // reverse: true, // Mulai dari bawah (Level 1) ke atas
                      child: SizedBox(
                        width: mapWidth,
                        height: totalMapHeight,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Layer 1: Background Gambar Looping (loopbg1.png) sepanjang tinggi peta
                            for (int i = 0; i < tileCount; i++)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: i * bgTileHeight,
                                height: bgTileHeight,
                                child: Image.asset(
                                  'assets/images/loopbg1.png',
                                  fit: BoxFit.fill,
                                ),
                              ),

                            // Layer 2: Node Level (Judul + Tombol Bulat)
                            for (int i = 0; i < quizLevels.length; i++)
                              Positioned(
                                left: nodeOffsets[i].dx - 65,
                                top: nodeOffsets[i].dy - 50,
                                width: 130,
                                child: _buildLevelNode(
                                  node: quizLevels[i],
                                  accentColor: themeColor,
                                  onTap: () {},
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelNode({
    required QuizLevelNodeModel node,
    required Color accentColor,
    VoidCallback? onTap,
  }) {
    final Color circleColor = node.isUnlocked
        ? const Color(0xFF4338CA)
        : const Color(0xFF94A3B8);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Judul Level di bagian atas lingkaran
        Text(
          node.title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),

        const SizedBox(height: 6),

        // 2. Lingkaran Node Level
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: node.isUnlocked
                    ? [
                        const Color(0xFF4338CA),
                        circleColor,
                      ]
                    : [
                        const Color(0xFFCBD5E1),
                        circleColor,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${node.levelNumber}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
