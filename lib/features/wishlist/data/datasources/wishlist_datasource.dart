import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_module.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product.dart';

const _kProductSelect = '''
  id, name, price, description, weight, in_stock, unlist, created_at,
  sku, compare_price, tags, is_featured, category_id, seller_id,
  category:core_category!category_id(id, name),
  seller:core_user!seller_id(id, first_name, last_name),
  cover:core_media!product_cover_image_id(media)
''';

class WishlistDatasource {
  final SupabaseClient _client;
  WishlistDatasource(this._client);

  Future<List<String>> getWishlistIds() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    final rows = await _client
        .from('core_saveditems')
        .select('product_id')
        .eq('user_id', userId);
    return (rows as List).map((r) => r['product_id'] as String).toList();
  }

  Future<List<Product>> getWishlistProducts() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    final rows = await _client
        .from('core_saveditems')
        .select('product:core_products!product_id($_kProductSelect)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (rows as List)
        .where((r) => r['product'] != null)
        .map((r) => ProductModel.fromJson(
              Map<String, dynamic>.from(r['product'] as Map),
            ).toEntity())
        .toList();
  }

  Future<void> addToWishlist(String productId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('core_saveditems').upsert(
      {'user_id': userId, 'product_id': productId, 'is_fake': false},
      onConflict: 'user_id,product_id',
    );
  }

  Future<void> removeFromWishlist(String productId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client
        .from('core_saveditems')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }
}

final wishlistDatasourceProvider = Provider<WishlistDatasource>(
  (ref) => WishlistDatasource(ref.watch(supabaseClientProvider)),
  name: 'wishlistDatasourceProvider',
);
