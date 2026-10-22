import 'dart:math';

final Random _random = Random();

double _randomXFactor() => 0.15 + (0.70 / 99) * _random.nextInt(100);

class QuizLevelNodeModel {
  final int levelNumber;
  final String title;
  final double xFactor;
  final bool isUnlocked;

  QuizLevelNodeModel({
    required this.levelNumber,
    required this.title,
    double? xFactor,
    this.isUnlocked = true,
  }) : xFactor = xFactor ?? _randomXFactor();
}

final List<QuizLevelNodeModel> quizLevels = List.generate(
  30,
  (index) => QuizLevelNodeModel(
    levelNumber: index + 1,
    title: 'Level ${index + 1}',
    isUnlocked: index < 5,
  ),
);
