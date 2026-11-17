import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/features/siswa/quiz/models/quiz_per_mapel_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/quiz_level_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/screens/quiz_play_screen.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_level_map_section_widget.dart';

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
  Color _resolveBgColor(String sceneTheme) {
    switch (sceneTheme) {
      case 'chess1':
        return const Color(0xFF4B5335);
      case 'chess2':
        return const Color(0xFF6B6552);
      case 'chess':
      default:
        return const Color(0xFF0A4D5E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeTitle = widget.themeItem?.title ?? 'Geometri';
    final themeColor = widget.themeItem?.color ?? const Color(0xFF4338CA);
    final sceneTheme = widget.themeItem?.levelSceneTheme ?? 'chess';

    return Scaffold(
      backgroundColor: _resolveBgColor(sceneTheme),
      body: SafeArea(
        bottom: false,
        child: QuizLevelMapSectionWidget(
          themeTitle: themeTitle,
          themeColor: themeColor,
          sceneTheme: sceneTheme,
          levels: quizLevels,
          onLevelTap: (levelNode) {
            if (!levelNode.isUnlocked) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${levelNode.title} masih terkunci! Selesaikan level sebelumnya dulu.',
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
              return;
            }

            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => QuizPlayScreen(
                  themeTitle: themeTitle,
                  levelNumber: levelNode.levelNumber,
                  themeColor: themeColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
