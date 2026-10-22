import 'package:flutter/material.dart';

import 'changepass.dart';
import 'notifikasi.dart';
import 'quizLevel.dart';
import '../models/student_profile_model.dart';
import '../models/materi_page.dart';
import 'widgets/dashboard_header_widget.dart';
import '../models/quiz_per_mapel.dart';

// class QuizThemeItemModel {
//   final String title;
//   final String subtitle;
//   final Color color;

//   const QuizThemeItemModel({
//     required this.title,
//     required this.subtitle,
//     required this.color,
//   });
// }

class QuizPerMapel extends StatefulWidget {

  final MateriModel? subject;

  const QuizPerMapel({super.key, this.subject});


  @override
  State<QuizPerMapel> createState() => _QuizPerMapelState();
}

class _QuizPerMapelState extends State<QuizPerMapel> {
    final ScrollController _scrollController = ScrollController();
  // Dummy Profile Data
  static const studentProfile = StudentProfileModel(
    name: 'Abimanyu',
    gradeClass: 'Kelas VIII-A',
    schoolName: 'SMP Merdeka',
    initials: 'AP',
    hasNotification: true,
  );
  @override
void initState() {
  super.initState();

  _scrollController.addListener(() {
    setState(() {});
  });
}

@override
void dispose() {
  _scrollController.dispose();
  super.dispose();
}

  // Daftar pilihan tema quiz (contoh tema pada mapel Matematika)
//   final List<QuizThemeItemModel> _quizThemes = const [];

  @override
  Widget build(BuildContext context) {
    final subjectTitle = widget.subject?.materi ?? 'Matematika';

    return Scaffold(
      backgroundColor: const Color(0xFF4338CA),
      body: SafeArea(
        child: Stack(
          children: [
            // Layer Background (Akan diisi gambar background nantinya)
            Positioned.fill(child: Container(color: const Color(0xFF4338CA))),

            // Layer Konten Utama
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Atas menggunakan template DashboardHeaderWidget
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

                // Info Mapel & Tombol Kembali
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
                          'Pilih Tema Quiz - ${subjectTitle[0].toUpperCase()}${subjectTitle.substring(1)}',
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

                // 2. Konten Utama: Daftar Pilihan Quiz (Lingkaran Kiri-Kanan dengan Judul di Dalam Lingkaran)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cardHorizontalMargin = constraints.maxWidth < 360
                            ? 16.0
                            : 24.0;
                        // Tinggi 1 tile gambar mengikuti rasio loopbg1.png (9:16 -> tinggi = lebar * 16/9)
                        final bgTileHeight = constraints.maxWidth * (16 / 9);
                        final scrollOffset = _scrollController.hasClients
                            ? _scrollController.offset
                            : 0.0;
                        // Karena ListView menggunakan reverse: true, saat di-scroll ke atas background ikut bergerak turun secara looping
                        final loopedOffset = scrollOffset % bgTileHeight;
                        final tileCount =
                            (constraints.maxHeight / bgTileHeight).ceil() + 2;

                        return Stack(
                          children: [
                            // Background Gambar Looping (loopbg1.png) mengikuti scroll ListView
                            for (int i = -1; i < tileCount; i++)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: (i * bgTileHeight) - loopedOffset,
                                height: bgTileHeight,
                                child: Image.asset(
                                  'assets/images/loopbg1.png',
                                  fit: BoxFit.fill,
                                ),
                              ),

                            // Daftar Pilihan Quiz
                            ListView.builder(
                              reverse: true,
                              controller: _scrollController,
                              itemCount: quizMapel.length,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              itemBuilder: (context, index) {
                                final item = quizMapel[index];
                                final isCircleOnLeft = index % 2 == 0;

                                return _buildQuizCircleItem(
                                  item: item,
                                  isCircleOnLeft: isCircleOnLeft,
                                  horizontalMargin: cardHorizontalMargin,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            QuizLevel(themeItem: item),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // 3. Jarak / Ruang Bawah antara Daftar Pilihan Quiz dan Bawah Layar
                // untuk penempatan layout karakter user nantinya
                Container(
                  width: double.infinity,
                  height: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Text(
                    'Area Karakter User',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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

  Widget _buildQuizCircleItem({
    required QuizPerMapelM item,
    required bool isCircleOnLeft,
    required double horizontalMargin,
    VoidCallback? onTap,
  }) {
    // Lingkaran dengan judul berada di dalam lingkaran
    final circleWidget = Container(
      width: 158,
      height: 158,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 10),
      child: Align(
        alignment: isCircleOnLeft
            ? Alignment.centerLeft
            : Alignment.centerRight,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: circleWidget,
        ),
      ),
    );
  }
}
