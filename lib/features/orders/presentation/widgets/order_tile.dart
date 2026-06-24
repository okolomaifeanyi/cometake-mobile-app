import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/enums/order_status.dart';
import '../../../../shared/enums/payment_status.dart';
import '../../domain/entities/order.dart';

class OrderTile extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderTile({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingH,
          vertical: AppDimensions.spacingMd,
        ),
        child: Row(
          children: [
            // Status indicator dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _statusColor(order.status),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Formatters.orderId(order.id),
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'} · ${Formatters.date(order.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.currency(order.total),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                _StatusChip(status: order.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus s) => switch (s) {
        OrderStatus.delivered => AppColors.success,
        OrderStatus.shipped => AppColors.info,
        OrderStatus.processing || OrderStatus.confirmed => AppColors.warning,
        OrderStatus.cancelled || OrderStatus.refunded => AppColors.error,
        OrderStatus.pending => AppColors.textSecondaryLight,
      };
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OrderStatus.delivered => AppColors.success,
      OrderStatus.shipped => AppColors.info,
      OrderStatus.processing || OrderStatus.confirmed => AppColors.warning,
      OrderStatus.cancelled || OrderStatus.refunded => AppColors.error,
      OrderStatus.pending => AppColors.textSecondaryLight,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
