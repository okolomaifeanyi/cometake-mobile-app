import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../providers/wallet_provider.dart';
import '../widgets/transaction_tile.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletNotifierProvider);
    final txAsync = ref.watch(walletTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () async {
              await ref.read(walletNotifierProvider.notifier).refresh();
              ref.read(walletTransactionsProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(walletNotifierProvider.notifier).refresh();
          ref.read(walletTransactionsProvider.notifier).refresh();
        },
        child: CustomScrollView(
          slivers: [
            // ─── Balance card ──────────────────────────────────────
            SliverToBoxAdapter(
              child: walletAsync.when(
                loading: () => const _BalanceCardSkeleton(),
                error: (e, _) => AppErrorWidget(
                  message: e.toString(),
                  onRetry: () =>
                      ref.read(walletNotifierProvider.notifier).refresh(),
                ),
                data: (wallet) => _BalanceCard(
                  balance: wallet.balance,
                  onTopup: () => context.push(AppRoutes.walletTopup),
                ),
              ),
            ),

            // ─── Section header ────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.screenPaddingH,
                  AppDimensions.spacingLg,
                  AppDimensions.screenPaddingH,
                  AppDimensions.spacingSm,
                ),
                child: _SectionHeader(title: 'Recent Transactions'),
              ),
            ),

            // ─── Transactions ──────────────────────────────────────
            txAsync.when(
              loading: () => const SliverToBoxAdapter(
                  child: AppLoadingOverlay()),
              error: (e, _) => SliverToBoxAdapter(
                child: AppErrorWidget(
                  message: e.toString(),
                  onRetry: () => ref
                      .read(walletTransactionsProvider.notifier)
                      .refresh(),
                ),
              ),
              data: (txs) {
                if (txs.isEmpty) {
                  return const SliverFillRemaining(
                    child: _EmptyTransactions(),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      if (i.isOdd) {
                        return const Divider(height: 1,
                            indent: AppDimensions.screenPaddingH);
                      }
                      return TransactionTile(transaction: txs[i ~/ 2]);
                    },
                    childCount: txs.length * 2 - 1,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Balance card ──────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final double balance;
  final VoidCallback onTopup;

  const _BalanceCard({required this.balance, required this.onTopup});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.screenPaddingH),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingXl,
        vertical: AppDimensions.spacingXl,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Balance',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            Formatters.currency(balance),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: AppDimensions.spacingXl),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTopup,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Top Up',
                  style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCardSkeleton extends StatelessWidget {
  const _BalanceCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.screenPaddingH),
      height: 180,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: const AppLoadingOverlay(),
    );
  }
}

// ─── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w700),
      );
}

// ─── Empty state ───────────────────────────────────────────────────────────────

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text('No transactions yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              'Top up your wallet to get started',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
}
