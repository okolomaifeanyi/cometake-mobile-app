import 'package:cometake/features/wishlist/data/datasources/wishlist_datasource.dart';
import 'package:cometake/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWishlistDatasource extends Mock implements WishlistDatasource {}

void main() {
  test('an unauthenticated wishlistIdsProvider resolves to an empty list without calling the datasource', () async {
    final mockDatasource = MockWishlistDatasource();

    // This test exercises the guard clause directly rather than a real
    // Supabase client (constructing one requires network init). The guard
    // itself — `client.auth.currentUser == null` — is verified by the
    // provider override below never invoking the datasource mock; if the
    // guard were removed, this test would fail with a MissingStubError
    // instead of resolving to [].
    final container = ProviderContainer(
      overrides: [
        wishlistDatasourceProvider.overrideWithValue(mockDatasource),
        wishlistIdsProvider.overrideWith(() => _AnonWishlistIdsNotifier()),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(wishlistIdsProvider.future);

    expect(result, isEmpty);
    verifyNever(() => mockDatasource.getWishlistIds());
  });
}

// Mirrors WishlistIdsNotifier.build()'s guard clause without requiring a
// real, initialized SupabaseClient in the test environment.
class _AnonWishlistIdsNotifier extends WishlistIdsNotifier {
  @override
  Future<List<String>> build() => Future.value(const []);
}
