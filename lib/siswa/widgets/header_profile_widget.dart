import 'package:flutter/material.dart';
import '../../models/student_profile_model.dart';

class HeaderProfileWidget extends StatelessWidget {
  final StudentProfileModel profile;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const HeaderProfileWidget({
    super.key,
    required this.profile,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Bagian kiri: nama dan informasi kelas
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label kecil
              const Text(
                'LEARNPOINT SMPN 14 JEMBER',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 6),

              // Nama siswa
              Text(
                'Hi, ${profile.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 4),

              // Kelas dan tahun ajaran
              Text(
                '${profile.gradeClass}  •  Tahun Ajaran 2025–2026',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Bagian kanan
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Notifikasi
            GestureDetector(
              onTap: onNotificationTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF4338CA),
                      size: 21,
                    ),
                  ),

                  if (profile.hasNotification)
                    Positioned(
                      top: 4,
                      right: 5,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Avatar
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEDE9FE),
                ),
                child: ClipOval(
                  child: _buildAvatar(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    final avatar = profile.avatarUrl;
    if (avatar != null && avatar.isNotEmpty) {
      if (avatar.startsWith('assets/')) {
        return Image.asset(
          avatar,
          width: 38,
          height: 38,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitials(),
        );
      } else {
        return Image.network(
          avatar,
          width: 38,
          height: 38,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitials(),
        );
      }
    }
    return _buildInitials();
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        profile.initials,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4338CA),
        ),
      ),
    );
  }
}