import 'package:flutter/material.dart';

import '../../models/quiz_level_model.dart';
import 'quiz_back_header_widget.dart';
import 'quiz_level_node_item_widget.dart';

class QuizLevelMapSectionWidget extends StatelessWidget {
  final String themeTitle;
  final Color themeColor;
  final List<QuizLevelNodeModel> levels;
  final ValueChanged<QuizLevelNodeModel>? onLevelTap;

  static const double _verticalStep = 135.0;
  static const double _topBottomPadding = 100.0;

  const QuizLevelMapSectionWidget({
    super.key,
    required this.themeTitle,
    required this.themeColor,
    required this.levels,
    this.onLevelTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalMapHeight =
        (levels.length - 1) * _verticalStep + (_topBottomPadding * 2);

    return Stack(
      children: [
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F5F9),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mapWidth = constraints.maxWidth;

              final List<Offset> nodeOffsets = List.generate(
                levels.length,
                (index) {
                  final node = levels[index];
                  final dx = mapWidth * node.xFactor;
                  final dy =
                      totalMapHeight - _topBottomPadding - (index * _verticalStep);
                  return Offset(dx, dy);
                },
              );

              final bgTileHeight = mapWidth * (16 / 9);
              final tileCount = (totalMapHeight / bgTileHeight).ceil() + 1;

              return SingleChildScrollView(
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
                      for (int i = 0; i < levels.length; i++)
                        Positioned(
                          left: nodeOffsets[i].dx - 65,
                          top: nodeOffsets[i].dy - 50,
                          width: 130,
                          child: QuizLevelNodeItemWidget(
                            node: levels[i],
                            accentColor: themeColor,
                            onTap: () => onLevelTap?.call(levels[i]),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Baris Tombol Kembali & Nama Tema Quiz di atas peta
        QuizBackHeaderWidget(
          title: 'Peta Level - $themeTitle',
        ),
      ],
    );
  }
}
