import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/vtu_datasource.dart';
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

  const VtuPurchaseState({
    this.isLoading = false,
    this.error,
    this.success = false,
    this.message,
  });

  VtuPurchaseState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
    String? message,
  }) =>
      VtuPurchaseState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        success: success ?? this.success,
        message: message ?? this.message,
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
      );
      final msg = result['message']?.toString() ?? 'Purchase successful';
      state = VtuPurchaseState(success: true, message: msg);
      return true;
    } catch (e) {
      state = VtuPurchaseState(error: e.toString());
      return false;
    }
  }

  void reset() => state = const VtuPurchaseState();
}

final vtuPurchaseProvider =
    AutoDisposeNotifierProvider<VtuPurchaseNotifier, VtuPurchaseState>(
        () => VtuPurchaseNotifier());

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
        () => VtuHistoryNotifier());
