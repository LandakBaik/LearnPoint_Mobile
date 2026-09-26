import 'package:flutter/material.dart';

import '../widget/bottomNavBar.dart';
import 'index.dart';
import 'materi.dart';

class BottomNavSiswa extends StatefulWidget {
  const BottomNavSiswa({super.key});

  @override
  State<BottomNavSiswa> createState() => _BottomNavSiswaState();
}

class _BottomNavSiswaState extends State<BottomNavSiswa> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const SiswaDashboardScreen(),
    const Materi(),
    const Center(child: Text('Halaman Tugas')),
    const Center(child: Text('Halaman Ujian')),
    const Center(child: Text('Halaman Kuis')),
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
            icon: Icon(Icons.assignment_outlined),
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline_rounded),
            label: 'Ujian',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Kuis',
          ),
        ],
      ),
    );
  }
}
