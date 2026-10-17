import 'package:flutter/material.dart';

import '../../models/materi_page.dart';
import 'inverted_top_curve_clipper.dart';
import 'quiz_subject_item_card_widget.dart';

class QuizSubjectListSectionWidget extends StatelessWidget {
  final List<MateriModel> subjects;
  final ValueChanged<MateriModel>? onSubjectTap;

  const QuizSubjectListSectionWidget({
    super.key,
    required this.subjects,
    this.onSubjectTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const InvertedTopCurveClipper(
        cornerRadius: 15,
        curveDepth: 20,
        centerX: 0.5,
        curveHalfWidth: 0.52,
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.fromLTRB(0, 45, 0, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardHorizontalMargin = constraints.maxWidth < 360
                ? 12.0
                : 20.0;

            return ListView.builder(
              itemCount: subjects.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final sub = subjects[index];
                final isCircleOnLeft = index % 2 == 0;

                return QuizSubjectItemCardWidget(
                  subject: sub,
                  isCircleOnLeft: isCircleOnLeft,
                  horizontalMargin: cardHorizontalMargin,
                  onTap: () => onSubjectTap?.call(sub),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
