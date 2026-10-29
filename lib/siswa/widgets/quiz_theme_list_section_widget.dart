import 'package:flutter/material.dart';

import '../../models/quiz_per_mapel.dart';
import 'quiz_back_header_widget.dart';
import 'quiz_theme_circle_item_widget.dart';

class QuizThemeListSectionWidget extends StatelessWidget {
  final String subjectTitle;
  final List<QuizPerMapelM> themes;
  final ScrollController scrollController;
  final ValueChanged<QuizPerMapelM>? onThemeTap;

  const QuizThemeListSectionWidget({
    super.key,
    required this.subjectTitle,
    required this.themes,
    required this.scrollController,
    this.onThemeTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedSubject = subjectTitle.isNotEmpty
        ? '${subjectTitle[0].toUpperCase()}${subjectTitle.substring(1)}'
        : subjectTitle;

    return Container(
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
          final cardHorizontalMargin = constraints.maxWidth < 360 ? 16.0 : 24.0;
          final bgTileHeight = constraints.maxWidth * (16 / 9);

          return AnimatedBuilder(
            animation: scrollController,
            builder: (context, child) {
              final scrollOffset = scrollController.hasClients
                  ? scrollController.offset
                  : 0.0;
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

                  child!,
                ],
              );
            },
            child: Stack(
              children: [
                // Daftar Pilihan Quiz
                ListView.builder(
                  reverse: true,
                  controller: scrollController,
                  itemCount: themes.length,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemBuilder: (context, index) {
                    final item = themes[index];
                    final isCircleOnLeft = index % 2 == 0;

                    return QuizThemeCircleItemWidget(
                      item: item,
                      isCircleOnLeft: isCircleOnLeft,
                      horizontalMargin: cardHorizontalMargin,
                      onTap: () => onThemeTap?.call(item),
                    );
                  },
                ),

                // Info Mapel & Tombol Kembali di atas background daftar tema
                QuizBackHeaderWidget(
                  title: 'Pilih Tema Quiz - $formattedSubject',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
