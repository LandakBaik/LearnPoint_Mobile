import 'package:flutter/material.dart';

enum QuizVisualType {
  cube3d,
  prism3d,
  pyramid3d,
  cylinder3d,
  sphere3d,
  cone3d,
  octahedron3d,
  torus3d,
  dodecahedron3d,
  star3d,
}

class QuizPlayQuestionModel {
  final String question;
  final List<String> options;
  final int correctIndex;
  final QuizVisualType visualType;
  final int rewardGems;

  const QuizPlayQuestionModel({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.visualType,
    this.rewardGems = 5,
  });
}

final List<QuizPlayQuestionModel> defaultQuizPlayQuestions = [
  const QuizPlayQuestionModel(
    question:
        'Bangun ruang apakah yang memiliki 6 sisi berbentuk persegi yang sama luas?',
    options: [
      'Prisma Segitiga',
      'Kubus',
      'Limas Segiempat',
      'Tabung',
    ],
    correctIndex: 1,
    visualType: QuizVisualType.cube3d,
  ),
  const QuizPlayQuestionModel(
    question:
        'Berapakah jumlah seluruh titik sudut yang dimiliki oleh bangun ruang balok?',
    options: [
      '6 Titik Sudut',
      '8 Titik Sudut',
      '10 Titik Sudut',
      '12 Titik Sudut',
    ],
    correctIndex: 1,
    visualType: QuizVisualType.prism3d,
  ),
  const QuizPlayQuestionModel(
    question:
        'Bangun ruang yang memiliki alas berbentuk segi empat dan 4 sisi tegak berbentuk segitiga disebut?',
    options: [
      'Limas Segiempat',
      'Kerucut',
      'Prisma Segiempat',
      'Bola',
    ],
    correctIndex: 0,
    visualType: QuizVisualType.pyramid3d,
  ),
  const QuizPlayQuestionModel(
    question:
        'Bangun ruang sisi lengkung yang memiliki dua sisi berbentuk lingkaran yang sejajar dan kongruen adalah?',
    options: [
      'Kerucut',
      'Bola',
      'Tabung',
      'Limas Segitiga',
    ],
    correctIndex: 2,
    visualType: QuizVisualType.cylinder3d,
  ),
  const QuizPlayQuestionModel(
    question:
        'Manakah rumus yang tepat untuk menghitung volume sebuah kubus dengan panjang rusuk s?',
    options: [
      'V = 6 × s²',
      'V = s × s × s',
      'V = 4 × s',
      'V = ½ × a × t',
    ],
    correctIndex: 1,
    visualType: QuizVisualType.cube3d,
  ),
  const QuizPlayQuestionModel(
    question:
        'Bangun ruang yang hanya memiliki 1 sisi lengkung dan tidak memiliki rusuk maupun titik sudut adalah?',
    options: [
      'Tabung',
      'Kerucut',
      'Bola',
      'Prisma',
    ],
    correctIndex: 2,
    visualType: QuizVisualType.sphere3d,
  ),
  const QuizPlayQuestionModel(
    question:
        'Sebuah kerucut memiliki alas berbentuk lingkaran dan berapa banyak titik puncak?',
    options: [
      '1 Titik Puncak',
      '2 Titik Puncak',
      '3 Titik Puncak',
      'Tidak Punya',
    ],
    correctIndex: 0,
    visualType: QuizVisualType.cone3d,
  ),
  const QuizPlayQuestionModel(
    question:
        'Berapakah jumlah rusuk yang dimiliki oleh sebuah kubus?',
    options: [
      '6 Rusuk',
      '8 Rusuk',
      '12 Rusuk',
      '16 Rusuk',
    ],
    correctIndex: 2,
    visualType: QuizVisualType.cube3d,
  ),
  const QuizPlayQuestionModel(
    question:
        'Jika sebuah kubus memiliki panjang rusuk 5 cm, berapakah volumenya?',
    options: [
      '25 cm³',
      '100 cm³',
      '125 cm³',
      '150 cm³',
    ],
    correctIndex: 2,
    visualType: QuizVisualType.prism3d,
  ),
  const QuizPlayQuestionModel(
    question:
        'Jaring-jaring yang terdiri dari 2 lingkaran dan 1 persegi panjang akan membentuk bangun ruang?',
    options: [
      'Kerucut',
      'Tabung',
      'Limas',
      'Bola',
    ],
    correctIndex: 1,
    visualType: QuizVisualType.cylinder3d,
  ),
];

Color darkenColor(Color color, [double amount = 0.22]) {
  final hsl = HSLColor.fromColor(color);
  final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
  return hsl.withLightness(lightness).toColor();
}

Color lightenColor(Color color, [double amount = 0.12]) {
  final hsl = HSLColor.fromColor(color);
  final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
  return hsl.withLightness(lightness).toColor();
}
