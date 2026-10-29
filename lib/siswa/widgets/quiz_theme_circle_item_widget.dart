import 'package:flutter/material.dart';
import '../../models/quiz_per_mapel.dart';

class QuizThemeCircleItemWidget extends StatelessWidget {
  final QuizPerMapelM item;
  final bool isCircleOnLeft;
  final double horizontalMargin;
  final VoidCallback? onTap;

  const QuizThemeCircleItemWidget({
    super.key,
    required this.item,
    required this.isCircleOnLeft,
    this.horizontalMargin = 24.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final circleWidget = Container(
      width: 158,
      height: 158,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 10),
      child: Align(
        alignment: isCircleOnLeft
            ? Alignment.centerLeft
            : Alignment.centerRight,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: circleWidget,
        ),
      ),
    );
  }
}
