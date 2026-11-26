import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MapelHeaderWidget extends StatelessWidget {
  final String subjectName;
  final String description;
  final String? kelasLabel;
  final double? rataRataNilaiTugas;
  final int jumlahTugasDinilai;
  final bool isLoading;

  const MapelHeaderWidget({
    super.key,
    this.subjectName = 'Matematika',
    this.description = '',
    this.kelasLabel,
    this.rataRataNilaiTugas,
    this.jumlahTugasDinilai = 0,
    this.isLoading = false,
  });

  List<Color> _resolveGradient(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('matematika')) {
      return const [Color(0xFF4F8FF7), Color(0xFF8EC5FC)];
    } else if (lower.contains('ipa') || lower.contains('biologi')) {
      return const [Color(0xFF5AD49A), Color(0xFFA7F3D0)];
    } else if (lower.contains('fisika')) {
      return const [Color(0xFF6366F1), Color(0xFFA5B4FC)];
    } else if (lower.contains('kimia')) {
      return const [Color(0xFF9333EA), Color(0xFFD8B4FE)];
    } else if (lower.contains('indonesia') ||
        lower.contains('inggris') ||
        lower.contains('bahasa')) {
      return const [Color(0xFFF43F5E), Color(0xFFFDA4AF)];
    } else if (lower.contains('ips') ||
        lower.contains('sejarah') ||
        lower.contains('ekonomi') ||
        lower.contains('geografi')) {
      return const [Color(0xFFF59E0B), Color(0xFFFDE68A)];
    }
    return const [Color(0xFF4F8FF7), Color(0xFF8EC5FC)];
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _resolveGradient(subjectName);
    final isMath = subjectName.toLowerCase().contains('matematika');
    final isScience = subjectName.toLowerCase().contains('ipa') ||
        subjectName.toLowerCase().contains('biologi');
    final hasScore = rataRataNilaiTugas != null;
    final score = rataRataNilaiTugas ?? 0;
    final scoreColor = !hasScore
        ? Colors.white.withValues(alpha: 0.55)
        : score >= 85
            ? const Color(0xFF6EE7B7)
            : score >= 70
                ? Colors.white
                : const Color(0xFFFDE68A);
    final scoreLabel = !hasScore
        ? 'Belum dinilai'
        : score >= 85
            ? 'Sangat Baik'
            : score >= 70
                ? 'Baik'
                : 'Perlu ditingkatkan';

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 176),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Subtle watermark symbols
          if (isMath) ...[
            Positioned(
              right: 26,
              top: 12,
              child: Text(
                'x²',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.16),
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Positioned(
              right: 22,
              bottom: 6,
              child: Text(
                'π',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.16),
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else if (isScience) ...[
            Positioned(
              right: 20,
              top: 14,
              child: Icon(
                Icons.hub_outlined,
                color: Colors.white.withValues(alpha: 0.16),
                size: 80,
              ),
            ),
          ] else ...[
            Positioned(
              right: 20,
              top: 16,
              child: Icon(
                Icons.auto_stories_outlined,
                color: Colors.white.withValues(alpha: 0.16),
                size: 74,
              ),
            ),
          ],

          // Card Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (kelasLabel != null &&
                          kelasLabel!.trim().isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            kelasLabel!,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ] else if (isLoading) ...[
                        Container(
                          width: 82,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        'MATA PELAJARAN',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subjectName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          height: 1.15,
                        ),
                      ),
                      if (description.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  width: 108,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'RATA-RATA',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 52,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                          border: Border.all(color: scoreColor, width: 3),
                        ),
                        child: Text(
                          hasScore
                              ? (score % 1 == 0
                                  ? score.toStringAsFixed(0)
                                  : score.toStringAsFixed(1))
                              : '-',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scoreLabel,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (hasScore) ...[
                        const SizedBox(height: 2),
                        Text(
                          '$jumlahTugasDinilai tugas',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
