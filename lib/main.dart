import 'package:flutter/material.dart';
import 'siswa/bottomNavSiswa.dart';

void main() {
  runApp(const LearnPointApp());
}

class LearnPointApp extends StatelessWidget {
  const LearnPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnPoint Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const BottomNavSiswa(),
    );
  }
}
