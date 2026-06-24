import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/enums/order_status.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../../wallet/domain/entities/wallet.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';

// ─── Unified notification item ────────────────────────────────────────────────

class _NotifItem {
  final String id;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final DateTime time;
  final VoidCallback? onTap;

  const _NotifItem({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    this.onTap,
  });
}

List<_NotifItem> _fromOrders(List<Order> orders, BuildContext context) =>
    orders.map((o) {
      final (icon, color) = _orderIconColor(o.status);
      return _NotifItem(
        id: 'order-${o.id}',
        icon: icon,
        iconColor: color,
        title: _orderTitle(o.status),
        subtitle: 'Order ${o.orderNumber} · ${Formatters.currency(o.total)}',
        time: o.createdAt,
        onTap: () => context.push(AppRoutes.orderDetailPath(o.id)),
      );
    }).toList();

List<_NotifItem> _fromTransactions(List<WalletTransaction> txns) =>
    txns.map((t) => _NotifItem(
          id: 'tx-${t.id}',
          icon: t.isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          iconColor: t.isCredit ? AppColors.figmaGreen : AppColors.error,
          title: t.isCredit ? 'Wallet Credited' : 'Wallet Debited',
          subtitle: '${Formatters.currency(t.amount)} · ${t.description}',
          time: t.createdAt,
        )).toList();

(IconData, Color) _orderIconColor(OrderStatus status) => switch (status) {
      OrderStatus.pending => (Icons.access_time_rounded, Colors.orange),
      OrderStatus.confirmed => (Icons.check_circle_outline_rounded, AppColors.figmaGreen),
      OrderStatus.processing => (Icons.settings_outlined, Colors.blue),
      OrderStatus.shipped => (Icons.local_shipping_outlined, Colors.indigo),
      OrderStatus.delivered => (Icons.done_all_rounded, AppColors.figmaGreen),
      OrderStatus.cancelled => (Icons.cancel_outlined, AppColors.error),
      OrderStatus.refunded => (Icons.replay_rounded, Colors.orange),
    };

String _orderTitle(OrderStatus status) => switch (status) {
      OrderStatus.pending => 'Order Placed',
      OrderStatus.confirmed => 'Order Confirmed',
      OrderStatus.processing => 'Order Processing',
      OrderStatus.shipped => 'Order Shipped',
      OrderStatus.delivered => 'Order Delivered',
      OrderStatus.cancelled => 'Order Cancelled',
      OrderStatus.refunded => 'Order Refunded',
    };

// ─── Screen ──────────────────────────────────────────────────────────────────

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersNotifierProvider);
    final txnsAsync = ref.watch(walletTransactionsProvider);

    final items = <_NotifItem>[];

    ordersAsync.whenData((orders) => items.addAll(_fromOrders(orders, context)));
    txnsAsync.whenData((txns) => items.addAll(_fromTransactions(txns)));
    items.sort((a, b) => b.time.compareTo(a.time));

    final isLoading = ordersAsync.isLoading || txnsAsync.isLoading;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        title: Text(
          'Notifications',
          style: TextStyle(color: context.t1, fontWeight: FontWeight.w700),
        ),
        iconTheme: IconThemeData(color: context.t1),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? _EmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: context.border,
                    indent: 72,
                  ),
                  itemBuilder: (context, i) => _NotifTile(item: items[i]),
                ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final _NotifItem item;
  const _NotifTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: context.t1,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: TextStyle(color: context.t3, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _timeAgo(item.time),
              style: TextStyle(color: context.t4, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: context.t4,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                color: context.t2,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Order updates and wallet activity\nwill appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.t4, fontSize: 13),
            ),
          ],
        ),
      );
}
