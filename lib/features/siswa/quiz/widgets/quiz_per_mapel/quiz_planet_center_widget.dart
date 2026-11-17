import 'package:flutter/material.dart';

/// Widget Lingkaran Planet Tengah untuk halaman QuizPerMapel.
/// Menampilkan asset gambar planet jika tersedia, atau placeholder bola bercahaya.
class QuizPlanetCenterWidget extends StatelessWidget {
  final String title;
  final Color baseColor;
  final String? imageAsset;

  const QuizPlanetCenterWidget({
    super.key,
    required this.title,
    required this.baseColor,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    if (imageAsset != null) {
      return Image.asset(
        imageAsset!,
        fit: BoxFit.contain,
      );
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.25, -0.3),
            radius: 0.85,
            colors: [
              const Color(0xFF67E8F9),
              const Color(0xFF06B6D4),
              baseColor,
              const Color(0xFF0E7490),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22D3EE).withValues(alpha: 0.45),
              blurRadius: 28,
              spreadRadius: 4,
            ),
          ],
          border: Border.all(
            color: const Color(0xFFA5F3FC).withValues(alpha: 0.75),
            width: 2.5,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
