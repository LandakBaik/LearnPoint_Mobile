import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/features/siswa/quiz/config/quiz_assets.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/quiz_per_mapel_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/quiz_level_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/screens/quiz_play_screen.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_level_map_section_widget.dart';

class QuizLevel extends StatefulWidget {
  final QuizPerMapelM? themeItem;
  final QuizScenePreset? scenePreset;
  final String? sceneThemeOverride;

  const QuizLevel({
    super.key,
    this.themeItem,
    this.scenePreset,
    this.sceneThemeOverride,
  });

  @override
  State<QuizLevel> createState() => _QuizLevelState();
}

class _QuizLevelState extends State<QuizLevel> {
  QuizScenePreset get _resolvedPreset {
    if (widget.scenePreset != null) {
      return widget.scenePreset!;
    }
    final sceneId =
        widget.sceneThemeOverride ?? widget.themeItem?.levelSceneTheme ?? 'chess';
    return QuizAssets.resolveScenePreset(sceneId: sceneId);
  }

  @override
  Widget build(BuildContext context) {
    final themeTitle = widget.themeItem?.title ?? 'Geometri';
    final themeColor = widget.themeItem?.color ?? const Color(0xFF4338CA);
    final activePreset = _resolvedPreset;

    return Scaffold(
      backgroundColor: activePreset.fallbackBgColor,
      body: SafeArea(
        bottom: false,
        child: QuizLevelMapSectionWidget(
          themeTitle: themeTitle,
          themeColor: themeColor,
          scenePreset: activePreset,
          sceneTheme: activePreset.id,
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
