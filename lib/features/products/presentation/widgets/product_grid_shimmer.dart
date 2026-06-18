import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_loading.dart';

class ProductGridShimmer extends StatelessWidget {
  final int count;
  const ProductGridShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.spacingMd,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.spacingMd,
          mainAxisSpacing: AppDimensions.spacingMd,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, __) => const _ProductCardShimmer(),
          childCount: count,
        ),
      ),
    );
  }
}

class _ProductCardShimmer extends StatelessWidget {
  const _ProductCardShimmer();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: double.infinity,
            height: AppDimensions.productCardImageHeight,
            radius: AppDimensions.radiusMd,
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          const ShimmerBox(width: double.infinity, height: 14),
          const SizedBox(height: AppDimensions.spacingXs),
          const ShimmerBox(width: 80, height: 14),
          const SizedBox(height: AppDimensions.spacingXs),
          ShimmerBox(
            width: MediaQuery.sizeOf(context).width * 0.25,
            height: 12,
          ),
        ],
      );
}
