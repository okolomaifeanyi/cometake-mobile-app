import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../domain/entities/vtu.dart';
import '../providers/vtu_provider.dart';

class VtuScreen extends ConsumerWidget {
  const VtuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(vtuHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VTU Services'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.vtuHistory),
            icon: const Icon(Icons.history),
            label: const Text('History'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Service tiles ─────────────────────────────────────
            Text(
              'Quick Services',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppDimensions.spacingMd,
              mainAxisSpacing: AppDimensions.spacingMd,
              childAspectRatio: 1.4,
              children: VtuServiceType.values
                  .map((t) => _ServiceTile(type: t))
                  .toList(),
            ),

            const SizedBox(height: AppDimensions.spacingXl),

            // ─── Recent history ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.vtuHistory),
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            historyAsync.when(
              loading: () => const Center(
                  child: Padding(
                padding: EdgeInsets.all(AppDimensions.spacingLg),
                child: CircularProgressIndicator(strokeWidth: 2),
              )),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () =>
                    ref.read(vtuHistoryProvider.notifier).refresh(),
              ),
              data: (txs) {
                final recent = txs.take(5).toList();
                if (recent.isEmpty) {
                  return const _EmptyHistory();
                }
                return Column(
                  children: recent
                      .map((t) => _VtuTxTile(transaction: t))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Service tile ─────────────────────────────────────────────────────────────

class _ServiceTile extends StatelessWidget {
  final VtuServiceType type;

  static const _colors = {
    VtuServiceType.airtime: Color(0xFF4CAF50),
    VtuServiceType.data: Color(0xFF2196F3),
    VtuServiceType.electricity: Color(0xFFFF9800),
    VtuServiceType.cable: Color(0xFF9C27B0),
  };

  static const _icons = {
    VtuServiceType.airtime: Icons.phone_android_outlined,
    VtuServiceType.data: Icons.wifi_outlined,
    VtuServiceType.electricity: Icons.bolt_outlined,
    VtuServiceType.cable: Icons.tv_outlined,
  };

  const _ServiceTile({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = _colors[type] ?? AppColors.primary;
    final icon = _icons[type] ?? Icons.miscellaneous_services;

    return InkWell(
      onTap: () => context.push(AppRoutes.vtuPurchasePath(type.name)),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              type.displayName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Transaction tile ─────────────────────────────────────────────────────────

class _VtuTxTile extends StatelessWidget {
  final VtuTransaction transaction;
  const _VtuTxTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (transaction.status) {
      VtuStatus.completed => AppColors.success,
      VtuStatus.failed => AppColors.error,
      VtuStatus.pending => AppColors.warning,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: Row(
        children: [
          Icon(Icons.receipt_outlined,
              color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${transaction.serviceType} — ${transaction.provider}',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  Formatters.dateTime(transaction.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.currency(transaction.amount),
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  transaction.status.displayName,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingXl),
          child: Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
}
