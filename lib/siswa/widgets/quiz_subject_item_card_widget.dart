import 'package:flutter/material.dart';

import '../../models/materi_page.dart';

class QuizSubjectItemCardWidget extends StatelessWidget {
  final MateriModel subject;
  final bool isCircleOnLeft;
  final double horizontalMargin;
  final VoidCallback? onTap;

  const QuizSubjectItemCardWidget({
    super.key,
    required this.subject,
    required this.isCircleOnLeft,
    this.horizontalMargin = 20.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Widget Lingkaran Polos Warna
    final circleWidget = Container(
      width: 158,
      height: 158,
      decoration: BoxDecoration(
        color: subject.iconColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: subject.iconColor.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    final textWidget = Expanded(
      child: Column(
        crossAxisAlignment: isCircleOnLeft
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            subject.materi,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subject.description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalMargin,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: isCircleOnLeft
              ? [
                  circleWidget,
                  const SizedBox(width: 16),
                  textWidget,
                ]
              : [
                  textWidget,
                  const SizedBox(width: 16),
                  circleWidget,
                ],
        ),
      ),
    );
  }
}
