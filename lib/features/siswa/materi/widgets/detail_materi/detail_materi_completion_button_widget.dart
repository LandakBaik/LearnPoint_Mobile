import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/detail_materi/detail_materi_colors.dart';

class DetailMateriCompletionButtonWidget extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onPressed;

  const DetailMateriCompletionButtonWidget({
    super.key,
    required this.isCompleted,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          isCompleted ? Icons.check_circle_rounded : Icons.task_alt_rounded,
          size: 19,
        ),
        label: Text(
          isCompleted
              ? 'Materi Selesai Dipelajari'
              : 'Tandai Selesai Dipelajari',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted
              ? DetailMateriColors.successGreen
              : DetailMateriColors.primaryPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
