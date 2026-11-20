import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/features/siswa/gamification/data/gacha_service.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/models/item_model.dart';
import 'package:learnpoint_mobile/features/siswa/profile/models/student_profile_model.dart';
import 'package:learnpoint_mobile/features/siswa/profile/screens/akun_screen.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/screens/notifikasi_screen.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/widgets/dashboard_header_widget.dart';

class Inventory extends StatefulWidget {
  final VoidCallback? onBackTap;
  const Inventory({super.key, this.onBackTap});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  int _coins = 0;
  int _selectedTab = 0; // 0 = Item Power, 1 = Banner Dashboard
  int selectedIndex = 0;
  String searchQuery = '';
  bool _isLoading = true;
  bool _isEquipping = false;

  List<ItemModel> _powers = List<ItemModel>.from(item);
  List<BannerItemModel> _banners = const [];

  final TextEditingController _searchController = TextEditingController();

  static const studentProfile = StudentProfileModel(
    name: 'Abimanyu',
    gradeClass: 'Kelas VIII-A',
    schoolName: 'SMP Merdeka',
    initials: 'AP',
    hasNotification: true,
  );

  @override
  void initState() {
    super.initState();
    _coins = GachaService.coinsNotifier.value;
    _powers = GachaService.powersNotifier.value;
    _banners = GachaService.bannersNotifier.value;

    GachaService.coinsNotifier.addListener(_syncFromNotifiers);
    GachaService.powersNotifier.addListener(_syncFromNotifiers);
    GachaService.bannersNotifier.addListener(_syncFromNotifiers);

    _loadInventoryData();
  }

  @override
  void dispose() {
    GachaService.coinsNotifier.removeListener(_syncFromNotifiers);
    GachaService.powersNotifier.removeListener(_syncFromNotifiers);
    GachaService.bannersNotifier.removeListener(_syncFromNotifiers);
    _searchController.dispose();
    super.dispose();
  }

  void _syncFromNotifiers() {
    if (!mounted) return;
    setState(() {
      _coins = GachaService.coinsNotifier.value;
      _powers = GachaService.powersNotifier.value;
      _banners = GachaService.bannersNotifier.value;
    });
  }

  Future<void> _loadInventoryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await GachaService.fetchGachaStatus(includePanduanPowers: true);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat inventory dari server: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleEquipBanner(BannerItemModel banner) async {
    if (_isEquipping || !banner.isUnlocked || banner.isEquipped) return;

    setState(() {
      _isEquipping = true;
    });

    try {
      await GachaService.equipBanner(banner.kode);
      if (!mounted) return;
      setState(() {
        _isEquipping = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Banner "${banner.nama}" berhasil dipasang!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isEquipping = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memasang banner: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPowers = _powers.where((alat) {
      return alat.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    final filteredBanners = _banners.where((b) {
      return b.nama.toLowerCase().contains(searchQuery.toLowerCase()) ||
          b.badge.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    final isPowerTab = _selectedTab == 0;
    final activeCount = isPowerTab ? filteredPowers.length : filteredBanners.length;
    final safeIdx = activeCount > 0
        ? selectedIndex.clamp(0, activeCount - 1)
        : 0;

    final ItemModel? selectedPower =
        isPowerTab && filteredPowers.isNotEmpty ? filteredPowers[safeIdx] : null;
    final BannerItemModel? selectedBanner =
        !isPowerTab && filteredBanners.isNotEmpty
            ? filteredBanners[safeIdx]
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
                      builder: (_) =>
                          const AkunScreen(profile: studentProfile),
                    ),
                  );
                },
              ),
            ),

            // 2. Main Content
            Expanded(
              child: Column(
                children: [
                  // A. Layout Atas (Preview & Informasi Item / Banner)
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
                          // Baris Atas: Tombol Back, Toggle Tab, & Koin
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

                              // Toggle Tab: Item Power vs Banner
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildTabPill(
                                      title: 'Power',
                                      icon: Icons.bolt_rounded,
                                      isActive: _selectedTab == 0,
                                      onTap: () {
                                        setState(() {
                                          _selectedTab = 0;
                                          selectedIndex = 0;
                                        });
                                      },
                                    ),
                                    _buildTabPill(
                                      title: 'Banner',
                                      icon: Icons.panorama_rounded,
                                      isActive: _selectedTab == 1,
                                      onTap: () {
                                        setState(() {
                                          _selectedTab = 1;
                                          selectedIndex = 0;
                                        });
                                      },
                                    ),
                                  ],
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
                                      _isLoading ? '...' : '$_coins',
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

                          // Baris Bawah: Preview Item Power atau Banner
                          Expanded(
                            child: isPowerTab
                                ? _buildPowerPreview(selectedPower)
                                : _buildBannerPreview(selectedBanner),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // B. Layout Bawah (Search Bar & Grid Item/Banner)
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
                          // Search Bar & Tombol Refresh
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
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
                                      hintText: isPowerTab
                                          ? 'Cari item power...'
                                          : 'Cari koleksi banner...',
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: _loadInventoryData,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Icon(Icons.refresh_rounded),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Daftar Grid (4 Kolom untuk Power, 2 Kolom untuk Banner)
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
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : isPowerTab
                                  ? _buildPowerGrid(filteredPowers, safeIdx)
                                  : _buildBannerGrid(filteredBanners, safeIdx),
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

  Widget _buildTabPill({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? const Color(0xFF4338CA) : Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isActive ? const Color(0xFF4338CA) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerPreview(ItemModel? selectedItem) {
    if (selectedItem == null) {
      return const Center(
        child: Text(
          'Item power tidak ditemukan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  selectedItem.icon,
                  size: 56,
                  color: selectedItem.color,
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'x${selectedItem.qty}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedItem.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: selectedItem.color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          selectedItem.rarity.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (selectedItem.tagline.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      selectedItem.tagline,
                      style: const TextStyle(
                        color: Color(0xFFFEF08A),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    selectedItem.desc,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerPreview(BannerItemModel? banner) {
    if (banner == null) {
      return const Center(
        child: Text(
          'Belum ada koleksi banner',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF0B1030),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (banner.isDefault || banner.fullGifUrl.isEmpty)
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  )
                else
                  Image.network(
                    banner.fullGifUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(
                        Icons.panorama_rounded,
                        color: Colors.white70,
                        size: 42,
                      ),
                    ),
                  ),
                if (!banner.isUnlocked)
                  Container(
                    color: Colors.black.withValues(alpha: 0.55),
                    child: const Center(
                      child: Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            banner.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: banner.rarityColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            banner.badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      banner.deskripsi.isNotEmpty
                          ? banner.deskripsi
                          : 'Banner latar belakang Hero Dashboard Siswa.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed:
                        (!banner.isUnlocked || banner.isEquipped || _isEquipping)
                        ? null
                        : () => _handleEquipBanner(banner),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: banner.isEquipped
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                      disabledBackgroundColor: banner.isEquipped
                          ? const Color(0xFF10B981)
                          : Colors.black26,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(
                      banner.isEquipped
                          ? Icons.check_circle_rounded
                          : (banner.isUnlocked
                                ? Icons.wallpaper_rounded
                                : Icons.lock_outline_rounded),
                      size: 15,
                    ),
                    label: Text(
                      banner.isEquipped
                          ? 'Sedang Dipasang'
                          : (banner.isUnlocked
                                ? (_isEquipping
                                      ? 'Memasang...'
                                      : 'Pasang Banner')
                                : 'Terkunci (Gacha)'),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPowerGrid(List<ItemModel> filteredItems, int currentSelected) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.92,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final isSelected = index == currentSelected;
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
                color: isSelected ? Colors.amber : Colors.black26,
                width: isSelected ? 3.0 : 1.0,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(alat.icon, color: alat.color, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        alat.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: alat.qty > 0
                          ? const Color(0xFF4338CA)
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'x${alat.qty}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBannerGrid(
    List<BannerItemModel> filteredBanners,
    int currentSelected,
  ) {
    if (filteredBanners.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada daftar banner.',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemCount: filteredBanners.length,
      itemBuilder: (context, index) {
        final isSelected = index == currentSelected;
        final banner = filteredBanners[index];

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
          },
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF0B1030),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors.amber
                    : (banner.isEquipped
                          ? const Color(0xFF10B981)
                          : Colors.white70),
                width: isSelected || banner.isEquipped ? 3.0 : 1.2,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (banner.isDefault || banner.fullGifUrl.isEmpty)
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  )
                else
                  Image.network(
                    banner.fullGifUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.78),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                if (!banner.isUnlocked)
                  Container(
                    color: Colors.black.withValues(alpha: 0.48),
                    child: const Center(
                      child: Icon(
                        Icons.lock_rounded,
                        color: Colors.white70,
                        size: 26,
                      ),
                    ),
                  ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: banner.isEquipped
                          ? const Color(0xFF10B981)
                          : banner.rarityColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      banner.isEquipped ? 'TERPASANG' : banner.badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 6,
                  child: Text(
                    banner.nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
