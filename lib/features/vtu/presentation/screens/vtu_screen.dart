import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../domain/entities/vtu.dart';
import '../providers/vtu_provider.dart';

class VtuScreen extends ConsumerWidget {
  const VtuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.bg,
      body: RefreshIndicator(
        color: AppColors.figmaGreen,
        onRefresh: () async => ref.read(vtuHistoryProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _VtuAppBar()),
            SliverToBoxAdapter(child: _VtuHero()),
            SliverToBoxAdapter(child: _TopUpServices()),
            SliverToBoxAdapter(child: _VtuHistorySection(ref: ref)),
            SliverToBoxAdapter(child: _TrustBanner()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────────────────────

class _VtuAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.bg,
      padding: EdgeInsets.fromLTRB(16, MediaQuery.viewPaddingOf(context).top + 8, 16, 12),
      child: Row(
        children: [
          Text(
            'VTU Services',
            style: TextStyle(
              color: context.t1,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.go(AppRoutes.vtuHistory),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.border),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded,
                      color: AppColors.figmaGreen, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'History',
                    style: TextStyle(
                      color: AppColors.figmaGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Banner ─────────────────────────────────────────────────────────────

class _VtuHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.figmaTeal, AppColors.figmaTealEnd],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.figmaGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'INSTANT TOP-UP',
                      style: TextStyle(
                        color: AppColors.figmaGreen,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Top Up &\nStay Connected',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Airtime, data, bills — all in one place.',
                    style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 12),
                  ),
                ],
              ),
            ),
            const Text('📱', style: TextStyle(fontSize: 52)),
          ],
        ),
      ),
    );
  }
}

// ─── Top-Up Services (2-col) ─────────────────────────────────────────────────

class _TopUpServices extends StatelessWidget {
  static const _services = [
    _VtuService(
      type: VtuServiceType.airtime,
      label: 'Airtime',
      subtitle: 'Instant recharge',
      icon: Icons.phone_android,
      color: Color(0xFF22C55E),
    ),
    _VtuService(
      type: VtuServiceType.data,
      label: 'Data Bundle',
      subtitle: 'High-speed internet',
      icon: Icons.wifi_rounded,
      color: Color(0xFF3B82F6),
    ),
    _VtuService(
      type: VtuServiceType.cable,
      label: 'Cable TV',
      subtitle: 'DSTV, GoTV & more',
      icon: Icons.tv_rounded,
      color: Color(0xFF8B5CF6),
    ),
    _VtuService(
      type: VtuServiceType.electricity,
      label: 'Electricity',
      subtitle: 'Prepaid & postpaid',
      icon: Icons.bolt_rounded,
      color: Color(0xFFEAB308),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'Quick Top-Up',
            style: TextStyle(
              color: context.t1,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: _services
                .map((s) => _TopUpCard(service: s))
                .expand((w) => [w, const SizedBox(height: 10)])
                .toList()
              ..removeLast(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _VtuService {
  final VtuServiceType type;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _VtuService({
    required this.type,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _TopUpCard extends StatelessWidget {
  final _VtuService service;
  const _TopUpCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.vtuPurchasePath(service.type.name)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: service.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(service.icon, color: service.color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.label,
                    style: TextStyle(
                      color: context.t1,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    service.subtitle,
                    style: TextStyle(color: context.t2, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.t4, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── VTU History Section ──────────────────────────────────────────────────────

class _VtuHistorySection extends ConsumerWidget {
  final WidgetRef ref;
  const _VtuHistorySection({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(vtuHistoryProvider);

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
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go(AppRoutes.vtuHistory),
                child: const Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        color: AppColors.figmaGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: AppColors.figmaGreen, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        historyAsync.when(
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
              onRetry: () => ref.read(vtuHistoryProvider.notifier).refresh(),
            ),
          ),
          data: (txs) {
            if (txs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_outlined, color: context.t4, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'No transactions yet',
                        style: TextStyle(color: context.t2, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: txs.take(5).map((t) => _VtuTxCard(tx: t)).toList(),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _VtuTxCard extends StatelessWidget {
  final VtuTransaction tx;
  const _VtuTxCard({required this.tx});

  static const _statusColors = {
    VtuStatus.completed: AppColors.figmaGreen,
    VtuStatus.failed: Color(0xFFEF4444),
    VtuStatus.pending: Color(0xFFF59E0B),
  };

  static const _serviceIcons = {
    'airtime': Icons.phone_android,
    'data': Icons.wifi_rounded,
    'cable': Icons.tv_rounded,
    'electricity': Icons.bolt_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColors[tx.status] ?? AppColors.figmaGreen;
    final serviceKey = tx.serviceType.toLowerCase();
    final icon = _serviceIcons.entries
        .firstWhere(
          (e) => serviceKey.contains(e.key),
          orElse: () => const MapEntry('', Icons.receipt_outlined),
        )
        .value;

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
              color: statusColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: statusColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tx.serviceType} — ${tx.provider}',
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
                  style: TextStyle(color: context.t2, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.currency(tx.amount),
                style: TextStyle(
                  color: context.t1,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tx.status.displayName,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Trust Banner ─────────────────────────────────────────────────────────────

class _TrustBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.figmaGreen.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.figmaGreen.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_rounded,
                  color: AppColors.figmaGreen, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Secure. Fast. Reliable.',
                    style: TextStyle(
                      color: context.t1,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'All transactions are encrypted and\nprocessed instantly.',
                    style: TextStyle(color: context.t2, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
