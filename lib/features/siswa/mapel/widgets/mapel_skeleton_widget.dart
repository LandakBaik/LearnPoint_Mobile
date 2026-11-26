import 'package:flutter/material.dart';

/// Menyediakan animasi shimmer terpusat agar semua skeleton widget berbagi
/// satu [AnimationController] dan [LinearGradient] yang konsisten.
class ShimmerSkeletonScope extends StatefulWidget {
  final Widget Function(BuildContext context, Gradient shimmerGradient) builder;

  const ShimmerSkeletonScope({
    super.key,
    required this.builder,
  });

  @override
  State<ShimmerSkeletonScope> createState() => _ShimmerSkeletonScopeState();
}

class _ShimmerSkeletonScopeState extends State<ShimmerSkeletonScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final slide = -1.5 + (3.0 * _controller.value);
        final shimmerGradient = LinearGradient(
          begin: Alignment(slide - 1.0, -0.35),
          end: Alignment(slide + 1.0, 0.35),
          colors: const [
            Color(0xFFE2E8F0),
            Color(0xFFF1F5F9),
            Color(0xFFF8FAFC),
            Color(0xFFF1F5F9),
            Color(0xFFE2E8F0),
          ],
          stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
        );

        return widget.builder(context, shimmerGradient);
      },
    );
  }
}

class ShimmerBone extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final BoxShape shape;
  final Gradient? gradient;

  const ShimmerBone({
    super.key,
    this.width,
    required this.height,
    this.radius = 6,
    this.shape = BoxShape.rectangle,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    if (gradient == null) {
      return ShimmerSkeletonScope(
        builder: (_, resolvedGradient) => _buildBox(resolvedGradient),
      );
    }
    return _buildBox(gradient!);
  }

  Widget _buildBox(Gradient resolvedGradient) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: resolvedGradient,
        shape: shape,
        borderRadius:
            shape == BoxShape.rectangle ? BorderRadius.circular(radius) : null,
      ),
    );
  }
}

class MapelSkeletonListWidget extends StatelessWidget {
  final double horizontalMargin;
  final int itemCount;

  const MapelSkeletonListWidget({
    super.key,
    this.horizontalMargin = 20,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeletonScope(
      builder: (context, shimmerGradient) {
        return Column(
          children: List.generate(
            itemCount,
            (_) => _MapelCardSkeleton(
              horizontalMargin: horizontalMargin,
              shimmerGradient: shimmerGradient,
            ),
          ),
        );
      },
    );
  }
}

class _MapelCardSkeleton extends StatelessWidget {
  final double horizontalMargin;
  final Gradient shimmerGradient;

  const _MapelCardSkeleton({
    required this.horizontalMargin,
    required this.shimmerGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Banner Skeleton
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(19),
            ),
            child: Stack(
              children: [
                ShimmerBone(
                  width: double.infinity,
                  height: 106,
                  radius: 0,
                  gradient: shimmerGradient,
                ),
                Positioned(
                  left: 14,
                  bottom: 12,
                  child: Container(
                    width: 72,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Middle Row Skeleton
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                ShimmerBone(
                  width: 44,
                  height: 44,
                  radius: 12,
                  gradient: shimmerGradient,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBone(
                        width: 160,
                        height: 16,
                        radius: 6,
                        gradient: shimmerGradient,
                      ),
                      const SizedBox(height: 6),
                      ShimmerBone(
                        width: 110,
                        height: 12,
                        radius: 6,
                        gradient: shimmerGradient,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ShimmerBone(
                  width: 34,
                  height: 34,
                  shape: BoxShape.circle,
                  gradient: shimmerGradient,
                ),
              ],
            ),
          ),

          // Bottom Progress Section Skeleton
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBone(
                      width: 84,
                      height: 12,
                      radius: 6,
                      gradient: shimmerGradient,
                    ),
                    ShimmerBone(
                      width: 32,
                      height: 12,
                      radius: 6,
                      gradient: shimmerGradient,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ShimmerBone(
                  width: double.infinity,
                  height: 6,
                  radius: 99,
                  gradient: shimmerGradient,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton daftar item pada halaman Detail Mapel (tab Materi, Tugas, Ujian).
class DetailMapelListSkeletonWidget extends StatelessWidget {
  final int itemCount;

  const DetailMapelListSkeletonWidget({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeletonScope(
      builder: (context, shimmerGradient) {
        return Column(
          children: List.generate(
            itemCount,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.035),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ShimmerBone(
                        width: 44,
                        height: 44,
                        radius: 12,
                        gradient: shimmerGradient,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBone(
                              width: 170,
                              height: 15,
                              radius: 6,
                              gradient: shimmerGradient,
                            ),
                            const SizedBox(height: 6),
                            ShimmerBone(
                              width: 115,
                              height: 12,
                              radius: 6,
                              gradient: shimmerGradient,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ShimmerBone(
                        width: 34,
                        height: 34,
                        shape: BoxShape.circle,
                        gradient: shimmerGradient,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBone(
                        width: 86,
                        height: 12,
                        radius: 6,
                        gradient: shimmerGradient,
                      ),
                      ShimmerBone(
                        width: 58,
                        height: 12,
                        radius: 6,
                        gradient: shimmerGradient,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ShimmerBone(
                    width: double.infinity,
                    height: 5,
                    radius: 99,
                    gradient: shimmerGradient,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
