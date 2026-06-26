import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/supabase_wallet_datasource.dart';
import '../../data/models/wallet_model.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/entities/wallet_verify_result.dart';

// ─── Wallet notifier ──────────────────────────────────────────────────────────

class WalletNotifier extends AsyncNotifier<Wallet> {
  @override
  Future<Wallet> build() async {
    final ds = ref.watch(walletDatasourceProvider);
    final model = await ds.fetchWallet();
    return model.toEntity();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final walletNotifierProvider =
    AsyncNotifierProvider<WalletNotifier, Wallet>(() => WalletNotifier());

// ─── Transactions notifier ────────────────────────────────────────────────────

class WalletTransactionsNotifier
    extends AsyncNotifier<List<WalletTransaction>> {
  @override
  Future<List<WalletTransaction>> build() async {
    final walletAsync = await ref.watch(walletNotifierProvider.future);
    final ds = ref.watch(walletDatasourceProvider);
    final models = await ds.fetchTransactions(walletAsync.id);
    return models.map((m) => m.toEntity()).toList();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final walletTransactionsProvider =
    AsyncNotifierProvider<WalletTransactionsNotifier, List<WalletTransaction>>(
        () => WalletTransactionsNotifier(),);

// ─── Topup notifier ───────────────────────────────────────────────────────────

class TopupNotifier extends AutoDisposeAsyncNotifier<TopupResult?> {
  @override
  Future<TopupResult?> build() async => null;

  Future<TopupResult?> initiate(double amount) async {
    state = const AsyncLoading();
    try {
      final ds = ref.read(walletDatasourceProvider);
      final model = await ds.initiateTopup(amount);
      final result = model.toEntity();
      state = AsyncData(result);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// Verify the payment, retrying on [VerifyPending] up to [maxAttempts] times.
  /// The delay between retries is read from the backend response (`retryAfterSeconds`)
  /// so we never hardcode a sleep here.
  Future<WalletVerifyResult> verify(
    String reference, {
    int maxAttempts = 3,
  }) async {
    final ds = ref.read(walletDatasourceProvider);
    WalletVerifyResult last = const VerifyFailed('Verification timed out');

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      last = await ds.verifyTopupStatus(reference);
      if (last is! VerifyPending) return last;
      if (attempt < maxAttempts - 1) {
        await Future<void>.delayed(
          Duration(seconds: last.retryAfterSeconds),
        );
      }
    }

    return last;
  }
}

final topupNotifierProvider =
    AsyncNotifierProvider.autoDispose<TopupNotifier, TopupResult?>(
        () => TopupNotifier(),);
