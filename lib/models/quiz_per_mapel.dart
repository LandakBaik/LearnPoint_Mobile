import 'package:flutter/material.dart';

class QuizPerMapelM {
  final String title;
  final String subtitle;
  final Color color;
  final String? menuImageAsset;

  QuizPerMapelM({
    required this.title,
    required this.subtitle,
    required this.color,
    this.menuImageAsset,
  });
}

final List<QuizPerMapelM> quizMapel = [
  QuizPerMapelM(
    title: 'Geometri',
    subtitle: 'Bangun datar & ruang',
    color: const Color(0xFF3674D9),
    menuImageAsset: 'assets/images/planet1list.png',
  ),
  QuizPerMapelM(
    title: 'Logaritma',
    subtitle: 'Sifat & persamaan logaritma',
    color: const Color(0xFF218B5B),
    menuImageAsset: 'assets/images/planet1list.png',
  ),
  QuizPerMapelM(
    title: 'Aljabar',
    subtitle: 'Operasi bentuk aljabar',
    color: const Color(0xFFD97706),
    menuImageAsset: 'assets/images/planet1list.png',
  ),
  QuizPerMapelM(
    title: 'Trigonometri',
    subtitle: 'Sudut & perbandingan segitiga',
    color: const Color(0xFFDC2626),
    menuImageAsset: 'assets/images/planet1list.png',
  ),
  QuizPerMapelM(
    title: 'Statistika',
    subtitle: 'Penyajian & pengolahan data',
    color: const Color(0xFF9333EA),
    menuImageAsset: 'assets/images/planet1list.png',
  ),
  QuizPerMapelM(
    title: 'Peluang',
    subtitle: 'Kombinatorika & probabilitas',
    color: const Color(0xFF0891B2),
    menuImageAsset: 'assets/images/planet1list.png',
  ),
  QuizPerMapelM(
    title: 'Kalkulus',
    subtitle: 'Limit, turunan & integral',
    color: const Color(0xFFDB2777),
    menuImageAsset: 'assets/images/planet1list.png',
  ),
  QuizPerMapelM(
    title: 'Matriks',
    subtitle: 'Determinan & invers matriks',
    color: const Color(0xFF4F46E5),
    menuImageAsset: 'assets/images/planet1list.png',
  ),
  QuizPerMapelM(
    title: 'Vektor',
    subtitle: 'Besaran & arah ruang',
    color: const Color(0xFF059669),
    menuImageAsset: 'assets/images/planet1list.png',
  ),
];
