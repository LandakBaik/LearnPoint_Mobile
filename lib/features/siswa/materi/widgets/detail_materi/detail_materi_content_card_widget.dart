import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/detail_materi/detail_materi_colors.dart';

class DetailMateriContentCardWidget extends StatelessWidget {
  final String? deskripsi;
  final bool hasDeskripsi;
  final String? publishedLabel;

  const DetailMateriContentCardWidget({
    super.key,
    required this.deskripsi,
    required this.hasDeskripsi,
    this.publishedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final contentText = hasDeskripsi && deskripsi != null
        ? deskripsi!
        : 'Guru belum menambahkan uraian deskripsi untuk materi ini. '
            'Silakan tonton video atau unduh modul lampiran di bawah (jika tersedia).';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DetailMateriColors.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DetailMateriColors.sectionTitle('DESKRIPSI MATERI'),
              if (publishedLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: DetailMateriColors.lightPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 11,
                        color: DetailMateriColors.primaryPurple,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        publishedLabel!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: DetailMateriColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Text(
            contentText,
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
