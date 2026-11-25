import 'package:flutter/material.dart';

class DetailMateriColors {
  const DetailMateriColors._();

  static const Color primaryPurple = Color(0xFF6336ED);
  static const Color lightPurple = Color(0xFFF1EEFF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color successGreen = Color(0xFF10B981);

  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  static Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: Color(0xFF94A3B8),
      ),
    );
  }
}
