import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../domain/entities/wallet.dart';
import '../providers/wallet_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.bg,
      body: RefreshIndicator(
        color: AppColors.figmaGreen,
        onRefresh: () async {
          await ref.read(walletNotifierProvider.notifier).refresh();
          ref.read(walletTransactionsProvider.notifier).refresh();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _WalletAppBar(ref: ref)),
            SliverToBoxAdapter(child: _BalanceCard(ref: ref)),
            SliverToBoxAdapter(child: _WalletActions()),
            SliverToBoxAdapter(child: _QuickServices()),
            SliverToBoxAdapter(child: _TransactionsSection(ref: ref)),
            SliverToBoxAdapter(child: _PromoBanner()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _WalletAppBar extends StatelessWidget {
  final WidgetRef ref;
  const _WalletAppBar({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.bg,
      padding: EdgeInsets.fromLTRB(16, MediaQuery.viewPaddingOf(context).top + 8, 16, 12),
      child: Row(
        children: [
          Text(
            'My Wallet',
            style: TextStyle(
              color: context.t1,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              await ref.read(walletNotifierProvider.notifier).refresh();
              ref.read(walletTransactionsProvider.notifier).refresh();
            },
            child: Icon(Icons.refresh, color: context.t4, size: 22),
          ),
        ],
      ),
    );
  }
}

// ─── Balance Card ─────────────────────────────────────────────────────────────

class _BalanceCard extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _BalanceCard({required this.ref});

  @override
  ConsumerState<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends ConsumerState<_BalanceCard> {
  bool _showBalance = true;

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletNotifierProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.figmaTeal, AppColors.figmaTealEnd],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1A4040)),
        ),
        child: walletAsync.when(
          loading: () => const SizedBox(
            height: 160,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.figmaGreen,
                strokeWidth: 2,
              ),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(20),
            child: AppErrorWidget(
              message: e.toString(),
              onRetry: () =>
                  ref.read(walletNotifierProvider.notifier).refresh(),
            ),
          ),
          data: (wallet) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _showBalance = !_showBalance),
                      child: Icon(
                        _showBalance
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF9CA3AF),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _showBalance
                      ? Formatters.currency(wallet.balance)
                      : '₦•••,•••.••',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Wallet ID',
                            style: TextStyle(
                                color: Color(0xFF9CA3AF), fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          GestureDetector(
                            onTap: () {
                              final id =
                                  'CTK-${wallet.id.substring(0, wallet.id.length.clamp(0, 8)).toUpperCase()}';
                              Clipboard.setData(ClipboardData(text: id));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Wallet ID copied'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  'CTK-${wallet.id.substring(0, wallet.id.length.clamp(0, 8)).toUpperCase()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.copy,
                                    color: AppColors.figmaGreen, size: 14),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.figmaGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.account_balance_wallet,
                          color: AppColors.figmaGreen, size: 22),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 4-Action Grid ────────────────────────────────────────────────────────────

class _WalletActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = [
      _ActionItem(
        icon: Icons.add_circle_outline,
        label: 'Add Money',
        color: AppColors.figmaGreen,
        onTap: () => context.go(AppRoutes.walletTopup),
      ),
      _ActionItem(
        icon: Icons.history_rounded,
        label: 'History',
        color: const Color(0xFFF97316),
        onTap: () => context.go(AppRoutes.vtuHistory),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: actions
            .map((a) => Expanded(child: _ActionCard(item: a)))
            .expand((w) => [w, const SizedBox(width: 10)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _ActionCard extends StatelessWidget {
  final _ActionItem item;
  const _ActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.border),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: TextStyle(
                color: context.t1,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Services (5-col) ───────────────────────────────────────────────────

class _QuickServices extends StatelessWidget {
  static const _services = [
    _ServiceItem(
        'Airtime', Icons.phone_android, Color(0xFF22C55E), '/vtu/airtime'),
    _ServiceItem('Data', Icons.wifi, Color(0xFF3B82F6), '/vtu/data'),
    _ServiceItem('Cable TV', Icons.tv, Color(0xFF8B5CF6), '/vtu/cable'),
    _ServiceItem(
        'Electricity', Icons.bolt, Color(0xFFEAB308), '/vtu/electricity'),
    _ServiceItem('More', Icons.grid_view, Color(0xFF9CA3AF), '/vtu'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'Quick Services',
            style: TextStyle(
              color: context.t1,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _services.map((s) {
              return GestureDetector(
                onTap: () => context.go(s.route),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: s.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(s.icon, color: s.color, size: 24),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.label,
                      style: TextStyle(color: context.t3, fontSize: 10),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ServiceItem {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _ServiceItem(this.label, this.icon, this.color, this.route);
}

// ─── Transactions ─────────────────────────────────────────────────────────────

class _TransactionsSection extends ConsumerWidget {
  final WidgetRef ref;
  const _TransactionsSection({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(walletTransactionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  color: context.t1,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go(AppRoutes.vtuHistory),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.figmaGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        txAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                color: AppColors.figmaGreen,
                strokeWidth: 2,
              ),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppErrorWidget(
              message: e.toString(),
              onRetry: () =>
                  ref.read(walletTransactionsProvider.notifier).refresh(),
            ),
          ),
          data: (txs) {
            if (txs.isEmpty) {
              return _EmptyTxState();
            }
            return Column(
              children: txs.take(5).map((tx) => _TxCard(tx: tx)).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _EmptyTxState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, color: context.t4, size: 48),
            const SizedBox(height: 12),
            Text(
              'No transactions yet',
              style: TextStyle(color: context.t2, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _TxCard extends StatelessWidget {
  final WalletTransaction tx;
  const _TxCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.isCredit;
    final amountColor = isCredit ? AppColors.figmaGreen : Colors.red;
    final amountPrefix = isCredit ? '+' : '-';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: amountColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description.isNotEmpty
                      ? tx.description
                      : 'Wallet Transaction',
                  style: TextStyle(
                    color: context.t1,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.dateTime(tx.createdAt),
                  style: TextStyle(
                    color: context.t2,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix${Formatters.currency(tx.amount)}',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Bal: ${Formatters.currencyCompact(tx.balanceAfter)}',
                style: TextStyle(
                  color: context.t4,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Promo Banner ─────────────────────────────────────────────────────────────

class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.figmaTeal, AppColors.figmaTealEnd],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.figmaGreen.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enjoy Seamless Payments',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Add money to your wallet and\nshop without limits.',
                    style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.walletTopup),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.figmaGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Add Money Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Text('💳', style: TextStyle(fontSize: 40)),
          ],
        ),
      ),
    );
  }
}
