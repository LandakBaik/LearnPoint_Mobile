import 'package:flutter/material.dart';

class QuizPerMapelM {
  final String title;
  final String subtitle;
  final Color color;

  QuizPerMapelM({
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

final List<QuizPerMapelM> quizMapel = [
  QuizPerMapelM(
    title: 'Geometri',
    subtitle: 'Bangun datar & ruang',
    color: Color(0xFF3674D9),
  ),
  QuizPerMapelM(
    title: 'Logaritma',
    subtitle: 'Sifat & persamaan logaritma',
    color: Color(0xFF218B5B),
  ),
  QuizPerMapelM(
    title: 'Aljabar',
    subtitle: 'Operasi bentuk aljabar',
    color: Color(0xFFD97706),
  ),
  QuizPerMapelM(
    title: 'Trigonometri',
    subtitle: 'Sudut & perbandingan segitiga',
    color: Color(0xFFDC2626),
  ),
  QuizPerMapelM(
    title: 'Statistika',
    subtitle: 'Penyajian & pengolahan data',
    color: Color(0xFF9333EA),
  ),
];
