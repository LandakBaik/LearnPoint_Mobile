import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnpoint_mobile/features/siswa/profile/models/student_profile_model.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/widgets/dashboard_header_widget.dart';

class HeroBannerWidget extends StatelessWidget {
  final StudentProfileModel profile;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onContinueTap;
  final String? continueSubject;
  final String? continueTitle;
  final double continueProgress;

  const HeroBannerWidget({
    super.key,
    required this.profile,
    this.onNotificationTap,
    this.onProfileTap,
    this.onContinueTap,
    this.continueSubject,
    this.continueTitle,
    this.continueProgress = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dark space container with rounded bottom corners
        Container(
          height: 280,
          decoration: const BoxDecoration(
            color: Color(0xFF0B1030),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Pixel-art Space Animated GIF Background
                Image.asset(
                  'assets/images/hero-banner/space-hero.gif',
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) {
                    return CustomPaint(
                      painter: SpaceFallbackPainter(),
                    );
                  },
                ),
                // Gradient overlay to enhance text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.transparent,
                        const Color(0xFF0B1030).withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Header Content
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar: App Logo & Actions
                        DashboardHeaderWidget(
                          profile: profile,
                          onNotificationTap: onNotificationTap,
                          onProfileTap: onProfileTap,
                        ),

                        const SizedBox(height: 16),

                        // Greeting Title & Subtitle
                        Text(
                          'Halo, ${profile.name}!',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Siap jelajahi galaksi ilmu hari ini? ✦',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFE0E7FF),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Chips Row
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _buildHeroBadge('NIS ${profile.nisn ?? '01234'}'),
                            _buildHeroBadge(profile.gradeClass),
                            _buildHeroBadge('Sem. Ganjil'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Floating "Lanjutkan Belajar" Card overlapping at the bottom
        Positioned(
          left: 20,
          right: 20,
          bottom: -46,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E1B4B).withValues(alpha: 0.25),
                  offset: const Offset(0, 8),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'LANJUTKAN BELAJAR',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        continueTitle != null && continueTitle!.isNotEmpty
                            ? (continueSubject != null && continueSubject!.isNotEmpty
                                ? '$continueSubject · $continueTitle'
                                : continueTitle!)
                            : 'Mulai Pembelajaran Baru',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Container(
                          height: 6,
                          color: Colors.white.withValues(alpha: 0.3),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: continueProgress.clamp(0.1, 1.0),
                              child: Container(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: onContinueTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4F46E5),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    textStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Lanjut'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class SpaceFallbackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF06091F), Color(0xFF140F38), Color(0xFF221147)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);

    final starCoords = [
      Offset(size.width * 0.1, 40),
      Offset(size.width * 0.25, 70),
      Offset(size.width * 0.35, 30),
      Offset(size.width * 0.5, 90),
      Offset(size.width * 0.15, 120),
      Offset(size.width * 0.4, 160),
      Offset(size.width * 0.7, 180),
      Offset(size.width * 0.9, 50),
      Offset(size.width * 0.6, 60),
    ];

    for (final coord in starCoords) {
      canvas.drawRect(
        Rect.fromCenter(center: coord, width: 3, height: 3),
        starPaint,
      );
    }

    final planetCenter = Offset(size.width * 0.82, 90);
    final planetPaint = Paint()..color = const Color(0xFF9D67E0);
    canvas.drawCircle(planetCenter, 34, planetPaint);

    final ringPaint = Paint()
      ..color = const Color(0xFFF472B6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.save();
    canvas.translate(planetCenter.dx, planetCenter.dy);
    canvas.rotate(-0.35);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 95, height: 26),
      ringPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
