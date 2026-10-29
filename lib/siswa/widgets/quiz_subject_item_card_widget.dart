import 'package:flutter/material.dart';

import '../../models/materi_page.dart';

class QuizSubjectItemCardWidget extends StatefulWidget {
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
  State<QuizSubjectItemCardWidget> createState() =>
      _QuizSubjectItemCardWidgetState();
}

class _QuizSubjectItemCardWidgetState extends State<QuizSubjectItemCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 98),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.subject;

    // Widget Lingkaran Planet (Berputar Pelan) / Polos Warna dengan Hero ke halaman QuizPerMapel
    final circleWidget = Hero(
      tag: 'quiz_planet_${subject.materi}',
      child: subject.planetImageAsset != null
          ? SizedBox(
              width: 158,
              height: 158,
              child: RotationTransition(
                turns: _rotationController,
                child: Image.asset(
                  subject.planetImageAsset!,
                  fit: BoxFit.contain,
                ),
              ),
            )
          : Container(
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
            ),
    );

    final textWidget = Expanded(
      child: Column(
        crossAxisAlignment: widget.isCircleOnLeft
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
        horizontal: widget.horizontalMargin,
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
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: widget.isCircleOnLeft
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
