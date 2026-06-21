import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _navigating = false;

  void _handleTap() {
    if (_navigating) return;
    _navigating = true;
    widget.onTap();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _navigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: _handleTap,
      child: Card(
        elevation: AppDimensions.cardElevation,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Product image ─────────────────────────────────────
            Stack(
              children: [
                SizedBox(
                  height: AppDimensions.productCardImageHeight,
                  width: double.infinity,
                  child: widget.product.thumbnailUrl != null
                      ? Hero(
                          tag: 'product-${widget.product.id}',
                          child: CachedNetworkImage(
                            imageUrl: CloudinaryService.optimized(
                              widget.product.thumbnailUrl!,
                              width: AppDimensions.productCardWidth.toInt() * 2,
                            ),
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _ImagePlaceholder(),
                            errorWidget: (_, __, ___) => _ImagePlaceholder(),
                          ),
                        )
                      : _ImagePlaceholder(),
                ),
                // Discount badge
                if (widget.product.hasDiscount)
                  Positioned(
                    top: AppDimensions.spacingXs,
                    left: AppDimensions.spacingXs,
                    child: _DiscountBadge(percent: widget.product.discountPercent),
                  ),
                // Out of stock overlay
                if (!widget.product.inStock)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black45,
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingSm,
                          vertical: AppDimensions.spacingXs,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                        ),
                        child: Text(
                          'Out of Stock',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ─── Product info ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          Formatters.currency(widget.product.price),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (widget.product.hasDiscount)
                        Text(
                          Formatters.currency(widget.product.comparePrice!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                  // Category label
                  if (widget.product.category != null) ...[
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      widget.product.category!.name,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.primary.withOpacity(0.06),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: AppDimensions.iconXl,
            color: AppColors.primary.withOpacity(0.3),
          ),
        ),
      );
}

class _DiscountBadge extends StatelessWidget {
  final int percent;
  const _DiscountBadge({required this.percent});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
        ),
        child: Text(
          '-$percent%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}
