import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:learnpoint_mobile/features/siswa/gamification/data/gacha_service.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/models/item_model.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/screens/gacha_loading_screen.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/widgets/inventory/inventory_banner_grid_widget.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/widgets/inventory/inventory_banner_showcase_widget.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/widgets/inventory/inventory_power_grid_widget.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/widgets/inventory/inventory_power_showcase_widget.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/widgets/inventory/inventory_search_bar_widget.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/widgets/inventory/inventory_space_backdrop_widget.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/widgets/inventory/inventory_state_widgets.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/widgets/inventory/inventory_tab_selector_widget.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/widgets/inventory/inventory_top_bar_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/screens/quiz_per_mapel_loading_screen.dart';

class Inventory extends StatefulWidget {
  final VoidCallback? onBackTap;
  final int initialTab;
  const Inventory({super.key, this.onBackTap, this.initialTab = 0});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  int _coins = 0;
  int _pityCounter = 0;
  int _pityMax = 30;
  late int _selectedTab; // 0 = Item Power, 1 = Banner Dashboard
  int _selectedIndex = 0;
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isEquipping = false;
  String? _errorMessage;

  List<ItemModel> _powers = List<ItemModel>.from(item);
  List<BannerItemModel> _banners = const [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab.clamp(0, 1);
    _syncFromNotifiers(notify: false);
    for (final n in _notifiers) {
      n.addListener(_syncFromNotifiers);
    }
    _loadInventoryData();
  }

  List<Listenable> get _notifiers => [
    GachaService.coinsNotifier,
    GachaService.pityCounterNotifier,
    GachaService.pityMaxNotifier,
    GachaService.powersNotifier,
    GachaService.bannersNotifier,
  ];

  @override
  void dispose() {
    for (final n in _notifiers) {
      n.removeListener(_syncFromNotifiers);
    }
    _searchController.dispose();
    super.dispose();
  }

  void _syncFromNotifiers({bool notify = true}) {
    if (notify && !mounted) return;
    void apply() {
      _coins = GachaService.coinsNotifier.value;
      _pityCounter = GachaService.pityCounterNotifier.value;
      _pityMax = GachaService.pityMaxNotifier.value;
      _powers = GachaService.powersNotifier.value;
      _banners = GachaService.bannersNotifier.value;
    }

    if (notify) {
      setState(apply);
    } else {
      apply();
    }
  }

  Future<void> _loadInventoryData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await GachaService.fetchGachaStatus(includePanduanPowers: true);
      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      _showSnack('Gagal memuat data inventori dari server: $e', isError: true);
    }
  }

  Future<void> _handleEquipBanner(BannerItemModel banner) async {
    if (_isEquipping || !banner.isUnlocked || banner.isEquipped) return;

    setState(() => _isEquipping = true);
    try {
      await GachaService.equipBanner(banner.kode);
      if (!mounted) return;
      setState(() => _isEquipping = false);
      _showSnack('Banner "${banner.nama}" berhasil dipasang ke Dashboard!');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isEquipping = false);
      _showSnack('Gagal memasang banner: $e', isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openGachaScreen() {
    Navigator.of(context).push(quizSlideRoute<void>(const GachaLoadingScreen()));
  }

  void _handleBack() {
    if (widget.onBackTap != null) {
      widget.onBackTap!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _handleTabChanged(int tab) {
    if (_selectedTab == tab) return;
    setState(() {
      _selectedTab = tab;
      _selectedIndex = 0;
    });
  }

  void _handleSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _selectedIndex = 0;
    });
  }

  void _handleSearchClear() {
    _searchController.clear();
    _handleSearchChanged('');
  }

  List<ItemModel> get _filteredPowers {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _powers;
    return _powers
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.tagline.toLowerCase().contains(q) ||
              p.rarity.toLowerCase().contains(q),
        )
        .toList();
  }

  List<BannerItemModel> get _filteredBanners {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _banners;
    return _banners
        .where(
          (b) =>
              b.nama.toLowerCase().contains(q) ||
              b.badge.toLowerCase().contains(q) ||
              b.rarity.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isPowerTab = _selectedTab == 0;
    final powers = _filteredPowers;
    final banners = _filteredBanners;

    final activeCount = isPowerTab ? powers.length : banners.length;
    final safeIdx =
        activeCount > 0 ? _selectedIndex.clamp(0, activeCount - 1) : 0;

    final selectedPower = isPowerTab && powers.isNotEmpty ? powers[safeIdx] : null;
    final selectedBanner =
        !isPowerTab && banners.isNotEmpty ? banners[safeIdx] : null;

    return Scaffold(
      backgroundColor: const Color(0xFF070B1E),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: InventorySpaceBackdropWidget()),
          SafeArea(
            child: Column(
              children: [
                InventoryTopBarWidget(
                  coins: _coins,
                  pityCounter: _pityCounter,
                  pityMax: _pityMax,
                  isLoading: _isLoading,
                  onBackTap: _handleBack,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: InventoryTabSelectorWidget(
                    isPowerTab: isPowerTab,
                    totalPowerQty: _powers.fold<int>(
                      0,
                      (sum, p) => sum + (p.qty > 0 ? p.qty : 0),
                    ),
                    unlockedBannerCount: _banners.where((b) => b.isUnlocked).length,
                    totalBannerCount: _banners.length,
                    onTabChanged: _handleTabChanged,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: isPowerTab
                        ? InventoryPowerShowcaseWidget(item: selectedPower)
                        : InventoryBannerShowcaseWidget(
                            banner: selectedBanner,
                            isEquipping: _isEquipping,
                            onEquip: () {
                              if (selectedBanner != null) {
                                _handleEquipBanner(selectedBanner);
                              }
                            },
                            onOpenGacha: _openGachaScreen,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(child: _buildBottomPanel(isPowerTab, powers, banners, safeIdx)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(
    bool isPowerTab,
    List<ItemModel> powers,
    List<BannerItemModel> banners,
    int safeIdx,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0F1738).withValues(alpha: 0.94),
            const Color(0xFF080C20).withValues(alpha: 0.98),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          InventorySearchBarWidget(
            controller: _searchController,
            isPowerTab: isPowerTab,
            isLoading: _isLoading,
            searchQuery: _searchQuery,
            onChanged: _handleSearchChanged,
            onClear: _handleSearchClear,
            onRefresh: _loadInventoryData,
            onGachaTap: _openGachaScreen,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            const InventoryApiErrorBannerWidget(),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const InventoryLoadingStateWidget()
                : isPowerTab
                    ? InventoryPowerGridWidget(
                        items: powers,
                        selectedIndex: safeIdx,
                        onSelect: (i) => setState(() => _selectedIndex = i),
                      )
                    : InventoryBannerGridWidget(
                        banners: banners,
                        selectedIndex: safeIdx,
                        onSelect: (i) => setState(() => _selectedIndex = i),
                      ),
          ),
        ],
      ),
    );
  }
}
