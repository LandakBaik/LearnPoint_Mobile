import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InventorySearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isPowerTab;
  final bool isLoading;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onRefresh;
  final VoidCallback onGachaTap;

  const InventorySearchBarWidget({
    super.key,
    required this.controller,
    required this.isPowerTab,
    required this.isLoading,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
    required this.onRefresh,
    required this.onGachaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildSearchField()),
        const SizedBox(width: 8),
        _buildRefreshButton(),
        const SizedBox(width: 8),
        _buildGachaButton(),
      ],
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: isPowerTab
              ? 'Cari modul item power...'
              : 'Cari koleksi banner kosmik...',
          hintStyle: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF64748B),
            fontSize: 12.5,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF38BDF8),
            size: 19,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white54,
                    size: 17,
                  ),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF16204A).withValues(alpha: 0.85),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return SizedBox(
      height: 42,
      width: 42,
      child: Material(
        color: const Color(0xFF16204A),
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: isLoading ? null : onRefresh,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
              ),
            ),
            child: const Icon(
              Icons.sync_rounded,
              color: Color(0xFF38BDF8),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGachaButton() {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onGachaTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF59E0B),
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
        icon: const Icon(Icons.auto_awesome_rounded, size: 15),
        label: Text(
          'Gacha',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
