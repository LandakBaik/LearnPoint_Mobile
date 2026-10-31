import 'package:flutter/material.dart';

import 'quizLevel.dart';
import '../models/materi_page.dart';
import '../models/quiz_per_mapel.dart';
import 'widgets/quiz_back_header_widget.dart';
import 'widgets/quiz_evaporating_hand_decoration_widget.dart';
import 'widgets/quiz_per_mapel_background_widget.dart';
import 'widgets/quiz_theme_list_section_widget.dart';

class QuizPerMapel extends StatefulWidget {
  final MateriModel? subject;

  const QuizPerMapel({super.key, this.subject});

  @override
  State<QuizPerMapel> createState() => _QuizPerMapelState();
}

class _QuizPerMapelState extends State<QuizPerMapel> {
  @override
  Widget build(BuildContext context) {
    final rawTitle = widget.subject?.materi ?? 'Matematika';
    final subjectTitle = rawTitle.isNotEmpty
        ? '${rawTitle[0].toUpperCase()}${rawTitle.substring(1)}'
        : rawTitle;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 51, 60),
      body: Stack(
        children: [
          // 1. Layer Background: Satu warna sesuai planet (sedikit lebih gelap)
          //    + efek kabut gelap bergelombang di atas dan bawah layar
          const Positioned.fill(
            child: QuizPerMapelBackgroundWidget(
              baseColor: Color(0xFF042228),
            ),
          ),

          // 2. Layer Hiasan hand1.png dengan efek animasi menguap
          const Positioned.fill(
            child: QuizEvaporatingHandDecorationWidget(),
          ),

          // 3. Layer Konten Utama
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Atas: Tombol Back & Judul Mapel
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: QuizBackHeaderWidget(
                    title: subjectTitle,
                  ),
                ),

                // Area Radial Menu (Planet + Ring Bergelombang + Pilihan Tema)
                Expanded(
                  child: QuizThemeListSectionWidget(
                    subject: widget.subject,
                    subjectTitle: subjectTitle,
                    themes: quizMapel,
                    onThemeTap: (item) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizLevel(themeItem: item),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
