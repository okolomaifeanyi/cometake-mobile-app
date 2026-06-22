import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_module.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product.dart';

// Same columns as SupabaseProductsDatasource._kProductSelect
const _kSelect = '''
  id, name, price, description, weight, in_stock, unlist, created_at,
  sku, compare_price, tags, is_featured, category_id, seller_id,
  category:core_category!category_id(id, name),
  seller:core_user!seller_id(id, first_name, last_name),
  cover:core_media!product_cover_image_id(media)
''';

/// Fetches up to 40 products (newest first) and caches them for the session.
final homeProductPoolProvider = FutureProvider<List<Product>>((ref) async {
  final client = ref.read(supabaseClientProvider);
  final rows = await client
      .from('core_products')
      .select(_kSelect)
      .eq('unlist', false)
      .eq('approval_status', 'approved')
      .order('created_at', ascending: false)
      .limit(40);

  return (rows as List)
      .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
      .map((m) => m.toEntity())
      .toList();
});

/// New arrivals — newest 10 from pool (pool is already newest-first).
final newArrivalsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  return ref.watch(homeProductPoolProvider).whenData(
        (all) => all.take(10).toList(),
      );
});

/// Trending — isFeatured first; fallback to pool[10..17] (never overlaps with New Arrivals).
final trendingProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  return ref.watch(homeProductPoolProvider).whenData((all) {
    final featured = all.where((p) => p.isFeatured).take(8).toList();
    return featured.isNotEmpty ? featured : all.skip(10).take(8).toList();
  });
});

/// Best selling — 'bestseller' tagged; fallback to pool[18..25].
final bestSellingProvider = Provider<AsyncValue<List<Product>>>((ref) {
  return ref.watch(homeProductPoolProvider).whenData((all) {
    final bs = all.where((p) => p.tags.contains('bestseller')).take(8).toList();
    return bs.isNotEmpty ? bs : all.skip(18).take(8).toList();
  });
});

/// Recommended — pool[26..35].
final recommendedProvider = Provider<AsyncValue<List<Product>>>((ref) {
  return ref.watch(homeProductPoolProvider).whenData(
        (all) => all.skip(26).take(10).toList(),
      );
});
