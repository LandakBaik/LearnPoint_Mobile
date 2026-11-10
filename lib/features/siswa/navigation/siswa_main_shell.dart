import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/core/widgets/bottom_nav_bar.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/screens/siswa_dashboard_screen.dart';
import 'package:learnpoint_mobile/features/siswa/materi/screens/materi_screen.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/screens/quiz_screen.dart';

class BottomNavSiswa extends StatefulWidget {
  final int initialIndex;
  const BottomNavSiswa({super.key, this.initialIndex = 0});

  @override
  State<BottomNavSiswa> createState() => _BottomNavSiswaState();
}

class _BottomNavSiswaState extends State<BottomNavSiswa> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 2);
  }

  final List<Widget> _pages = [
    const SiswaDashboardScreen(),
    const Materi(),
    const Quiz(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Mapel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Quiz',
          ),
        ],
      ),
    );
  }
}
