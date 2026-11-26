import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InventoryTopBarWidget extends StatelessWidget {
  final int coins;
  final int pityCounter;
  final int pityMax;
  final bool isLoading;
  final VoidCallback onBackTap;

  const InventoryTopBarWidget({
    super.key,
    required this.coins,
    required this.pityCounter,
    required this.pityMax,
    required this.isLoading,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          _buildBackButton(),
          const SizedBox(width: 12),
          Expanded(child: _buildTitle()),
          _buildPityBadge(),
          const SizedBox(width: 8),
          _buildCoinBadge(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onBackTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                'Inventori Antariksa',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 17.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF38BDF8),
              size: 16,
            ),
          ],
        ),
        Text(
          'Kapsul Power Kuis & Koleksi Banner Kosmik',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF94A3B8),
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFA855F7).withValues(alpha: 0.55),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 13,
            color: Color(0xFFC084FC),
          ),
          const SizedBox(width: 4),
          Text(
            '$pityCounter/$pityMax',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFE9D5FF),
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF59E0B).withValues(alpha: 0.24),
            const Color(0xFFB45309).withValues(alpha: 0.24),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFBBF24), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 17,
            height: 17,
            decoration: BoxDecoration(
              color: const Color(0xFFFBBF24),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFB45309), width: 1),
            ),
            child: const Icon(Icons.star_rounded, size: 11, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Text(
            isLoading ? '...' : '$coins',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
