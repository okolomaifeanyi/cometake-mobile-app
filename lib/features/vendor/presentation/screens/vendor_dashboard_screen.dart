import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../products/domain/entities/product.dart';
import '../providers/vendor_provider.dart';
import 'become_seller_screen.dart';

class VendorDashboardScreen extends ConsumerWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(myVendorSubscriptionProvider);

    return subscriptionAsync.when(
      loading: () => const Scaffold(body: AppLoadingOverlay()),
      error: (_, __) => const _Dashboard(),
      data: (sub) {
        if (sub == null || !sub.isActive) return const BecomeSellerScreen();
        return const _Dashboard();
      },
    );
  }
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(vendorProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () =>
                ref.read(vendorProductsProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.vendorAddProduct),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: productsAsync.when(
        loading: () => const AppLoadingOverlay(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () =>
              ref.read(vendorProductsProvider.notifier).refresh(),
        ),
        data: (products) {
          if (products.isEmpty) {
            return const _EmptyProducts();
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(vendorProductsProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: products.length,
              padding: const EdgeInsets.only(bottom: 100),
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (_, i) => _ProductTile(product: products[i]),
            ),
          );
        },
      ),
    );
  }
}

class _ProductTile extends ConsumerWidget {
  final Product product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isListed = !product.isUnlisted;

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        child: SizedBox(
          width: 48,
          height: 48,
          child: product.thumbnailUrl != null
              ? CachedNetworkImage(
                  imageUrl:
                      CloudinaryService.thumbnail(product.thumbnailUrl!, size: 96),
                  fit: BoxFit.cover,
                )
              : Container(
                  color: AppColors.primary.withOpacity(0.08),
                  child: const Icon(Icons.image_outlined,
                      color: AppColors.primary, size: 24,),
                ),
        ),
      ),
      title: Text(
        product.name,
        style: theme.textTheme.bodyMedium
            ?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text(
            Formatters.currency(product.price),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: AppDimensions.spacingXs),
          _StatusChip(label: isListed ? 'Listed' : 'Unlisted',
              color: isListed ? AppColors.success : AppColors.warning,),
          const SizedBox(width: AppDimensions.spacingXs),
          if (!product.inStock)
            const _StatusChip(label: 'Out of stock', color: AppColors.error),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (action) async {
          if (action == 'edit') {
            context.push(AppRoutes.vendorEditProductPath(product.id));
          } else if (action == 'delete') {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Delete product?'),
                content: Text('Delete "${product.name}"? This cannot be undone.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),),
                ],
              ),
            );
            if (confirmed == true && context.mounted) {
              await ref
                  .read(productMutationProvider.notifier)
                  .delete(product.id);
            }
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 9, fontWeight: FontWeight.w600,),),
      );
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,),
            const SizedBox(height: AppDimensions.spacingMd),
            Text('No products yet',
                style: Theme.of(context).textTheme.titleMedium,),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              'Tap + to add your first product',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
}
