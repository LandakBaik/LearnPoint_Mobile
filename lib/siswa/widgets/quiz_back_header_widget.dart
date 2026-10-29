import 'package:flutter/material.dart';

class QuizBackHeaderWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onBackTap;

  const QuizBackHeaderWidget({
    super.key,
    required this.title,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      child: Row(
        children: [
          if (Navigator.of(context).canPop())
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: onBackTap ?? () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
