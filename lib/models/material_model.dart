import 'package:flutter/material.dart';

class MaterialModel {
  final String id;
  final String subject;
  final String title;
  final String typeLabel;
  final IconData typeIcon;
  final Color subjectBadgeColor;
  final Color thumbnailBgColor;

  const MaterialModel({
    required this.id,
    required this.subject,
    required this.title,
    required this.typeLabel,
    required this.typeIcon,
    this.subjectBadgeColor = const Color(0xFFEBF3FE),
    this.thumbnailBgColor = const Color(0xFFCCCCCC),
  });
}
