import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_module.dart';
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
  Future<List<String>> build() {
    final client = ref.watch(supabaseClientProvider);
    if (client.auth.currentUser == null) return Future.value(const []);
    return ref.read(wishlistDatasourceProvider).getWishlistIds();
  }

  Future<void> toggle(String productId) async {
    final previous = state.valueOrNull ?? [];
    final removing = previous.contains(productId);
    final optimistic = removing
        ? previous.where((id) => id != productId).toList()
        : [...previous, productId];

    state = AsyncData(optimistic);

    try {
      if (removing) {
        await ref
            .read(wishlistDatasourceProvider)
            .removeFromWishlist(productId);
      } else {
        await ref.read(wishlistDatasourceProvider).addToWishlist(productId);
      }
    } catch (e) {
      // Roll back local heart state if persistence failed.
      state = AsyncData(previous);
      rethrow;
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
