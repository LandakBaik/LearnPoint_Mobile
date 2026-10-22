import 'package:flutter/material.dart';

class MateriModel {
  final String materi;
  final Color color;
  final Color iconColor;
  final IconData icon;
  final String description;

  MateriModel({
    required this.materi,
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.description,
  });
}

final List<MateriModel> subjek = [

  MateriModel(
    materi: 'matematika',
    color: Color(0xFFEAF2FF),
    iconColor: Color(0xFF3674D9),
    icon: Icons.calculate_outlined,
    description: 'Angka, rumus, dan logika',
  ),

  MateriModel(
    materi: 'Fisika',
    color: const Color(0xFFEAFBF3),
    iconColor: const Color(0xFF218B5B),
    icon: Icons.bolt_outlined,
    description: 'Energi, gaya, dan gerak',
  ),

  MateriModel(
    materi: 'Biologi',
    color: const Color(0xFFFFF7E6),
    iconColor: const Color(0xFFD97706),
    icon: Icons.eco_outlined,
    description: 'Makhluk hidup dan ekosistem',
  ),

  MateriModel(
    materi: 'Bahasa Indonesia',
    color: const Color(0xFFFEE2E2),
    iconColor: const Color(0xFFDC2626),
    icon: Icons.menu_book_outlined,
    description: 'Tata bahasa dan literasi',
  ),

  MateriModel(
    materi: 'Kimia',
    color: const Color(0xFFF3E8FF),
    iconColor: const Color(0xFF9333EA),
    icon: Icons.science_outlined,
    description: 'Struktur dan reaksi zat',
  ),
];
