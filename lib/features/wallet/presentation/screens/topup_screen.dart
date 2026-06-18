import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/wallet_provider.dart';

class TopupScreen extends ConsumerStatefulWidget {
  const TopupScreen({super.key});

  @override
  ConsumerState<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends ConsumerState<TopupScreen> {
  final _ctrl = TextEditingController();
  bool _launched = false;

  static const _presets = [500, 1000, 2000, 5000, 10000];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double? get _amount {
    final v = double.tryParse(_ctrl.text.replaceAll(',', ''));
    return (v != null && v >= 100) ? v : null;
  }

  Future<void> _pay() async {
    final amt = _amount;
    if (amt == null) return;

    final result =
        await ref.read(topupNotifierProvider.notifier).initiate(amt);
    if (result == null || !mounted) return;

    final uri = Uri.tryParse(result.authorizationUrl);
    if (uri == null) return;

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (ok && mounted) {
      setState(() => _launched = true);
    }
  }

  Future<void> _refresh() async {
    await ref.read(walletNotifierProvider.notifier).refresh();
    await ref.read(walletTransactionsProvider.notifier).refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wallet refreshed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topupAsync = ref.watch(topupNotifierProvider);
    final isLoading = topupAsync.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Top Up Wallet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Amount input ──────────────────────────────────────
            Text(
              'Enter amount',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            TextFormField(
              controller: _ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                prefixText: '₦  ',
                hintText: '1000',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                ),
                helperText: 'Minimum ₦100',
              ),
              style: Theme.of(context).textTheme.headlineSmall,
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: AppDimensions.spacingMd),

            // ─── Preset amounts ────────────────────────────────────
            Wrap(
              spacing: AppDimensions.spacingSm,
              children: _presets.map((p) {
                return ActionChip(
                  label: Text(Formatters.currency(p.toDouble())),
                  onPressed: () {
                    _ctrl.text = p.toString();
                    setState(() {});
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: AppDimensions.spacingXl),

            // ─── Pay button ────────────────────────────────────────
            if (!_launched)
              AppButton(
                label: 'Pay with Paystack',
                onPressed: _amount != null && !isLoading ? _pay : null,
                isLoading: isLoading,
                icon: const Icon(Icons.payment_outlined),
              ),

            // ─── Post-launch state ─────────────────────────────────
            if (_launched) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.08),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(
                      color: AppColors.success.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.open_in_browser,
                        color: AppColors.success, size: 32),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Text(
                      'Payment page opened in your browser.',
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      'Complete the payment, then tap Refresh below.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              AppButton(
                label: 'Refresh Wallet Balance',
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _launched = false),
                  child: const Text('Pay a different amount'),
                ),
              ),
            ],

            if (topupAsync.hasError)
              Padding(
                padding:
                    const EdgeInsets.only(top: AppDimensions.spacingMd),
                child: Text(
                  topupAsync.error.toString(),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
