import 'package:flutter/material.dart';

import '../widget/bottomNavBar.dart';
import 'index.dart';
import 'materi.dart';
import 'quiz.dart';

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
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    const SiswaDashboardScreen(),
    const Materi(),
    const Center(child: Text('Halaman Ujian')),
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
            label: 'Materi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline_rounded),
            label: 'Ujian',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Kuis',
          ),
        ],
      ),
    );
  }
}
