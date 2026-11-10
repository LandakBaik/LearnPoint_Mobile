import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/student_profile_model.dart';
import '../akun.dart';
import '../notifikasi.dart';

class DashboardHeaderWidget extends StatelessWidget {
  final StudentProfileModel profile;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final bool isLight;

  const DashboardHeaderWidget({
    super.key,
    required this.profile,
    this.onNotificationTap,
    this.onProfileTap,
    this.isLight = false,
  });

  void _handleNotificationTap(BuildContext context) {
    if (onNotificationTap != null) {
      onNotificationTap!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const NotificationScreen(),
      ),
    );
  }

  void _handleProfileTap(BuildContext context) {
    if (onProfileTap != null) {
      onProfileTap!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AkunScreen(profile: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String initialChar =
        profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'R';

    final Color textColor = isLight ? const Color(0xFF1E1B4B) : Colors.white;
    final Color boxBg = isLight
        ? const Color(0xFF4F46E5).withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.16);
    final Color boxBorder = isLight
        ? const Color(0xFF4F46E5).withValues(alpha: 0.25)
        : Colors.white.withValues(alpha: 0.3);
    final Color iconColor = isLight ? const Color(0xFF4F46E5) : Colors.white;
    final Color smpBg = isLight
        ? const Color(0xFFE0E7FF)
        : Colors.white.withValues(alpha: 0.2);
    final Color smpText = isLight ? const Color(0xFF3730A3) : Colors.white;
    final Color notifBg = isLight
        ? const Color(0xFFF3F4F6)
        : Colors.white.withValues(alpha: 0.14);
    final Color notifBorder = isLight
        ? const Color(0xFFE5E7EB)
        : Colors.white.withValues(alpha: 0.3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: App Logo & Title + SMP Badge
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: boxBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: boxBorder,
                  ),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'LearnPoint',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: smpBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'SMP',
                  style: GoogleFonts.plusJakartaSans(
                    color: smpText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Right: Notification Circle & Yellow 'R' Profile Circle
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => _handleNotificationTap(context),
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: notifBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: notifBorder,
                  ),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: textColor,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _handleProfileTap(context),
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDE68A),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initialChar,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF78350F),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
