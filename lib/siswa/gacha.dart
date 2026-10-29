import 'dart:math';
import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/student_profile_model.dart';
import '../widget/bottomNavBar.dart';
import 'bottomNavSiswa.dart';
import 'changepass.dart';
import 'notifikasi.dart';
import 'widgets/dashboard_header_widget.dart';

class GachaBannerModel {
  final String id;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final IconData themeIcon;
  final int costSingle;
  final int costTen;
  final List<ItemModel> availableItems;

  const GachaBannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.themeIcon,
    this.costSingle = 100,
    this.costTen = 900,
    required this.availableItems,
  });
}

class GachaHistoryEntry {
  final ItemModel item;
  final String time;

  const GachaHistoryEntry({
    required this.item,
    required this.time,
  });
}

class Gacha extends StatefulWidget {
  final VoidCallback? onBackTap;
  const Gacha({super.key, this.onBackTap});

  @override
  State<Gacha> createState() => _GachaState();
}

class _GachaState extends State<Gacha> {
  int money = 1999;
  final Random _random = Random();

  static const studentProfile = StudentProfileModel(
    name: 'Abimanyu',
    gradeClass: 'Kelas VIII-A',
    schoolName: 'SMP Merdeka',
    initials: 'AP',
    hasNotification: true,
  );

  late final List<GachaBannerModel> banners = [
    GachaBannerModel(
      id: 'banner_cosmic',
      title: 'Banner Kosmik Bintang',
      subtitle: 'Koleksi item pelindung dan pengganda poin bertema luar angkasa!',
      gradientColors: const [Color(0xFF312E81), Color(0xFF6366F1)],
      themeIcon: Icons.auto_awesome_rounded,
      costSingle: 100,
      costTen: 900,
      availableItems: item,
    ),
    GachaBannerModel(
      id: 'banner_time',
      title: 'Banner Penjelajah Waktu',
      subtitle: 'Dapatkan Ramuan Waktu & Buku Petunjuk dengan peluang lebih tinggi!',
      gradientColors: const [Color(0xFF0F766E), Color(0xFF14B8A6)],
      themeIcon: Icons.hourglass_full_rounded,
      costSingle: 120,
      costTen: 1000,
      availableItems: item,
    ),
    GachaBannerModel(
      id: 'banner_hero',
      title: 'Banner Ksatria Cahaya',
      subtitle: 'Pedang Cahaya & Perisai Bintang legendaris siap membantu kuismu!',
      gradientColors: const [Color(0xFFB45309), Color(0xFFF59E0B)],
      themeIcon: Icons.bolt_rounded,
      costSingle: 150,
      costTen: 1350,
      availableItems: item,
    ),
  ];

  // Menyimpan riwayat gacha per banner id
  final Map<String, List<GachaHistoryEntry>> _historyByBanner = {};

  void _performGacha(GachaBannerModel banner, int count) {
    final int cost = count == 1 ? banner.costSingle : banner.costTen;

    if (money < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Koin tidak cukup untuk melakukan Gacha!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final List<ItemModel> pulledItems = List.generate(
      count,
      (_) => banner.availableItems[_random.nextInt(banner.availableItems.length)],
    );

    final now = TimeOfDay.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      money -= cost;
      final list = _historyByBanner.putIfAbsent(banner.id, () => []);
      for (final pulled in pulledItems) {
        list.insert(0, GachaHistoryEntry(item: pulled, time: timeStr));
      }
    });

    _showGachaResultDialog(banner, pulledItems);
  }

  void _showGachaResultDialog(GachaBannerModel banner, List<ItemModel> results) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1B4B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
          title: Text(
            'Hasil Gacha (${results.length}x)',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: results.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: results.length == 1 ? 1 : 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: results.length == 1 ? 1.8 : 0.9,
              ),
              itemBuilder: (context, index) {
                final alat = results[index];
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        alat.icon,
                        color: alat.color,
                        size: results.length == 1 ? 48 : 30,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        alat.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: results.length == 1 ? 14 : 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAvailableItemsDialog(GachaBannerModel banner) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1B4B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
          title: Text(
            'Item Tersedia - ${banner.title}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: banner.availableItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final alat = banner.availableItems[index];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(alat.icon, color: alat.color, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alat.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              alat.desc,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHistoryDialog(GachaBannerModel banner) {
    final history = _historyByBanner[banner.id] ?? [];

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1B4B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
          title: Text(
            'Riwayat Gacha - ${banner.title}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 260,
            child: history.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada riwayat gacha di banner ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = history[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              entry.item.icon,
                              color: entry.item.color,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                entry.item.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              entry.time,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4338CA),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Profil (DashboardHeaderWidget)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: DashboardHeaderWidget(
                profile: studentProfile,
                onNotificationTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                },
                onProfileTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const Changepass(),
                    ),
                  );
                },
              ),
            ),

            // 2. Main Content
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 108, 175, 230),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Layout Paling Atas: Tombol Back & Uang/Koin (seperti di Inventori)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap:
                              widget.onBackTap ??
                              () {
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                }
                              },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                            border: Border.all(
                              color: Colors.white,
                              width: 2.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.monetization_on,
                                color: Colors.yellow,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$money',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Daftar Pilihan Banner Gacha
                    Expanded(
                      child: ListView.separated(
                        itemCount: banners.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final banner = banners[index];
                          return _buildBannerCard(banner);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 3. Layout Paling Bawah: Navbar
      bottomNavigationBar: BottomNav(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(
                builder: (_) => BottomNavSiswa(initialIndex: index),
              ),
              (route) => false,
            );
          }
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

  Widget _buildBannerCard(GachaBannerModel banner) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: banner.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17.5),
        child: Stack(
          children: [
            // Background Tema Item Gacha (Dekorasi Ikon & Visual)
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                banner.themeIcon,
                size: 160,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            Positioned(
              left: 40,
              bottom: -15,
              child: Row(
                children: banner.availableItems.map((alat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      alat.icon,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Informasi Judul & Subjudul Banner + Preview Item
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 16, 16, 70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'EVENT BANNER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    banner.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    banner.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Pojok Kiri Banner: 2 IconButton (Info Item & Info Riwayat Gacha)
            Positioned(
              left: 10,
              bottom: 10,
              child: Row(
                children: [
                  // IconButton Info Item yang tersedia
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white70, width: 1.5),
                    ),
                    child: IconButton(
                      constraints: const BoxConstraints(
                        minWidth: 38,
                        minHeight: 38,
                      ),
                      padding: EdgeInsets.zero,
                      tooltip: 'Info Item Tersedia',
                      onPressed: () => _showAvailableItemsDialog(banner),
                      icon: const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // IconButton Info Riwayat Gacha
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white70, width: 1.5),
                    ),
                    child: IconButton(
                      constraints: const BoxConstraints(
                        minWidth: 38,
                        minHeight: 38,
                      ),
                      padding: EdgeInsets.zero,
                      tooltip: 'Riwayat Gacha',
                      onPressed: () => _showHistoryDialog(banner),
                      icon: const Icon(
                        Icons.history_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pojok Kanan Banner: 2 Tombol Gacha (1x Gacha & 10x Gacha)
            Positioned(
              right: 12,
              bottom: 10,
              child: Row(
                children: [
                  // Tombol Gacha 1x
                  ElevatedButton(
                    onPressed: () => _performGacha(banner, 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E1B4B),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Colors.amber,
                          width: 2,
                        ),
                      ),
                      elevation: 3,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Gacha 1x',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: Colors.amber,
                              size: 13,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${banner.costSingle}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Tombol Gacha 10x
                  ElevatedButton(
                    onPressed: () => _performGacha(banner, 10),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: const Color(0xFF1E1B4B),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      elevation: 3,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Gacha 10x',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: Color(0xFF1E1B4B),
                              size: 13,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${banner.costTen}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
