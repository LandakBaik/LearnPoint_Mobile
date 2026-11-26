import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

import 'package:learnpoint_mobile/features/siswa/gamification/data/gacha_service.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/models/item_model.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/screens/gacha_loading_screen.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/config/quiz_assets.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/screens/quiz_per_mapel_loading_screen.dart';

class Gacha extends StatefulWidget {
  final VoidCallback? onBackTap;

  /// Status Gacha yang sudah dimuat sebelumnya (oleh GachaLoadingScreen).
  final GachaStatusModel? initialStatus;

  const Gacha({
    super.key,
    this.onBackTap,
    this.initialStatus,
  });

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
  bool _hideOptionsForPull = false;
  bool _isReturning = false;

  @override
  void initState() {
    super.initState();
    _coins = GachaService.coinsNotifier.value;
    GachaService.coinsNotifier.addListener(_onCoinsChanged);
    final preloaded = widget.initialStatus;
    if (preloaded != null) {
      _coins = preloaded.koin;
      _pityCounter = preloaded.pityCounter;
      _pityMax = preloaded.pityMax;
      _harga1x = preloaded.harga1x;
      _harga10x = preloaded.harga10x;
      _isLoadingStatus = false;
    } else {
      _loadGachaStatus();
    }
  }

  Future<void> _handleBackToQuiz() async {
    if (_isReturning) return;
    _isReturning = true;

    if (widget.onBackTap != null) {
      widget.onBackTap!();
      return;
    }

    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      quizSlideRoute<void>(
        const GachaLoadingScreen(isReturning: true),
      ),
    );
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

    // 1. Pudarkan opsi tombol Gacha terlebih dahulu
    setState(() {
      _isPulling = true;
      _hideOptionsForPull = true;
    });

    try {
      // Jalankan request API secara paralel dengan durasi pudarnya tombol opsi (380ms)
      final results = await Future.wait([
        GachaService.pullGacha(count),
        Future<void>.delayed(const Duration(milliseconds: 380)),
      ]);
      final pullResponse = results[0] as GachaPullResponseModel;
      if (!mounted) return;

      setState(() {
        _coins = pullResponse.sisaKoin;
        _pityCounter = pullResponse.pityCounter;
        _pityMax = pullResponse.pityMax;
      });

      // 2. Tampilkan animasi `gacha_pull.gif` di tengah layar + extend cahaya putih di akhir
      await _showSummonAnimationOverlay();
      if (!mounted) return;

      // 3. Tampilkan dialog item yang didapat
      await _showResultDialog(pullResponse);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPulling = false;
          _hideOptionsForPull = false;
        });
      }
    }
  }

  /// Menampilkan animasi `gacha_pull.gif` tepat di tengah layar tanpa efek meteor tambahan,
  /// lalu menahan (extend) cahaya putih di akhir animasi sebentar sebelum menampilkan hasil item.
  Future<void> _showSummonAnimationOverlay() async {
    // Evict cache GIF agar selalu mulai dari frame 0 setiap kali pull
    await AssetImage(QuizAssets.gachaPullEffect).evict();
    if (!mounted) return;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return const _GachaPullAnimationOverlay();
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
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

  Widget _buildJackpotBannerCard(
    BuildContext dialogCtx,
    BannerItemModel banner,
  ) {
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
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFFFBBF24),
                size: 16,
              ),
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
          if (banner.localAssetPath != null || banner.fullGifUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 84,
                width: double.infinity,
                child: BannerMediaView(
                  banner: banner,
                  fallbackWidget: Container(
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
                      content: Text(
                        'Banner "${banner.nama}" berhasil dipasang!',
                      ),
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
                            for (final p in (snapshot.data?.powers.isNotEmpty ==
                                    true
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
                              for (final b in (snapshot
                                          .data?.banners.isNotEmpty ==
                                      true
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleBackToQuiz();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0E0728),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background Parallax Gacha (Tanpa efek goyang/wavy)
            const Positioned.fill(
              child: _GachaParallaxBackground(),
            ),

            // 2. Top Bar: Back Button (kiri), Info Panduan & Koin Badge (kanan)
            //    Ikut memudar ketika animasi gacha sedang berjalan
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 320),
                  opacity: _hideOptionsForPull ? 0.0 : 1.0,
                  child: IgnorePointer(
                    ignoring: _hideOptionsForPull,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Material(
                            color: Colors.black.withValues(alpha: 0.38),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _handleBackToQuiz,
                              child: const Padding(
                                padding: EdgeInsets.all(9),
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.48),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B).withValues(
                                    alpha: 0.75,
                                  ),
                                  width: 1.3,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 14,
                                    color: Color(0xFFFBBF24),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Pity $_pityCounter/$_pityMax',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                color: Colors.black.withValues(alpha: 0.48),
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
                                    style: GoogleFonts.plusJakartaSans(
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
            ),
          ),

          // 3. Bottom Action Area: Tombol Gacha 1x & 10x Dibungkus dengan Asset `gacha op.gif`
          //    Memudar terlebih dahulu saat user menekan salah satu opsi Gacha
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                opacity: _hideOptionsForPull ? 0.0 : 1.0,
                child: IgnorePointer(
                  ignoring: _hideOptionsForPull,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Tombol Gacha 1x dibungkus portal Lottie
                            Expanded(
                              child: _buildGachaOpButton(
                                pullCountLabel: '1x',
                                subtitleLabel: 'Buka 1x',
                                cost: '$_harga1x',
                                glowColor: const Color(0xFFFB923C),
                                onTap: () => _performGacha(1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Tombol Gacha 10x dibungkus portal Lottie
                            Expanded(
                              child: _buildGachaOpButton(
                                pullCountLabel: '10x',
                                subtitleLabel: 'Buka 10x',
                                cost: '$_harga10x',
                                glowColor: const Color(0xFFFBBF24),
                                isMultiPull: true,
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
            ),
          ),
        ],
      ),
    ),
  );
  }

  /// Tombol Gacha (1x atau 10x) yang dibungkus langsung dengan aset `gacha op.gif`.
  /// Untuk tombol 10x (`isMultiPull = true`), ukuran dibuat lebih besar dan aset `gacha op.gif` diputar 90 derajat.
  Widget _buildGachaOpButton({
    required String pullCountLabel,
    required String subtitleLabel,
    required String cost,
    required Color glowColor,
    required VoidCallback onTap,
    bool isMultiPull = false,
  }) {
    final double orbSize = isMultiPull ? 210 : 172;
    final double glowSize = isMultiPull ? 156 : 126;

    return GestureDetector(
      onTap: _isPulling ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: orbSize,
            height: orbSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Cahaya lembut di belakang orb gacha op
                Container(
                  width: glowSize,
                  height: glowSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withValues(
                          alpha: isMultiPull ? 0.45 : 0.26,
                        ),
                        blurRadius: isMultiPull ? 36 : 22,
                        spreadRadius: isMultiPull ? 5 : 1,
                      ),
                    ],
                  ),
                ),

                // Aset pembungkus tombol: animasi Lottie `gacha_portal.json`
                // Untuk 10x diputar 90 derajat (quarterTurns: 1)
                Positioned.fill(
                  child: RotatedBox(
                    quarterTurns: isMultiPull ? 1 : 0,
                    child: Lottie.asset(
                      QuizAssets.gachaPortalLottie,
                      repeat: true,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Image.asset(
                        QuizAssets.gachaOpOrb,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Teks & Harga Koin di Tengah Portal
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pullCountLabel,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: isMultiPull ? 30 : 25,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                        shadows: [
                          Shadow(
                            color: glowColor.withValues(alpha: 0.9),
                            blurRadius: 12,
                          ),
                          const Shadow(
                            color: Colors.black,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitleLabel.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFFDE68A),
                        fontSize: isMultiPull ? 11.5 : 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: glowColor.withValues(alpha: 0.8),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Color(0xFFFBBF24),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            cost,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: isMultiPull ? 13 : 12,
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
        ],
      ),
    );
  }
}

/// Background halaman Gacha (Tanpa efek goyang/wavy):
/// 1. `gacha_main.png`
/// 2. `gacha_spiral.png` (gelombang opacity berkilau)
/// 3. `gacha_bigstars.png`
/// 4. `gacha_stars.png` (geser pelan ke kanan + kedip berurutan dari kiri ke kanan)
/// 5. `gacha_mist.png`
/// 6. `gacha_lightpath.png` (animasi looping dari tengah ke pinggir dengan jeda)
/// 7. `gacha_groundstars_light.png` (statis, tanpa efek bergoyang)
class _GachaParallaxBackground extends StatefulWidget {
  const _GachaParallaxBackground();

  @override
  State<_GachaParallaxBackground> createState() =>
      _GachaParallaxBackgroundState();
}

class _GachaParallaxBackgroundState extends State<_GachaParallaxBackground>
    with TickerProviderStateMixin {
  late final AnimationController _moveRightController;
  late final AnimationController _twinkleWaveController;
  late final AnimationController _lightPathLoopController;
  late final Animation<double> _twinkleSweepAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Menggeser gacha_stars pelan ke kanan lalu loop
    _moveRightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 80),
    )..repeat();

    // 2. Gelombang kedipan bintang & spiral dari kiri ke kanan
    _twinkleWaveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _twinkleSweepAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(_twinkleWaveController);

    // 3. Animasi gacha_lightpath dijalankan sekali saja ketika membuka screen Gacha:
    //    Muncul perlahan dari tengah melebar ke pinggir (3.1 detik), lalu tetap tampil penuh.
    _lightPathLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3100),
    )..forward();
  }

  @override
  void dispose() {
    _moveRightController.dispose();
    _twinkleWaveController.dispose();
    _lightPathLoopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Utama Gacha
          Image.asset(
            QuizAssets.gachaMainBg,
            fit: BoxFit.fill,
            alignment: Alignment.center,
          ),

          // 2. Layer Spiral Angin Gacha (Efek gelombang opacity mengalir seperti di Lobby)
          AnimatedBuilder(
            animation: _twinkleSweepAnimation,
            builder: (context, spiralChild) {
              return ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment(_twinkleSweepAnimation.value - 1.0, -0.2),
                    end: Alignment(_twinkleSweepAnimation.value + 1.0, 0.2),
                    tileMode: TileMode.repeated,
                    colors: [
                      Colors.white.withValues(alpha: 0.28),
                      Colors.white,
                      Colors.white.withValues(alpha: 0.40),
                      Colors.white,
                      Colors.white.withValues(alpha: 0.28),
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  ).createShader(rect);
                },
                child: spiralChild,
              );
            },
            child: Image.asset(
              QuizAssets.gachaSpiral,
              fit: BoxFit.fill,
              alignment: Alignment.center,
            ),
          ),

          // 3. Layer 3 Bintang Kuning Besar
          Image.asset(
            QuizAssets.gachaBigStars,
            fit: BoxFit.fill,
            alignment: Alignment.center,
          ),

          // 4. Layer Bintang Kecil (Geser pelan ke kanan & kedip berurutan dari kiri ke kanan)
          AnimatedBuilder(
            animation: Listenable.merge([
              _moveRightController,
              _twinkleSweepAnimation,
            ]),
            builder: (context, starChild) {
              final dx = _moveRightController.value * screenWidth;

              return ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment(_twinkleSweepAnimation.value - 1.0, 0),
                    end: Alignment(_twinkleSweepAnimation.value + 1.0, 0),
                    tileMode: TileMode.repeated,
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white,
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white,
                      Colors.white.withValues(alpha: 0.15),
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  ).createShader(rect);
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Transform.translate(
                      offset: Offset(dx, 0),
                      child: starChild,
                    ),
                    Transform.translate(
                      offset: Offset(dx - screenWidth, 0),
                      child: starChild,
                    ),
                  ],
                ),
              );
            },
            child: Image.asset(
              QuizAssets.gachaStars,
              fit: BoxFit.fill,
              alignment: Alignment.center,
            ),
          ),

          // 5. Layer Kabut (Mist)
          Image.asset(
            QuizAssets.gachaMist,
            fit: BoxFit.fill,
            alignment: Alignment.center,
          ),

          // 6. Layer Lightpath Gacha (Tepat di belakang groundstars, animasi looping dari tengah ke pinggir)
          _buildRevealingGachaLightPath(),

          // 7. Layer Ground Stars & Light (Statis tanpa efek bergoyang)
          Image.asset(
            QuizAssets.gachaGroundStarsLight,
            fit: BoxFit.fill,
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRevealingGachaLightPath() {
    const int stopCount = 21;

    return AnimatedBuilder(
      animation: _lightPathLoopController,
      builder: (context, child) {
        final progress = _lightPathLoopController.value;

        // Setelah animasi masuk selesai (progress >= 1.0), lightpath tetap tampil penuh tanpa ShaderMask
        if (progress >= 1.0) {
          return child!;
        }

        final stops = <double>[];
        final colors = <Color>[];
        const transitionWidth = 0.26;

        for (int i = 0; i < stopCount; i++) {
          final x = i / (stopCount - 1);
          final distFromCenter = (x - 0.5).abs(); // 0.0 di tengah, 0.5 di pinggir

          // Muncul perlahan dari tengah melebar ke pinggir sekali saja saat membuka screen
          final waveFront = (progress * 0.90) - 0.12;
          final raw =
              ((waveFront - distFromCenter) / transitionWidth).clamp(0.0, 1.0);
          final alpha = raw * raw * (3.0 - 2.0 * raw);

          stops.add(x);
          colors.add(Colors.white.withValues(alpha: alpha));
        }

        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: colors,
              stops: stops,
            ).createShader(rect);
          },
          child: child,
        );
      },
      child: Image.asset(
        QuizAssets.gachaLightPath,
        fit: BoxFit.fill,
        alignment: Alignment.center,
      ),
    );
  }
}

/// Overlay untuk memutar video `animasi_bintang_gacha.mp4` tepat di tengah layar (~11 detik),
/// lalu menyambung & menahan (extend) cahaya putih di akhir animasi sebelum menampilkan hasil item.
class _GachaPullAnimationOverlay extends StatefulWidget {
  const _GachaPullAnimationOverlay();

  @override
  State<_GachaPullAnimationOverlay> createState() =>
      _GachaPullAnimationOverlayState();
}

class _GachaPullAnimationOverlayState extends State<_GachaPullAnimationOverlay>
    with SingleTickerProviderStateMixin {
  // Durasi total overlay animasi gacha (~11 detik = 11000ms).
  // Menjelang akhir video (~10350ms), kita munculkan cahaya putih lembut
  // sebelum menutup overlay & membuka dialog hasil item.
  static const int _totalOverlayDurationMs = 11000;
  static const int _whiteFlashStartMs = 10350;

  late final VideoPlayerController _videoController;
  late final AnimationController _whiteExtendController;
  bool _videoReady = false;
  bool _videoError = false;
  Timer? _whiteFlashStartTimer;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();

    _whiteExtendController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _videoController = VideoPlayerController.asset(QuizAssets.gachaPullVideo);
    _initVideo();

    _whiteFlashStartTimer = Timer(
      const Duration(milliseconds: _whiteFlashStartMs),
      () {
        if (mounted) {
          _whiteExtendController.forward();
        }
      },
    );

    _autoCloseTimer = Timer(
      const Duration(milliseconds: _totalOverlayDurationMs),
      _closeOverlay,
    );
  }

  Future<void> _initVideo() async {
    try {
      await _videoController.initialize();
      if (!mounted) return;
      await _videoController.setLooping(false);
      await _videoController.play();
      if (!mounted) return;
      setState(() {
        _videoReady = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _videoError = true;
      });
    }
  }

  void _closeOverlay() {
    _whiteFlashStartTimer?.cancel();
    _autoCloseTimer?.cancel();
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _whiteFlashStartTimer?.cancel();
    _autoCloseTimer?.cancel();
    _videoController.dispose();
    _whiteExtendController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Video animasi `animasi_bintang_gacha.mp4` tampil penuh di tengah layar
          if (_videoReady)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else if (_videoError)
            Center(
              child: Image.asset(
                QuizAssets.gachaPullEffect,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fill,
                alignment: Alignment.center,
                gaplessPlayback: true,
              ),
            ),

          // 2. Extend cahaya putih menjelang akhir video (~10.35s -> 11s)
          AnimatedBuilder(
            animation: _whiteExtendController,
            builder: (context, _) {
              final v = Curves.easeInOut.transform(_whiteExtendController.value);
              if (v <= 0.0) return const SizedBox.shrink();

              return Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    color: const Color(0xFFFAF9F0).withValues(alpha: v),
                  ),
                ),
              );
            },
          ),

          // 3. Tombol Lewati di kanan bawah
          Positioned(
            bottom: 28,
            right: 20,
            child: SafeArea(
              child: TextButton.icon(
                onPressed: _closeOverlay,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.65),
                  foregroundColor: const Color(0xFFFBBF24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(
                      color: Color(0xFFF6C445),
                      width: 1.2,
                    ),
                  ),
                ),
                icon: const Icon(Icons.fast_forward_rounded, size: 17),
                label: Text(
                  'Lewati',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
