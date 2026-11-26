import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/features/siswa/quiz/config/quiz_assets.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/quiz_level_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/quiz_per_mapel_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/screens/quiz_play_screen.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/services/quiz_api_service.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_difficulty_locked_dialog_widget.dart';
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
  QuizAdventureMapData _mapData = QuizAdventureMapData.defaultFallback();
  String _selectedDifficulty = 'Mudah';
  bool _hasInitializedDifficulty = false;

  @override
  void initState() {
    super.initState();
    _loadLevelsFromApi();
  }

  Future<void> _loadLevelsFromApi() async {
    final quizId = widget.themeItem?.id;
    if (quizId == null) return;

    try {
      final apiMapData = await QuizApiService.fetchQuizAdventureMap(quizId);
      if (!mounted) return;
      setState(() {
        _mapData = apiMapData;
        if (!_hasInitializedDifficulty ||
            !_mapData.activeDifficulties.contains(_selectedDifficulty)) {
          _selectedDifficulty = apiMapData.currentDifficulty;
          _hasInitializedDifficulty = true;
        }
      });
    } catch (_) {
      // Tetap gunakan fallback `_mapData` jika offline atau gagal memuat
    }
  }

  void _handleSelectDifficulty(String targetDifficulty) {
    if (targetDifficulty.toLowerCase() == _selectedDifficulty.toLowerCase()) {
      return;
    }

    final unlocked = _mapData.isDifficultyUnlocked(targetDifficulty);
    if (!unlocked) {
      _showLockedDifficultyModal(targetDifficulty);
      return;
    }

    setState(() {
      _selectedDifficulty = targetDifficulty;
    });
  }

  void _handleNextDifficultyTap() {
    final nextDiff = _mapData.nextDifficultyAfter(_selectedDifficulty);
    if (nextDiff == null) return;

    final unlocked = _mapData.isDifficultyUnlocked(nextDiff);
    if (!unlocked) {
      _showLockedDifficultyModal(nextDiff);
      return;
    }

    setState(() {
      _selectedDifficulty = nextDiff;
    });
  }

  Future<void> _showLockedDifficultyModal(String targetDifficulty) async {
    final currentLevels = _mapData.levelsFor(_selectedDifficulty);
    final availableLevels = currentLevels
        .where((l) => l.hasQuestions)
        .toList();
    final completedCount = availableLevels
        .where((l) => l.isCompleted)
        .length;

    QuizLevelNodeModel? activeNode;
    for (final lvl in availableLevels) {
      if (lvl.isUnlocked && !lvl.isCompleted) {
        activeNode = lvl;
        break;
      }
    }
    activeNode ??= availableLevels.isNotEmpty ? availableLevels.first : null;

    await QuizDifficultyLockedDialogWidget.show(
      context,
      currentDifficulty: _selectedDifficulty,
      targetDifficulty: targetDifficulty,
      completedLevels: completedCount,
      totalAvailableLevels: availableLevels.length,
      activeLevelNode: activeNode,
      onPlayActiveLevel: activeNode != null
          ? () => _openLevelToPlay(activeNode!)
          : null,
    );
  }

  Future<void> _openLevelToPlay(QuizLevelNodeModel levelNode) async {
    final themeTitle = widget.themeItem?.title ?? 'Geometri';
    final themeColor = widget.themeItem?.color ?? const Color(0xFF4338CA);
    final quizId = widget.themeItem?.id;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizPlayScreen(
          quizId: quizId,
          themeTitle: '$themeTitle ($_selectedDifficulty)',
          levelNumber: levelNode.arcLevelNum,
          arc: levelNode.arc ?? _selectedDifficulty,
          arcLevelNum: levelNode.arcLevelNum,
          step: levelNode.step,
          themeColor: themeColor,
        ),
      ),
    );

    if (mounted && quizId != null) {
      await _loadLevelsFromApi();
    }
  }

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
    final quizId = widget.themeItem?.id;

    final currentLevels = _mapData.levelsFor(_selectedDifficulty);
    final nextDifficulty = _mapData.nextDifficultyAfter(_selectedDifficulty);
    final isNextUnlocked = nextDifficulty != null &&
        _mapData.isDifficultyUnlocked(nextDifficulty);

    return Scaffold(
      backgroundColor: activePreset.fallbackBgColor,
      body: SafeArea(
        bottom: false,
        child: QuizLevelMapSectionWidget(
          themeTitle: themeTitle,
          themeColor: themeColor,
          scenePreset: activePreset,
          sceneTheme: activePreset.id,
          levels: currentLevels,
          currentDifficulty: _selectedDifficulty,
          activeDifficulties: _mapData.activeDifficulties,
          nextDifficulty: nextDifficulty,
          isNextDifficultyUnlocked: isNextUnlocked,
          onSelectDifficulty: _handleSelectDifficulty,
          onNextDifficultyTap: _handleNextDifficultyTap,
          onLevelTap: (levelNode) async {
            // 1. Jika level pada difficulty ini belum diinput soal oleh guru -> terkunci
            if (!levelNode.hasQuestions) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${levelNode.title} ($_selectedDifficulty) terkunci karena belum diinput soal oleh guru.',
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
              return;
            }

            // 2. Jika level sudah ada soal tapi belum terbuka karena level sebelumnya belum selesai
            if (!levelNode.isUnlocked) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${levelNode.title} ($_selectedDifficulty) masih terkunci! Selesaikan level sebelumnya dulu.',
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
              return;
            }

            // 3. Jika level sudah selesai dikerjakan
            if (quizId != null && levelNode.isCompleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${levelNode.title} ($_selectedDifficulty) sudah selesai dikerjakan (Skor: ${levelNode.skorLevel}%, ★${levelNode.bintang}).',
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
              return;
            }

            await _openLevelToPlay(levelNode);
          },
        ),
      ),
    );
  }
}
