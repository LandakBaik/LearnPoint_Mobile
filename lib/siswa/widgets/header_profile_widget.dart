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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Greeting & Class Info
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${profile.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 200, 219, 248),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${profile.gradeClass}  •  ${profile.schoolName}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 49, 2, 70),
              ),
            ),
          ],
        ),

        // Notification Icon & Profile Initials Badge
        Row(
          children: [
            // Bell Notification Button with Red Badge
            GestureDetector(
              onTap: onNotificationTap,
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF334155),
                      size: 26,
                    ),
                  ),
                  if (profile.hasNotification)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Profile Avatar Badge with Initials
            GestureDetector(
              onTap: onProfileTap,
              child: CircleAvatar(
                radius: 19,
                backgroundColor: const Color(0xFFDBEAFE),
                child: Text(
                  profile.initials,
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
