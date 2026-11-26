import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/leaderboard_entry_model.dart';

class LeaderboardSubjectFilterWidget extends StatelessWidget {
  final List<LeaderboardMapelOptionModel> mapels;
  final int? selectedMapelId;
  final ValueChanged<int?> onSelectMapel;

  const LeaderboardSubjectFilterWidget({
    super.key,
    required this.mapels,
    required this.selectedMapelId,
    required this.onSelectMapel,
  });

  @override
  Widget build(BuildContext context) {
    final totalItems = mapels.length + 1;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: totalItems,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final mapel = isAll ? null : mapels[index - 1];
          final isSelected = isAll
              ? selectedMapelId == null
              : selectedMapelId == mapel!.id;
          final label = isAll ? 'Semua Mapel' : mapel!.namaMapel;

          return GestureDetector(
            onTap: () => onSelectMapel(isAll ? null : mapel!.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                      )
                    : null,
                color: isSelected
                    ? null
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF38BDF8)
                      : Colors.white.withValues(alpha: 0.14),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isAll ? Icons.layers_rounded : Icons.menu_book_rounded,
                    size: 13,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
