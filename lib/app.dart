import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/core/theme/app_theme.dart';
import 'package:learnpoint_mobile/features/auth/presentation/screens/login_screen.dart';

class LearnPointApp extends StatelessWidget {
  const LearnPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnPoint SMP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const Login(),
    );
  }
}

