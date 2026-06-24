import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../domain/entities/vtu.dart';
import '../providers/vtu_provider.dart';

class VtuHistoryScreen extends ConsumerWidget {
  const VtuHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(vtuHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('VTU History')),
      body: historyAsync.when(
        loading: () => const AppLoadingOverlay(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.read(vtuHistoryProvider.notifier).refresh(),
        ),
        data: (txs) {
          if (txs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text('No transactions yet',
                      style: Theme.of(context).textTheme.titleMedium,),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(vtuHistoryProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: txs.length,
              separatorBuilder: (_, __) => const Divider(
                  height: 1, indent: AppDimensions.screenPaddingH,),
              itemBuilder: (_, i) => _VtuHistoryTile(transaction: txs[i]),
            ),
          );
        },
      ),
    );
  }
}

class _VtuHistoryTile extends StatelessWidget {
  final VtuTransaction transaction;
  const _VtuHistoryTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (transaction.status) {
      VtuStatus.completed => AppColors.success,
      VtuStatus.failed => AppColors.error,
      VtuStatus.pending => AppColors.warning,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.spacingMd,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: const Icon(Icons.bolt_outlined,
                color: AppColors.primary, size: 20,),
          ),
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
                  'To: ${transaction.recipient}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                Text(
                  Formatters.dateTime(transaction.createdAt),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.currency(transaction.amount),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                      fontWeight: FontWeight.w600,),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
