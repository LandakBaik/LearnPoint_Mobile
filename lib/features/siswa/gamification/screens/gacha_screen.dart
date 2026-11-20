import 'dart:async';
import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/core/config/api_config.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/data/gacha_service.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/models/item_model.dart';

class Gacha extends StatefulWidget {
  final VoidCallback? onBackTap;
  const Gacha({super.key, this.onBackTap});

  @override
  State<Gacha> createState() => _GachaState();
}

class _GachaState extends State<Gacha> {
  int _coins = 0;
  int _pityCounter = 0;
  int _pityMax = 30;
  int _harga1x = 20;
  int _harga10x = 180;

  bool _isLoadingStatus = true;
  bool _isPulling = false;

  @override
  void initState() {
    super.initState();
    _coins = GachaService.coinsNotifier.value;
    GachaService.coinsNotifier.addListener(_onCoinsChanged);
    _loadGachaStatus();
  }

  @override
  void dispose() {
    GachaService.coinsNotifier.removeListener(_onCoinsChanged);
    super.dispose();
  }

  void _onCoinsChanged() {
    if (!mounted) return;
    setState(() {
      _coins = GachaService.coinsNotifier.value;
    });
  }

  Future<void> _loadGachaStatus() async {
    setState(() {
      _isLoadingStatus = true;
    });

    try {
      final status = await GachaService.fetchGachaStatus();
      if (!mounted) return;
      setState(() {
        _coins = status.koin;
        _pityCounter = status.pityCounter;
        _pityMax = status.pityMax;
        _harga1x = status.harga1x;
        _harga10x = status.harga10x;
        _isLoadingStatus = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingStatus = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat status gacha: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _performGacha(int count) async {
    if (_isPulling) return;

    final int cost = count == 1 ? _harga1x : _harga10x;

    if (_coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Koin tidak cukup! Butuh $cost koin (Koinmu: $_coins).',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isPulling = true;
    });

    try {
      final pullResponse = await GachaService.pullGacha(count);
      if (!mounted) return;

      setState(() {
        _coins = pullResponse.sisaKoin;
        _pityCounter = pullResponse.pityCounter;
        _pityMax = pullResponse.pityMax;
        _isPulling = false;
      });

      await _showSummonAnimationDialog();
      if (!mounted) return;

      await _showResultDialog(pullResponse);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPulling = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _showSummonAnimationDialog() async {
    final summonUrl = ApiConfig.gachaSummonGifUrl;
    Timer? autoCloseTimer;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        autoCloseTimer = Timer(const Duration(milliseconds: 2400), () {
          if (Navigator.of(ctx).canPop()) {
            Navigator.of(ctx).pop();
          }
        });

        return Dialog(
          backgroundColor: const Color(0xFF0B1026),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFFF6C445), width: 2.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 260,
                  width: double.infinity,
                  child: summonUrl.isNotEmpty
                      ? Image.network(
                          summonUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildSummonFallback(),
                        )
                      : _buildSummonFallback(),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: TextButton.icon(
                    onPressed: () {
                      autoCloseTimer?.cancel();
                      if (Navigator.of(ctx).canPop()) {
                        Navigator.of(ctx).pop();
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.65),
                      foregroundColor: const Color(0xFFFBBF24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    icon: const Icon(Icons.fast_forward_rounded, size: 16),
                    label: const Text(
                      'Lewati',
                      style: TextStyle(
                        fontSize: 12,
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

    autoCloseTimer?.cancel();
  }

  Widget _buildSummonFallback() {
    return Container(
      color: const Color(0xFF14182D),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rocket_launch_rounded,
            color: Color(0xFFF6C445),
            size: 64,
          ),
          SizedBox(height: 14),
          Text(
            'Mendaratkan Kapsul Galaksi...',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showResultDialog(GachaPullResponseModel pullResponse) async {
    final results = pullResponse.items;
    final jackpotBanners = results
        .where((r) => r.banner != null)
        .map((r) => r.banner!)
        .toList();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF14182D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFF6C445), width: 2),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hasil Gacha (${results.length}x)',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pity Banner: ${pullResponse.pityCounter}/${pullResponse.pityMax} • Sisa Koin: ${pullResponse.sisaKoin}',
                style: const TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (jackpotBanners.isNotEmpty) ...[
                    for (final banner in jackpotBanners)
                      _buildJackpotBannerCard(ctx, banner),
                    const SizedBox(height: 12),
                  ],
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: results.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: results.length == 1 ? 1 : 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: results.length == 1 ? 2.2 : 1.05,
                    ),
                    itemBuilder: (context, index) {
                      final rollItem = results[index];
                      final pulled = rollItem.power ?? item.first;
                      final hasJackpot = rollItem.hasBannerJackpot;

                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasJackpot
                                ? const Color(0xFFA855F7)
                                : const Color(0xFFF6C445),
                            width: hasJackpot ? 2 : 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              pulled.icon,
                              color: pulled.color,
                              size: results.length == 1 ? 38 : 26,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              pulled.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: results.length == 1 ? 13.5 : 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: pulled.color.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${pulled.rarity.toUpperCase()} • Stok: ${pulled.qty}',
                                style: TextStyle(
                                  color: pulled.color,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: Color(0xFFFBBF24),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildJackpotBannerCard(BuildContext dialogCtx, BannerItemModel banner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B0764), Color(0xFF1E1B4B)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF6C445), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFFFBBF24), size: 16),
              const SizedBox(width: 6),
              Text(
                banner.isPity ? 'JACKPOT PITY BANNER!' : 'JACKPOT BANNER GIF!',
                style: const TextStyle(
                  color: Color(0xFFFBBF24),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (banner.fullGifUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 84,
                width: double.infinity,
                child: Image.network(
                  banner.fullGifUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: Colors.black26,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.panorama_rounded,
                      color: Colors.white54,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            banner.nama,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  await GachaService.equipBanner(banner.kode);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Banner "${banner.nama}" berhasil dipasang!'),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal memasang banner: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
              label: const Text(
                'Pasang ke Dashboard',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPanduanDialog() async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return FutureBuilder<GachaPanduanModel>(
          future: GachaService.fetchGachaPanduan(),
          builder: (context, snapshot) {
            return AlertDialog(
              backgroundColor: const Color(0xFF14182D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFF6C445), width: 2),
              ),
              title: const Text(
                'Panduan & Katalog Gacha',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const SizedBox(
                        height: 120,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFBBF24),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '• Setiap roll 100% pasti mendapat 1 Item Power.\n'
                                '• Peluang 3% per roll (atau Jaminan Pity ${_pityMax}x) mendapat hadiah tambahan Banner GIF Dashboard!\n'
                                '• Harga 1x: $_harga1x Koin | 10x: $_harga10x Koin',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Daftar Item Power (100%)',
                              style: TextStyle(
                                color: Color(0xFFFBBF24),
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            for (final p in (snapshot.data?.powers.isNotEmpty == true
                                ? snapshot.data!.powers
                                : GachaService.powersNotifier.value))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Icon(p.icon, color: p.color, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${p.name} — ${p.desc}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if ((snapshot.data?.banners ??
                                    GachaService.bannersNotifier.value)
                                .isNotEmpty) ...[
                              const SizedBox(height: 10),
                              const Text(
                                'Daftar Banner GIF (Jackpot 3% / Pity)',
                                style: TextStyle(
                                  color: Color(0xFFC084FC),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              for (final b in (snapshot.data?.banners.isNotEmpty == true
                                  ? snapshot.data!.banners
                                  : GachaService.bannersNotifier.value))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Icon(
                                        b.isUnlocked
                                            ? Icons.check_circle_rounded
                                            : Icons.panorama_rounded,
                                        color: b.rarityColor,
                                        size: 17,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${b.nama} (${b.badge})',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: Color(0xFFFBBF24),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14182D),
      body: Stack(
        children: [
          // 1. Fullscreen Galaxy Train Interior Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/gacha_train_bg.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // 2. Top Bar: Back Button (kiri), Info Panduan & Koin Badge (kanan)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap:
                            widget.onBackTap ??
                            () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _showPanduanDialog,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.help_outline_rounded,
                                color: Color(0xFFF6C445),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFF6C445),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBBF24),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFB45309),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.star_rounded,
                                  size: 11,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isLoadingStatus ? '...' : '$_coins',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Bottom Gacha Cards (Tiket Kereta Galaksi & Pity Counter)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card Kiri: Tiket Kereta Galaksi (Buka 1x & Buka 10x)
                      Expanded(
                        flex: 68,
                        child: _buildGoldenCard(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'tiket kereta galaksi',
                                  style: TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTicketButton(
                                        title: _isPulling ? 'Proses...' : 'Buka 1x',
                                        cost: '$_harga1x',
                                        gradientColors: const [
                                          Color(0xFFFFFFFF),
                                          Color(0xFFE0F2FE),
                                          Color(0xFFBAE6FD),
                                        ],
                                        accentColor: const Color(0xFF2563EB),
                                        borderColor: const Color(0xFFD4A753),
                                        onTap: () => _performGacha(1),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildTicketButton(
                                        title: _isPulling ? 'Proses...' : 'Buka 10x',
                                        cost: '$_harga10x',
                                        gradientColors: const [
                                          Color(0xFFFFFFFF),
                                          Color(0xFFF3E8FF),
                                          Color(0xFFDDD6FE),
                                        ],
                                        accentColor: const Color(0xFF7C3AED),
                                        borderColor: const Color(0xFFD4A753),
                                        isCosmic: true,
                                        onTap: () => _performGacha(10),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Card Kanan: Pity Counter (Jaminan Banner)
                      Expanded(
                        flex: 32,
                        child: _buildGoldenCard(
                          child: Stack(
                            children: [
                              Positioned(
                                right: -4,
                                bottom: -4,
                                child: Icon(
                                  Icons.directions_transit_rounded,
                                  size: 40,
                                  color: const Color(
                                    0xFF3B82F6,
                                  ).withValues(alpha: 0.14),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Pity Banner',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Transform.rotate(
                                          angle: -0.25,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFFFDE68A),
                                                  Color(0xFFF59E0B),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: const Color(0xFFB45309),
                                                width: 1,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.confirmation_number_rounded,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Flexible(
                                          child: Text(
                                            '$_pityCounter/$_pityMax',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF0F172A),
                                              fontSize: 17,
                                              fontWeight: FontWeight.w900,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoldenCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF6C445), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.38),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 22,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFDE047),
                    Color(0xFFFBBF24),
                    Color(0xFFF59E0B),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 11,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    Icon(
                      Icons.auto_awesome,
                      size: 11,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: child),
            Container(
              height: 7,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketButton({
    required String title,
    required String cost,
    required List<Color> gradientColors,
    required Color accentColor,
    required Color borderColor,
    required VoidCallback onTap,
    bool isCosmic = false,
  }) {
    return ClipPath(
      clipper: _TicketNotchClipper(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isPulling ? null : onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -2,
                  bottom: -3,
                  child: Icon(
                    Icons.directions_transit_rounded,
                    size: 26,
                    color: accentColor.withValues(alpha: 0.22),
                  ),
                ),
                if (isCosmic)
                  Positioned(
                    right: 6,
                    top: 4,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 11,
                      color: accentColor.withValues(alpha: 0.45),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Transform.rotate(
                        angle: -0.2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.confirmation_number_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 13,
                                  height: 13,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBBF24),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFB45309),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.star_rounded,
                                    size: 9,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  cost,
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
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
        ),
      ),
    );
  }
}

class _TicketNotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double notchRadius = 5.0;
    final Path path = Path();
    path.moveTo(notchRadius, 0);
    path.lineTo(size.width - notchRadius, 0);
    path.arcToPoint(
      Offset(size.width, notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height - notchRadius);
    path.arcToPoint(
      Offset(size.width - notchRadius, size.height),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.lineTo(notchRadius, size.height);
    path.arcToPoint(
      Offset(0, size.height - notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.lineTo(0, notchRadius);
    path.arcToPoint(
      const Offset(notchRadius, 0),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
