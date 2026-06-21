import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/product.dart';
import '../../data/datasources/wishlist_datasource.dart';

// Stores product IDs only — used for fast heart-button checks.
final wishlistIdsProvider =
    AsyncNotifierProvider<WishlistIdsNotifier, List<String>>(
  WishlistIdsNotifier.new,
  name: 'wishlistIdsProvider',
);

class WishlistIdsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() =>
      ref.read(wishlistDatasourceProvider).getWishlistIds();

  Future<void> toggle(String productId) async {
    final current = state.valueOrNull ?? [];
    if (current.contains(productId)) {
      state = AsyncData(current.where((id) => id != productId).toList());
      await ref.read(wishlistDatasourceProvider).removeFromWishlist(productId);
    } else {
      state = AsyncData([...current, productId]);
      await ref.read(wishlistDatasourceProvider).addToWishlist(productId);
    }
    // Invalidate the products list so the wishlist screen refreshes.
    ref.invalidate(wishlistProductsProvider);
  }
}

// Full product data — used by WishlistScreen.
final wishlistProductsProvider =
    AsyncNotifierProvider<WishlistProductsNotifier, List<Product>>(
  WishlistProductsNotifier.new,
  name: 'wishlistProductsProvider',
);

class WishlistProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() =>
      ref.read(wishlistDatasourceProvider).getWishlistProducts();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(wishlistDatasourceProvider).getWishlistProducts(),
    );
  }
}
