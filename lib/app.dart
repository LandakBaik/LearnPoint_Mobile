import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learnpoint_mobile/core/theme/app_theme.dart';
import 'package:learnpoint_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/providers/notification_provider.dart';
import 'package:learnpoint_mobile/features/siswa/profile/providers/profile_provider.dart';

class LearnPointApp extends StatelessWidget {
  const LearnPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: 'LearnPoint SMP',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Login(),
      ),
    );
  }
}

