import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/models/item_model.dart';
import 'package:learnpoint_mobile/features/siswa/profile/models/student_profile_model.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/widgets/dashboard_header_widget.dart';

class HeroBannerWidget extends StatelessWidget {
  final StudentProfileModel profile;
  final BannerItemModel? activeBanner;
  final bool isBannerLoading;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onBannerTap;
  final VoidCallback? onContinueTap;
  final String? continueSubject;
  final String? continueTitle;
  final double continueProgress;

  const HeroBannerWidget({
    super.key,
    required this.profile,
    this.activeBanner,
    this.isBannerLoading = false,
    this.onNotificationTap,
    this.onProfileTap,
    this.onBannerTap,
    this.onContinueTap,
    this.continueSubject,
    this.continueTitle,
    this.continueProgress = 0.5,
  });

  Widget _buildBannerBackground() {
    if (activeBanner != null) {
      final defaultAssetFallback = Image.asset(
        'assets/images/hero-banner/space-hero.gif',
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => CustomPaint(
          painter: SpaceFallbackPainter(),
        ),
      );

      return BannerMediaView(
        key: ValueKey('banner_${activeBanner!.kode}'),
        banner: activeBanner!,
        defaultWidget: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF1D4ED8),
                Color(0xFF2563EB),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        fallbackWidget: defaultAssetFallback,
      );
    }

    if (isBannerLoading) {
      return const _BannerShimmerBackground(
        key: ValueKey('banner_shimmer'),
      );
    }

    // Fallback jika gagal memuat / offline setelah proses fetch selesai
    return Image.asset(
      'assets/images/hero-banner/space-hero.gif',
      key: const ValueKey('banner_fallback'),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => CustomPaint(
        painter: SpaceFallbackPainter(),
      ),
    );
  }

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
                // Background sesuai active_banner dari API (Shimmer saat loading, GIF/Gradient saat siap)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                  child: _buildBannerBackground(),
                ),
                // Gradient overlay to enhance text readability on bright banners
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.44),
                        Colors.black.withValues(alpha: 0.28),
                        const Color(0xFF0B1030).withValues(alpha: 0.78),
                      ],
                      stops: const [0.0, 0.45, 1.0],
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
                          profile.name.isNotEmpty
                              ? 'Halo, ${profile.name}!'
                              : 'Halo!',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            shadows: const [
                              Shadow(
                                color: Color(0x99000000),
                                offset: Offset(0, 2),
                                blurRadius: 8,
                              ),
                              Shadow(
                                color: Color(0x55000000),
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Siap jelajahi galaksi ilmu hari ini? ✦',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFDBEAFE),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            shadows: const [
                              Shadow(
                                color: Color(0x88000000),
                                offset: Offset(0, 1),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Chips Row
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _buildHeroBadge(
                              profile.isGuru
                                  ? 'NUPTK ${profile.nisn ?? '-'}'
                                  : 'NIS ${profile.nisn ?? '-'}',
                            ),
                            _buildHeroBadge(profile.gradeClass),
                            _buildHeroBadge(
                              profile.semester != null &&
                                      profile.semester!.isNotEmpty
                                  ? 'Sem. ${profile.semester}'
                                  : (profile.academicYear ??
                                      (profile.isActive ? 'Aktif' : 'Nonaktif')),
                            ),
                            // if (onBannerTap != null)
                            //   GestureDetector(
                            //     onTap: onBannerTap,
                            //     child: Container(
                            //       padding: const EdgeInsets.symmetric(
                            //         horizontal: 10,
                            //         vertical: 5,
                            //       ),
                            //       decoration: BoxDecoration(
                            //         color: Colors.white.withValues(alpha: 0.22),
                            //         borderRadius: BorderRadius.circular(20),
                            //         border: Border.all(
                            //           color: Colors.white.withValues(alpha: 0.45),
                            //         ),
                            //       ),
                            //       child: Row(
                            //         mainAxisSize: MainAxisSize.min,
                            //         children: [
                            //           const Icon(
                            //             Icons.wallpaper_rounded,
                            //             color: Colors.white,
                            //             size: 13,
                            //           ),
                            //           const SizedBox(width: 4),
                            //           Text(
                            //             'Ganti Banner',
                            //             style: GoogleFonts.plusJakartaSans(
                            //               color: Colors.white,
                            //               fontSize: 11.5,
                            //               fontWeight: FontWeight.w700,
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
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
              gradient: const LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D4ED8).withValues(alpha: 0.28),
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
                    foregroundColor: const Color(0xFF2563EB),
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
        color: const Color(0xFF0B1030).withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          shadows: const [
            Shadow(
              color: Color(0x77000000),
              offset: Offset(0, 1),
              blurRadius: 4,
            ),
          ],
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

class _BannerShimmerBackground extends StatefulWidget {
  const _BannerShimmerBackground({super.key});

  @override
  State<_BannerShimmerBackground> createState() =>
      _BannerShimmerBackgroundState();
}

class _BannerShimmerBackgroundState extends State<_BannerShimmerBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final slide = -1.5 + (3.0 * _controller.value);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(slide - 1.0, -0.35),
              end: Alignment(slide + 1.0, 0.35),
              colors: const [
                Color(0xFF0B1030),
                Color(0xFF172154),
                Color(0xFF283980),
                Color(0xFF172154),
                Color(0xFF0B1030),
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
            ),
          ),
        );
      },
    );
  }
}
