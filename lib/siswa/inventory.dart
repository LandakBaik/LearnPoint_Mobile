import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/student_profile_model.dart';
import 'changepass.dart';
import 'notifikasi.dart';
import 'widgets/dashboard_header_widget.dart';

class Inventory extends StatefulWidget {
  final VoidCallback? onBackTap;
  const Inventory({super.key, this.onBackTap});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  final int money = 1999;
  int selectedIndex = 0;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const studentProfile = StudentProfileModel(
    name: 'Abimanyu',
    gradeClass: 'Kelas VIII-A',
    schoolName: 'SMP Merdeka',
    initials: 'AP',
    hasNotification: true,
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = item.where((alat) {
      return alat.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    final selectedItem = filteredItems.isNotEmpty
        ? filteredItems[selectedIndex.clamp(0, filteredItems.length - 1)]
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF4338CA),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Profil
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
              child: Column(
                children: [
                  // A. Layout Atas (Preview & Informasi Item)
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      color: const Color.fromARGB(255, 108, 175, 230),
                      child: Column(
                        children: [
                          // Baris Atas: Tombol Back & Poin/Koin
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

                          const SizedBox(height: 8),

                          // Baris Bawah: Gambar Item (Kiri) & Deskripsi Item (Kanan)
                          Expanded(
                            child: selectedItem == null
                                ? const Center(
                                    child: Text(
                                      'Item tidak ditemukan',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              selectedItem.icon,
                                              size: 64,
                                              color: selectedItem.color,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2.5,
                                            ),
                                          ),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  selectedItem.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20.0,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  selectedItem.desc,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // B. Layout Bawah (Search Bar & Grid Item)
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: const Color.fromARGB(229, 77, 106, 186),
                      child: Column(
                        children: [
                          // Search Bar & Tombol Search
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.5,
                                height: 40,
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    setState(() {
                                      searchQuery = value;
                                      selectedIndex = 0;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Cari item...',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 0,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      searchQuery = _searchController.text;
                                      selectedIndex = 0;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Icon(Icons.search),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Daftar Grid Item (4 Kolom)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                color: const Color.fromARGB(255, 94, 176, 243),
                              ),
                              child: GridView.builder(
                                padding: EdgeInsets.zero,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 1.0,
                                    ),
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  final isSelected = index == selectedIndex;
                                  final alat = filteredItems[index];

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = index;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.amber
                                              : Colors.black26,
                                          width: isSelected ? 3.0 : 1.0,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            alat.icon,
                                            color: alat.color,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            alat.name,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
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
