import 'dart:math';
import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/features/siswa/gamification/models/item_model.dart';

class Gacha extends StatefulWidget {
  final VoidCallback? onBackTap;
  const Gacha({super.key, this.onBackTap});

  @override
  State<Gacha> createState() => _GachaState();
}

class _GachaState extends State<Gacha> {
  // State lokal yang dikelola dengan setState
  int _coins = 240;
  int _totalGacha = 0;
  final Random _random = Random();

  void _performGacha(int count) {
    final int cost = count == 1 ? 20 : 200;

    if (_coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Koin tidak cukup untuk membuka tiket!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final List<ItemModel> pulledItems = List.generate(
      count,
      (_) => item[_random.nextInt(item.length)],
    );

    // Memperbarui state lokal & memicu build() ulang pada widget ini
    setState(() {
      _coins -= cost;
      _totalGacha += count;
    });

    _showResultDialog(pulledItems);
  }

  void _showResultDialog(List<ItemModel> results) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF14182D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFF6C445), width: 2),
          ),
          title: Text(
            'Hasil Gacha (${results.length}x)',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: results.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: results.length == 1 ? 1 : 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: results.length == 1 ? 2.0 : 0.85,
              ),
              itemBuilder: (context, index) {
                final pulled = results[index];
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF6C445)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        pulled.icon,
                        color: pulled.color,
                        size: results.length == 1 ? 42 : 26,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pulled.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: results.length == 1 ? 13 : 10,
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

          // 2. Top Bar: Back Button (kiri) & Koin Badge (kanan)
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
                            '$_coins',
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
              ),
            ),
          ),

          // 3. Bottom Gacha Cards (Tiket Kereta Galaksi & Total Gacha)
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
                                        title: 'Buka 1x',
                                        cost: '20',
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
                                        title: 'Buka 10x',
                                        cost: '200',
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

                      // Card Kanan: Total Gacha
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
                                      'Total Gacha',
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
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 7),
                                        Text(
                                          '$_totalGacha',
                                          style: const TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                            height: 1,
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
          onTap: onTap,
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
