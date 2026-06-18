import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/enums/order_status.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../domain/entities/order.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_tile.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersNotifierProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: ordersAsync.when(
          loading: () => const AppLoadingOverlay(),
          error: (e, _) => AppErrorWidget(
            message: e.toString(),
            onRetry: () =>
                ref.read(ordersNotifierProvider.notifier).refresh(),
          ),
          data: (orders) => TabBarView(
            children: [
              _OrderList(orders: orders, filter: null, ref: ref),
              _OrderList(
                orders: orders,
                filter: (o) => o.status.isActive,
                ref: ref,
              ),
              _OrderList(
                orders: orders,
                filter: (o) => o.status.isFinal,
                ref: ref,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<Order> orders;
  final bool Function(Order)? filter;
  final WidgetRef ref;

  const _OrderList({
    required this.orders,
    required this.filter,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final filtered =
        filter != null ? orders.where(filter!).toList() : orders;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: AppDimensions.spacingMd),
            Text('No orders yet',
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(ordersNotifierProvider.notifier).refresh(),
      child: ListView.separated(
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) => OrderTile(
          order: filtered[i],
          onTap: () => context.push(AppRoutes.orderDetailPath(filtered[i].id)),
        ),
      ),
    );
  }
}
