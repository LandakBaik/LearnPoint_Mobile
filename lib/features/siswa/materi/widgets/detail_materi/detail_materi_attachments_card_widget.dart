import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/detail_materi/detail_materi_colors.dart';

class DetailMateriAttachmentsCardWidget extends StatelessWidget {
  final String materiTitle;
  final List<Map<String, String>> attachments;
  final bool hasVideo;
  final String? youtubeUrl;
  final void Function(String fileName, String url)? onOpenAttachment;
  final void Function(String label, String url, {bool isVideo}) onOpenUrl;

  const DetailMateriAttachmentsCardWidget({
    super.key,
    required this.materiTitle,
    required this.attachments,
    required this.hasVideo,
    required this.youtubeUrl,
    this.onOpenAttachment,
    required this.onOpenUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DetailMateriColors.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailMateriColors.sectionTitle('MODUL & BERKAS UNDUHAN'),
          const SizedBox(height: 12),
          if (attachments.isEmpty)
            const Text(
              'Tidak ada berkas lampiran untuk materi ini.',
              style: TextStyle(
                fontSize: 12,
                color: DetailMateriColors.textMuted,
              ),
            ),
          ...attachments.map(
            (file) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        if (onOpenAttachment != null) {
                          onOpenAttachment!(file['filename']!, file['url']!);
                        } else {
                          onOpenUrl(
                            'berkas ${file['filename']}',
                            file['url']!,
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE4E6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.picture_as_pdf_outlined,
                              color: Color(0xFFE11D48),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  file['title']!,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: DetailMateriColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${file['filename']} • ${file['size']}',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: DetailMateriColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (onOpenAttachment != null) {
                                onOpenAttachment!(
                                  file['filename']!,
                                  file['url']!,
                                );
                              } else {
                                onOpenUrl(
                                  'berkas ${file['filename']}',
                                  file['url']!,
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.visibility_outlined,
                              color: DetailMateriColors.primaryPurple,
                            ),
                            tooltip: 'Lihat berkas',
                          ),
                        ],
                      ),
                    ),
                    if (hasVideo && youtubeUrl != null) ...[
                      const SizedBox(height: 18),
                      InkWell(
                        onTap: () => onOpenUrl(
                          'video YouTube',
                          youtubeUrl!,
                          isVideo: true,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: DetailMateriColors.primaryPurple.withValues(
                              alpha: 0.14,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: DetailMateriColors.primaryPurple
                                  .withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: DetailMateriColors.primaryPurple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tonton Video Penjelasan',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: DetailMateriColors.primaryPurple,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Visualisasi konsep $materiTitle',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: DetailMateriColors.primaryPurple,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.open_in_new_rounded,
                                color: DetailMateriColors.primaryPurple
                                    .withValues(alpha: 0.7),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
