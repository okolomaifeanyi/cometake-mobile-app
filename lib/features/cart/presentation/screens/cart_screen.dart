import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          cartAsync.valueOrNull?.isEmpty == false
              ? TextButton(
                  onPressed: () => _confirmClear(context, ref),
                  child: const Text('Clear'),
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: cartAsync.when(
        loading: () => const AppLoadingOverlay(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () =>
              ref.read(cartNotifierProvider.notifier).refresh(),
        ),
        data: (cart) {
          if (cart.isEmpty) {
            return const _EmptyCartView();
          }
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(cartNotifierProvider.notifier).refresh(),
                  child: ListView.separated(
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final item = cart.items[i];
                      return CartItemTile(
                        item: item,
                        onRemove: () => ref
                            .read(cartNotifierProvider.notifier)
                            .removeItem(item.id),
                        onQuantityChanged: (qty) => ref
                            .read(cartNotifierProvider.notifier)
                            .updateQuantity(item.id, qty),
                      );
                    },
                  ),
                ),
              ),
              _CartSummary(subtotal: cart.subtotal, itemCount: cart.totalItems),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear'),),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(cartNotifierProvider.notifier).clearCart();
    }
  }
}

// ─── Cart summary bar ─────────────────────────────────────────────────────────

class _CartSummary extends StatefulWidget {
  final double subtotal;
  final int itemCount;

  const _CartSummary({required this.subtotal, required this.itemCount});

  @override
  State<_CartSummary> createState() => _CartSummaryState();
}

class _CartSummaryState extends State<_CartSummary> {
  bool _navigating = false;

  Future<void> _goCheckout() async {
    if (_navigating) return;
    setState(() => _navigating = true);
    await context.push('/checkout');
    if (mounted) setState(() => _navigating = false);
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal (${widget.itemCount} ${widget.itemCount == 1 ? 'item' : 'items'})',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                Formatters.currency(widget.subtotal),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          AppButton(
            label: 'Proceed to Checkout',
            onPressed: _navigating ? null : _goCheckout,
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text('Your cart is empty',
                style: Theme.of(context).textTheme.titleMedium,),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              'Add some products to get started',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
}
