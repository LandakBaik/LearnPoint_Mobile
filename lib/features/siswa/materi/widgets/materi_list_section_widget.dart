import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnpoint_mobile/features/siswa/mapel/widgets/mapel_skeleton_widget.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_preferences_service.dart';
import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/features/siswa/materi/screens/detail_materi_screen.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/materi_error_state_widget.dart';

class MateriListSectionWidget extends StatelessWidget {
  final String subjectName;
  final List<MateriItemModel> materiList;
  final Set<String> completedKeys;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onMateriOpened;

  const MateriListSectionWidget({
    super.key,
    required this.subjectName,
    required this.materiList,
    required this.completedKeys,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onMateriOpened,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const DetailMapelListSkeletonWidget();
    }

    if (errorMessage != null) {
      return Center(
        child: MateriErrorStateWidget(
          message: errorMessage!,
          onRetry: onRetry,
        ),
      );
    }

    if (materiList.isEmpty) {
      return Center(
        child: MateriErrorStateWidget.empty(
          message: 'Guru belum mengunggah materi untuk mata pelajaran ini.',
          onRetry: onRetry,
        ),
      );
    }

    return Column(
      children: List.generate(materiList.length, (index) {
        final MateriItemModel apiItem = materiList[index];
        final String title = apiItem.judul;

        final itemKey = MateriPreferencesService.getMateriKey(
          subjectName,
          title,
          id: apiItem.id,
        );
        final oldItemKey = MateriPreferencesService.getMateriKey(
          subjectName,
          title,
        );
        final isCompleted =
            completedKeys.contains(itemKey) ||
            completedKeys.contains(oldItemKey);

        final subtitleParts = <String>['Bab ${index + 1}'];
        if (apiItem.hasVideo) subtitleParts.add('Video');
        if (apiItem.hasFile) subtitleParts.add('Lampiran');
        final subtitleText = subtitleParts.join(' • ');

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailMateriPage(
                      title: title,
                      subject: subjectName,
                      materiItem: apiItem,
                    ),
                  ),
                );
                onMateriOpened();
              },
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Color(0xFF2563EB),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                subtitleText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF475569),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progres belajar',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Selesai',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0284C7),
                              ),
                            ),
                          )
                        else
                          Text(
                            'Belum dimulai',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: isCompleted ? 1.0 : 0.0,
                        minHeight: 5,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF5B9BF3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
