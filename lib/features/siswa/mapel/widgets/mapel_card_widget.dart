import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';

class MapelCardWidget extends StatelessWidget {
  final MateriModel subject;
  final String? imageUrl;
  final double elevation;
  final double horizontalMargin;
  final int completedCount;
  final VoidCallback? ontap;

  const MapelCardWidget({
    super.key,
    required this.subject,
    this.imageUrl,
    this.elevation = 0,
    this.horizontalMargin = 20,
    this.completedCount = 0,
    this.ontap,
  });

  ({
    List<Color> gradientColors,
    Color accentColor,
    Color iconBgColor,
    Color iconColor,
    _SubjectBannerType bannerType,
  }) _resolveVisualTheme(String subjectName) {
    final lower = subjectName.toLowerCase();
    if (lower.contains('matematika')) {
      return (
        gradientColors: const [Color(0xFF4F8FF7), Color(0xFF8EC5FC)],
        accentColor: const Color(0xFF5B9BF3),
        iconBgColor: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF3B82F6),
        bannerType: _SubjectBannerType.math,
      );
    } else if (lower.contains('ipa') || lower.contains('biologi')) {
      return (
        gradientColors: const [Color(0xFF5AD49A), Color(0xFFA7F3D0)],
        accentColor: const Color(0xFF34C782),
        iconBgColor: const Color(0xFFECFDF5),
        iconColor: const Color(0xFF10B981),
        bannerType: _SubjectBannerType.science,
      );
    } else if (lower.contains('fisika')) {
      return (
        gradientColors: const [Color(0xFF6366F1), Color(0xFFA5B4FC)],
        accentColor: const Color(0xFF6366F1),
        iconBgColor: const Color(0xFFEEF2FF),
        iconColor: const Color(0xFF4F46E5),
        bannerType: _SubjectBannerType.physics,
      );
    } else if (lower.contains('kimia')) {
      return (
        gradientColors: const [Color(0xFF9333EA), Color(0xFFD8B4FE)],
        accentColor: const Color(0xFF9333EA),
        iconBgColor: const Color(0xFFFAF5FF),
        iconColor: const Color(0xFF9333EA),
        bannerType: _SubjectBannerType.chemistry,
      );
    } else if (lower.contains('indonesia') ||
        lower.contains('inggris') ||
        lower.contains('bahasa')) {
      return (
        gradientColors: const [Color(0xFFF43F5E), Color(0xFFFDA4AF)],
        accentColor: const Color(0xFFF43F5E),
        iconBgColor: const Color(0xFFFFF1F2),
        iconColor: const Color(0xFFE11D48),
        bannerType: _SubjectBannerType.language,
      );
    } else if (lower.contains('ips') ||
        lower.contains('sejarah') ||
        lower.contains('ekonomi') ||
        lower.contains('geografi')) {
      return (
        gradientColors: const [Color(0xFFF59E0B), Color(0xFFFDE68A)],
        accentColor: const Color(0xFFF59E0B),
        iconBgColor: const Color(0xFFFFFBEB),
        iconColor: const Color(0xFFD97706),
        bannerType: _SubjectBannerType.social,
      );
    }

    return (
      gradientColors: const [Color(0xFF6366F1), Color(0xFF93C5FD)],
      accentColor: const Color(0xFF6366F1),
      iconBgColor: subject.color,
      iconColor: subject.iconColor,
      bannerType: _SubjectBannerType.general,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final textScale = (screenWidth / 400).clamp(0.9, 1.1).toDouble();
    final theme = _resolveVisualTheme(subject.materi);

    final totalMateri = subject.totalMateri;
    final safeCompleted =
        completedCount.clamp(0, totalMateri > 0 ? totalMateri : 0);
    final double progress =
        totalMateri > 0 ? (safeCompleted / totalMateri) : 0.0;

    final String guruText = subject.guru.isNotEmpty
        ? 'Guru: ${subject.guru.join(', ')}'
        : '$totalMateri Materi Pembelajaran';

    final String progressLabel = safeCompleted > 0 && totalMateri > 0
        ? '$safeCompleted dari $totalMateri materi'
        : 'Belum dimulai';

    return Container(
      margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: ontap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Gradient Banner with Decorative Symbols & Materi Count Pill
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(19),
                ),
                child: Container(
                  height: 106,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: theme.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      _BannerWatermark(type: theme.bannerType),
                      Positioned(
                        left: 14,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$totalMateri materi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5 * textScale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Middle Row: Subject Icon, Name & Teacher, Chevron Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        subject.icon,
                        color: theme.iconColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.materi,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.5 * textScale,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            guruText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5 * textScale,
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
              ),

              // Bottom Progress Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progres belajar',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12 * textScale,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          progressLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12 * textScale,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SubjectBannerType {
  math,
  science,
  physics,
  chemistry,
  language,
  social,
  general,
}

class _BannerWatermark extends StatelessWidget {
  final _SubjectBannerType type;

  const _BannerWatermark({required this.type});

  @override
  Widget build(BuildContext context) {
    final whiteSoft = Colors.white.withValues(alpha: 0.22);
    final whiteSofter = Colors.white.withValues(alpha: 0.14);

    switch (type) {
      case _SubjectBannerType.math:
        return Stack(
          children: [
            Positioned(
              left: 28,
              top: 14,
              child: Text(
                '+',
                style: TextStyle(
                  color: whiteSoft,
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Positioned(
              left: 92,
              top: 16,
              child: Text(
                '=',
                style: TextStyle(
                  color: whiteSoft,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Positioned(
              right: 84,
              top: 10,
              child: Text(
                'x²',
                style: TextStyle(
                  color: whiteSoft,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Positioned(
              right: 92,
              bottom: 12,
              child: Text(
                'Σ',
                style: TextStyle(
                  color: whiteSoft,
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: 10,
              child: Text(
                'π',
                style: TextStyle(
                  color: whiteSoft,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      case _SubjectBannerType.science:
        return Stack(
          children: [
            Positioned(
              left: 60,
              top: 14,
              child: Icon(
                Icons.eco_rounded,
                color: whiteSofter,
                size: 56,
              ),
            ),
            Positioned(
              right: 22,
              top: 8,
              child: Icon(
                Icons.hub_outlined,
                color: whiteSoft,
                size: 86,
              ),
            ),
          ],
        );
      case _SubjectBannerType.physics:
        return Stack(
          children: [
            Positioned(
              left: 48,
              top: 18,
              child: Icon(
                Icons.bolt_rounded,
                color: whiteSofter,
                size: 46,
              ),
            ),
            Positioned(
              right: 24,
              top: 10,
              child: Icon(
                Icons.settings_input_antenna_rounded,
                color: whiteSoft,
                size: 76,
              ),
            ),
          ],
        );
      case _SubjectBannerType.chemistry:
        return Stack(
          children: [
            Positioned(
              left: 52,
              top: 18,
              child: Icon(
                Icons.bubble_chart_outlined,
                color: whiteSofter,
                size: 46,
              ),
            ),
            Positioned(
              right: 26,
              top: 12,
              child: Icon(
                Icons.science_outlined,
                color: whiteSoft,
                size: 76,
              ),
            ),
          ],
        );
      case _SubjectBannerType.language:
        return Stack(
          children: [
            Positioned(
              left: 50,
              top: 16,
              child: Text(
                'Aa',
                style: TextStyle(
                  color: whiteSofter,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Positioned(
              right: 26,
              top: 12,
              child: Icon(
                Icons.menu_book_rounded,
                color: whiteSoft,
                size: 72,
              ),
            ),
          ],
        );
      case _SubjectBannerType.social:
        return Stack(
          children: [
            Positioned(
              left: 54,
              top: 18,
              child: Icon(
                Icons.public_rounded,
                color: whiteSofter,
                size: 48,
              ),
            ),
            Positioned(
              right: 24,
              top: 10,
              child: Icon(
                Icons.explore_outlined,
                color: whiteSoft,
                size: 76,
              ),
            ),
          ],
        );
      case _SubjectBannerType.general:
        return Stack(
          children: [
            Positioned(
              left: 54,
              top: 18,
              child: Icon(
                Icons.auto_stories_outlined,
                color: whiteSofter,
                size: 48,
              ),
            ),
            Positioned(
              right: 24,
              top: 10,
              child: Icon(
                Icons.school_outlined,
                color: whiteSoft,
                size: 76,
              ),
            ),
          ],
        );
    }
  }
}
