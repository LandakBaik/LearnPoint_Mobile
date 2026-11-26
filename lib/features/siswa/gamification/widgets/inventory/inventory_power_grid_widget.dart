import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:learnpoint_mobile/features/siswa/gamification/models/item_model.dart';

class InventoryPowerGridWidget extends StatelessWidget {
  final List<ItemModel> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const InventoryPowerGridWidget({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada Item Power yang cocok dengan pencarian.',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 2, bottom: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.88,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _PowerGridCell(
        item: items[index],
        isSelected: index == selectedIndex,
        onTap: () => onSelect(index),
      ),
    );
  }
}

class _PowerGridCell extends StatelessWidget {
  final ItemModel item;
  final bool isSelected;
  final VoidCallback onTap;

  const _PowerGridCell({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasStock = item.qty > 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [item.color.withValues(alpha: 0.28), const Color(0xFF16204A)]
                : [
                    const Color(0xFF151E46).withValues(alpha: 0.85),
                    const Color(0xFF0E1432).withValues(alpha: 0.9),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFBBF24)
                : (hasStock
                      ? item.color.withValues(alpha: 0.45)
                      : Colors.white.withValues(alpha: 0.1)),
            width: isSelected ? 2.2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.22),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            _buildTopRow(hasStock),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: _buildIconAndName(hasStock),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow(bool hasStock) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: item.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: item.color.withValues(alpha: 0.6), blurRadius: 6),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: hasStock
                ? item.color.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasStock ? item.color.withValues(alpha: 0.7) : Colors.white12,
            ),
          ),
          child: Text(
            'x${item.qty}',
            style: GoogleFonts.plusJakartaSans(
              color: hasStock ? Colors.white : Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconAndName(bool hasStock) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: item.color.withValues(alpha: hasStock ? 0.18 : 0.08),
            border: Border.all(
              color: item.color.withValues(alpha: hasStock ? 0.55 : 0.2),
            ),
          ),
          child: Icon(
            item.icon,
            color: hasStock ? item.color : item.color.withValues(alpha: 0.45),
            size: 25,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            color: hasStock ? Colors.white : Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}
