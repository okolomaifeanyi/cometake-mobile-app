import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class AppLoadingSpinner extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const AppLoadingSpinner({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class AppLoadingOverlay extends StatelessWidget {
  final String? message;

  const AppLoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppLoadingSpinner(size: 40),
          if (message != null) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = AppDimensions.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.cardDark : const Color(0xFFE0E0E0),
      highlightColor: isDark ? AppColors.surfaceDark : const Color(0xFFF5F5F5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.spacingSm,
      ),
      child: Row(
        children: [
          const ShimmerBox(
            width: AppDimensions.productCardImageHeight,
            height: AppDimensions.productCardImageHeight,
            radius: AppDimensions.radiusMd,
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: double.infinity, height: 16),
                const SizedBox(height: AppDimensions.spacingSm),
                ShimmerBox(
                  width: MediaQuery.sizeOf(context).width * 0.4,
                  height: 14,
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                const ShimmerBox(width: 80, height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
