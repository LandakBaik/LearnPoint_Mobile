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
    color: Color(0xFFEAFBF3),
    iconColor: Color(0xFF218B5B),
    icon: Icons.bolt_outlined,
    description: 'Energi, gaya, dan gerak',
  ),
];
