import 'package:flutter/material.dart';

class HeroBannerWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String timeString;

  const HeroBannerWidget({
    super.key,
    this.title = 'Mau belajar apa\nhari ini?',
    this.subtitle = 'Yuk lanjutkan kegiatan\nbelajarmu.',
    this.timeString = '06:30',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6B93C7),
            Color(0xFF5A82B8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A82B8).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFFE2E8F0),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Right Digital Clock Style Graphics
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Text(
              timeString,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    blurRadius: 8.0,
                    color: Colors.white70,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
