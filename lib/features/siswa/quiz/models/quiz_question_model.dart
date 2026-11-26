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
  final int? id;
  final String question;
  final List<String> options;
  /// Key asli untuk setiap opsi (misal `['a', 'b', 'c', 'd']`), digunakan saat submit ke backend
  final List<String> optionKeys;
  /// Index jawaban benar jika diketahui di client (untuk mode lokal / offline).
  /// Jika berasal dari endpoint `siswaKerjakan`, bernilai `-1` karena dikoreksi di server saat submit.
  final int correctIndex;
  final QuizVisualType visualType;
  final int rewardGems;
  final String? savedAnswerKey;
  final String? imageUrl;

  const QuizPlayQuestionModel({
    this.id,
    required this.question,
    required this.options,
    this.optionKeys = const ['a', 'b', 'c', 'd'],
    this.correctIndex = -1,
    this.visualType = QuizVisualType.cube3d,
    this.rewardGems = 5,
    this.savedAnswerKey,
    this.imageUrl,
  });

  String keyAt(int index) {
    if (index >= 0 && index < optionKeys.length) {
      return optionKeys[index];
    }
    return String.fromCharCode(97 + index); // 'a', 'b', 'c', 'd'
  }

  int indexForKey(String key) {
    final clean = key.trim().toLowerCase();
    return optionKeys.indexWhere((k) => k.toLowerCase() == clean);
  }

  /// Factory untuk mengubah item `soals` dari `GET /api/siswa/kuis/{quiz}/kerjakan`
  factory QuizPlayQuestionModel.fromApiJson(
    Map<String, dynamic> json, {
    int index = 0,
  }) {
    final keys = <String>[];
    final opts = <String>[];

    final rawPilihan = json['pilihan'];
    if (rawPilihan is Map) {
      for (final entry in rawPilihan.entries) {
        final k = entry.key.toString().trim().toLowerCase();
        final v = (entry.value ?? '').toString().trim();
        if (v.isNotEmpty || keys.length < 4) {
          keys.add(k);
          opts.add(v);
        }
      }
    } else if (rawPilihan is List) {
      for (int i = 0; i < rawPilihan.length; i++) {
        keys.add(String.fromCharCode(97 + i));
        opts.add((rawPilihan[i] ?? '').toString());
      }
    }

    if (opts.isEmpty) {
      keys.addAll(['a', 'b', 'c', 'd']);
      opts.addAll(['Pilihan A', 'Pilihan B', 'Pilihan C', 'Pilihan D']);
    }

    int resolvedCorrectIndex = -1;
    final rawKunci = json['kunci_jawaban']?.toString().trim().toLowerCase();
    if (rawKunci != null && rawKunci.isNotEmpty) {
      resolvedCorrectIndex = keys.indexWhere((k) => k == rawKunci);
    }

    final bobot = double.tryParse((json['bobot'] ?? 10).toString()) ?? 10.0;
    final visuals = QuizVisualType.values;

    return QuizPlayQuestionModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse((json['id'] ?? '').toString()),
      question: (json['pertanyaan'] ?? 'Pertanyaan Kuis').toString(),
      options: opts,
      optionKeys: keys,
      correctIndex: resolvedCorrectIndex,
      visualType: visuals[index % visuals.length],
      rewardGems: bobot.round().clamp(1, 100),
      savedAnswerKey: json['saved_answer']?.toString().trim().toLowerCase(),
      imageUrl: json['gambar_url']?.toString(),
    );
  }
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
