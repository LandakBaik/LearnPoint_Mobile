import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/profile/models/student_profile_model.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/widgets/dashboard_header_widget.dart';

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
    return DashboardHeaderWidget(
      profile: profile,
      onNotificationTap: onNotificationTap,
      onProfileTap: onProfileTap,
      isLight: true,
    );
  }
}
