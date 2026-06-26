import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/vtu_datasource.dart';
import '../../data/models/vtu_model.dart';
import '../../domain/entities/vtu.dart';

// ─── Services per category ────────────────────────────────────────────────────

final vtuServicesProvider = FutureProvider.autoDispose
    .family<List<VtuService>, String>((ref, category) async {
  final ds = ref.watch(vtuDatasourceProvider);
  final models = await ds.fetchServices(category);
  return models.map((m) => m.toEntity()).toList();
});

// ─── Variations per service ───────────────────────────────────────────────────

final vtuVariationsProvider = FutureProvider.autoDispose
    .family<List<VtuVariation>, String>((ref, serviceId) async {
  final ds = ref.watch(vtuDatasourceProvider);
  final models = await ds.fetchVariations(serviceId);
  return models.map((m) => m.toEntity()).toList();
});

// ─── Purchase notifier ────────────────────────────────────────────────────────

class VtuPurchaseState {
  final bool isLoading;
  final String? error;
  final bool success;
  final String? message;
  final String? authorizationUrl;
  final String? reference;

  const VtuPurchaseState({
    this.isLoading = false,
    this.error,
    this.success = false,
    this.message,
    this.authorizationUrl,
    this.reference,
  });

  bool get requiresPaystack => authorizationUrl != null;

  VtuPurchaseState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
    String? message,
    String? authorizationUrl,
    String? reference,
  }) =>
      VtuPurchaseState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        success: success ?? this.success,
        message: message ?? this.message,
        authorizationUrl: authorizationUrl,
        reference: reference,
      );
}

class VtuPurchaseNotifier extends AutoDisposeNotifier<VtuPurchaseState> {
  @override
  VtuPurchaseState build() => const VtuPurchaseState();

  Future<bool> purchase({
    required String serviceType,
    required String provider,
    required double amount,
    required String recipient,
    String? variationCode,
    String? billersCode,
    String paymentMethod = 'WALLET',
  }) async {
    state = const VtuPurchaseState(isLoading: true);
    try {
      final ds = ref.read(vtuDatasourceProvider);
      final result = await ds.purchase(
        serviceType: serviceType,
        provider: provider,
        amount: amount,
        recipient: recipient,
        variationCode: variationCode,
        billersCode: billersCode,
        paymentMethod: paymentMethod,
      );
      // DIRECT payment: server returns authorization_url to open in WebView
      final authUrl = result['authorization_url']?.toString();
      if (authUrl != null) {
        state = VtuPurchaseState(
          authorizationUrl: authUrl,
          reference: result['reference']?.toString(),
        );
        return false;
      }
      final msg = result['message']?.toString() ?? 'Purchase successful';
      state = VtuPurchaseState(success: true, message: msg);
      return true;
    } catch (e) {
      state = VtuPurchaseState(error: e.toString());
      return false;
    }
  }

  Future<void> verifyPayment(String reference) async {
    state = const VtuPurchaseState(isLoading: true);
    final ds = ref.read(vtuDatasourceProvider);

    // Retry up to 3 times (5 s apart) when Paystack hasn't confirmed yet.
    // OPay → Paystack hand-off can take 5–15 s, so the first poll often
    // returns "Payment not successful" even after the user has paid.
    const maxAttempts = 4;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(const Duration(seconds: 5));
      }

      try {
        final result = await ds.verifyPayment(reference);
        final ok = result['status']?.toString() == 'success';
        final msg = result['message']?.toString();

        if (ok) {
          state = VtuPurchaseState(success: true, message: msg ?? 'Purchase successful');
          return;
        }

        // "Payment not successful" = Paystack hasn't received bank confirmation
        // yet — retry. Any other message (amount mismatch, etc.) is final.
        final isPending = msg == null || msg == 'Payment not successful';
        if (isPending && attempt < maxAttempts - 1) continue;

        // Final attempt or definitive failure — check Supabase in case the
        // webhook already fulfilled the purchase server-side.
        final status = await ds.checkTransactionStatus(reference).catchError((_) => null);
        if (status == 'COMPLETED') {
          state = const VtuPurchaseState(success: true, message: 'Purchase successful');
          return;
        }

        state = VtuPurchaseState(
          error: msg ?? 'Payment verification failed',
        );
        return;
      } catch (e) {
        if (attempt < maxAttempts - 1) continue;

        // Network error on final attempt — Supabase fallback.
        final status = await ds.checkTransactionStatus(reference).catchError((_) => null);
        if (status == 'COMPLETED') {
          state = const VtuPurchaseState(success: true, message: 'Purchase successful');
          return;
        }
        state = VtuPurchaseState(error: e.toString());
      }
    }
  }

  void reset() => state = const VtuPurchaseState();
}

final vtuPurchaseProvider =
    AutoDisposeNotifierProvider<VtuPurchaseNotifier, VtuPurchaseState>(
        () => VtuPurchaseNotifier(),);

// ─── Merchant verify ──────────────────────────────────────────────────────────

class VtuMerchantVerifyNotifier
    extends AutoDisposeNotifier<AsyncValue<VtuMerchantInfo?>> {
  @override
  AsyncValue<VtuMerchantInfo?> build() => const AsyncData(null);

  Future<void> verify({
    required String serviceId,
    required String billersCode,
    String? type,
  }) async {
    state = const AsyncLoading();
    try {
      final ds = ref.read(vtuDatasourceProvider);
      final model = await ds.verifyMerchant(
        serviceId: serviceId,
        billersCode: billersCode,
        type: type,
      );
      state = AsyncData(model?.toEntity());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void reset() => state = const AsyncData(null);
}

final vtuMerchantVerifyProvider = AutoDisposeNotifierProvider<
    VtuMerchantVerifyNotifier, AsyncValue<VtuMerchantInfo?>>(
  () => VtuMerchantVerifyNotifier(),
);

// ─── VTU history ──────────────────────────────────────────────────────────────

class VtuHistoryNotifier extends AsyncNotifier<List<VtuTransaction>> {
  @override
  Future<List<VtuTransaction>> build() async {
    final ds = ref.watch(vtuDatasourceProvider);
    final models = await ds.fetchHistory();
    return models.map((m) => m.toEntity()).toList();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final vtuHistoryProvider =
    AsyncNotifierProvider<VtuHistoryNotifier, List<VtuTransaction>>(
        () => VtuHistoryNotifier(),);
