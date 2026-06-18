import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../domain/entities/order.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_tile.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return orderAsync.when(
      loading: () => Scaffold(appBar: AppBar(), body: const AppLoadingOverlay()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
      ),
      data: (order) => _OrderDetailView(order: order),
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  final Order order;
  const _OrderDetailView({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(Formatters.orderId(order.id)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Status card ───────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order Status',
                          style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                      _StatusChip(status: order.status),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Payment',
                          style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                      _PaymentChip(status: order.paymentStatus),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Placed',
                          style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                      Text(Formatters.dateTime(order.createdAt),
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spacingLg),
            Text('Items (${order.itemCount})',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppDimensions.spacingSm),

            // ─── Items list ────────────────────────────────────────
            ...order.items.map((item) => _OrderItemRow(item: item)),

            const Divider(height: AppDimensions.spacingXl),

            // ─── Total ─────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  Formatters.currency(order.total),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItem item;
  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding:
          const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            child: SizedBox(
              width: 56,
              height: 56,
              child: item.product?.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: CloudinaryService.thumbnail(
                          item.product!.imageUrl!, size: 112),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.primary.withOpacity(0.06),
                      child: const Icon(Icons.image_outlined, size: 24)),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product?.name ?? 'Product',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.quantity} × ${Formatters.currency(item.price)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            Formatters.currency(item.total),
            style: theme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final dynamic status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) => _StatusChipWidget(label: status.displayName, color: _color);

  Color get _color => switch (status.name) {
        'delivered' => AppColors.success,
        'shipped' => AppColors.info,
        'processing' || 'confirmed' => AppColors.warning,
        'cancelled' || 'refunded' => AppColors.error,
        _ => AppColors.textSecondaryLight,
      };
}

class _PaymentChip extends StatelessWidget {
  final dynamic status;
  const _PaymentChip({required this.status});

  @override
  Widget build(BuildContext context) => _StatusChipWidget(
        label: status.displayName,
        color: status.isSuccessful ? AppColors.success : AppColors.warning,
      );
}

class _StatusChipWidget extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChipWidget({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      );
}
