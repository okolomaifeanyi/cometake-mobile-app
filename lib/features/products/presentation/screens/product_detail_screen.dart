import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';

import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../domain/entities/product.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return productAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const AppLoadingOverlay(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(productDetailProvider(productId)),
        ),
      ),
      data: (product) => _ProductDetailView(product: product),
    );
  }
}

// ─── Full detail view ─────────────────────────────────────────────────────────

class _ProductDetailView extends StatefulWidget {
  final Product product;
  const _ProductDetailView({required this.product});

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  int _currentImage = 0;
  bool _descExpanded = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(AppDimensions.spacingSm),
            decoration: const BoxDecoration(
              color: Colors.black38,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        actions: [_WishlistButton(productId: product.id)],
      ),
      body: Column(
        children: [
          // ─── Image carousel ────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ImageCarousel(
                    images: product.images,
                    productId: product.id,
                    currentIndex: _currentImage,
                    onPageChanged: (i) =>
                        setState(() => _currentImage = i),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Price ───────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                Formatters.currency(product.price),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (product.hasDiscount) ...[
                              Text(
                                Formatters.currency(product.comparePrice!),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spacingSm),
                              _DiscountBadge(
                                  percent: product.discountPercent,),
                            ],
                          ],
                        ),

                        const SizedBox(height: AppDimensions.spacingSm),

                        // ─── Name ─────────────────────────────────
                        Text(
                          product.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spacingSm),

                        // ─── Chips row ────────────────────────────
                        Wrap(
                          spacing: AppDimensions.spacingXs,
                          runSpacing: AppDimensions.spacingXs,
                          children: [
                            _StockChip(inStock: product.inStock),
                            if (product.category != null)
                              _InfoChip(
                                icon: Icons.category_outlined,
                                label: product.category!.name,
                              ),
                            if (product.vendor != null)
                              _InfoChip(
                                icon: Icons.store_outlined,
                                label: product.vendor!.fullName,
                              ),
                          ],
                        ),

                        const SizedBox(height: AppDimensions.spacingMd),
                        const Divider(),
                        const SizedBox(height: AppDimensions.spacingMd),

                        // ─── Description ──────────────────────────
                        if (product.description.isNotEmpty) ...[
                          Text(
                            'Description',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingXs),
                          AnimatedCrossFade(
                            firstChild: Text(
                              product.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                            secondChild: Text(
                              product.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                            crossFadeState: _descExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 200),
                          ),
                          if (product.description.length > 200) ...[
                            const SizedBox(height: AppDimensions.spacingXs),
                            GestureDetector(
                              onTap: () => setState(
                                  () => _descExpanded = !_descExpanded,),
                              child: Text(
                                _descExpanded ? 'Show less' : 'Read more',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: AppDimensions.spacingMd),
                          const Divider(),
                          const SizedBox(height: AppDimensions.spacingMd),
                        ],

                        // ─── Tags ─────────────────────────────────
                        if (product.tags.isNotEmpty) ...[
                          Text(
                            'Tags',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingXs),
                          Wrap(
                            spacing: AppDimensions.spacingXs,
                            runSpacing: AppDimensions.spacingXs,
                            children: product.tags
                                .map((t) => Chip(
                                      label: Text(t),
                                      labelStyle:
                                          theme.textTheme.labelSmall,
                                      visualDensity:
                                          VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                    ),)
                                .toList(),
                          ),
                          const SizedBox(height: AppDimensions.spacingMd),
                        ],

                        // ─── Product details row ──────────────────
                        if (product.sku.isNotEmpty) ...[
                          _DetailRow(label: 'SKU', value: product.sku),
                          if (product.weight != null)
                            _DetailRow(
                              label: 'Weight',
                              value: '${product.weight} kg',
                            ),
                          const SizedBox(height: AppDimensions.spacingMd),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Add to cart CTA ───────────────────────────────────
          _AddToCartBar(product: product),
        ],
      ),
    );
  }
}

// ─── Image carousel ───────────────────────────────────────────────────────────

class _ImageCarousel extends StatelessWidget {
  final List<String> images;
  final String productId;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const _ImageCarousel({
    required this.images,
    required this.productId,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    const height = 300.0;

    if (images.isEmpty) {
      return SizedBox(
        height: height,
        child: Container(
          color: AppColors.primary.withOpacity(0.06),
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: 80,
              color: AppColors.primary.withOpacity(0.3),
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            onPageChanged: onPageChanged,
            itemCount: images.length,
            itemBuilder: (_, i) => Hero(
              tag: i == 0 ? 'product-$productId' : 'product-$productId-$i',
              child: CachedNetworkImage(
                imageUrl: CloudinaryService.optimized(
                  images[i],
                  width: MediaQuery.sizeOf(context).width.toInt(),
                  crop: 'limit',
                ),
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.primary.withOpacity(0.06),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.primary.withOpacity(0.06),
                  child: const Icon(Icons.broken_image_outlined, size: 48),
                ),
              ),
            ),
          ),
        ),
        // Dot indicators
        if (images.length > 1)
          Positioned(
            bottom: AppDimensions.spacingSm,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: currentIndex == i ? 16 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: currentIndex == i
                        ? Colors.white
                        : Colors.white54,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Add to cart bar ──────────────────────────────────────────────────────────

class _AddToCartBar extends ConsumerStatefulWidget {
  final Product product;
  const _AddToCartBar({required this.product});

  @override
  ConsumerState<_AddToCartBar> createState() => _AddToCartBarState();
}

class _AddToCartBarState extends ConsumerState<_AddToCartBar> {
  bool _adding = false;

  Future<void> _addToCart() async {
    setState(() => _adding = true);
    await ref
        .read(cartNotifierProvider.notifier)
        .addItem(widget.product.id);
    if (mounted) {
      setState(() => _adding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.name} added to cart'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'View Cart',
            onPressed: () => context.mounted
                ? Navigator.of(context).popUntil((r) => r.isFirst)
                : null,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenPaddingH,
        AppDimensions.spacingMd,
        AppDimensions.screenPaddingH,
        AppDimensions.spacingMd + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: AppButton(
        label: widget.product.inStock ? 'Add to Cart' : 'Out of Stock',
        onPressed: widget.product.inStock && !_adding ? _addToCart : null,
        isLoading: _adding,
        icon: widget.product.inStock && !_adding
            ? const Icon(Icons.shopping_cart_outlined)
            : null,
      ),
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _StockChip extends StatelessWidget {
  final bool inStock;
  const _StockChip({required this.inStock});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingSm,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: (inStock ? AppColors.success : AppColors.error)
              .withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              inStock
                  ? Icons.check_circle_outline
                  : Icons.cancel_outlined,
              size: 12,
              color: inStock ? AppColors.success : AppColors.error,
            ),
            const SizedBox(width: 4),
            Text(
              inStock ? 'In Stock' : 'Out of Stock',
              style: TextStyle(
                color: inStock ? AppColors.success : AppColors.error,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingSm,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
}

class _DiscountBadge extends StatelessWidget {
  final int percent;
  const _DiscountBadge({required this.percent});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Text(
          '-$percent%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

// ─── Wishlist heart button ────────────────────────────────────────────────────

class _WishlistButton extends ConsumerWidget {
  final String productId;
  const _WishlistButton({required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(wishlistIdsProvider).valueOrNull ?? [];
    final isSaved = ids.contains(productId);
    return Container(
      margin: const EdgeInsets.all(AppDimensions.spacingSm),
      decoration: const BoxDecoration(
        color: Colors.black38,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isSaved ? Colors.red : Colors.white,
          size: 22,
        ),
        onPressed: () =>
            ref.read(wishlistIdsProvider.notifier).toggle(productId),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.spacingXs),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      );
}
