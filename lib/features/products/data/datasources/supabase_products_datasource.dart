import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';
import 'products_datasource.dart';

// core_user has no public SELECT RLS policy — omit seller join for all queries
// to avoid PostgREST failing the entire query for unauthenticated users.
// seller_id is still returned so the vendor can be resolved separately if needed.
const _kProductSelect = '''
  id, name, price, description, weight, in_stock, unlist, created_at,
  sku, compare_price, tags, is_featured, category_id, seller_id,
  category:core_category!category_id(id, name),
  cover:core_media!product_cover_image_id(media)
''';

const _kProductDetailSelect = _kProductSelect;

const _kSortMap = {
  'newest': ('created_at', false),    // col, ascending
  'oldest': ('created_at', true),
  'price_asc': ('price', true),
  'price_desc': ('price', false),
};

class SupabaseProductsDatasource implements ProductsDatasource {
  final SupabaseClient _client;
  const SupabaseProductsDatasource(this._client);

  @override
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sort,
  }) async {
    try {
      final from = (page - 1) * limit;
      final to = from + limit - 1;

      var query = _client.from('core_products').select(_kProductSelect);

      // Active and approved products only
      query = query.eq('unlist', false).eq('approval_status', 'approved');

      if (search != null && search.isNotEmpty) {
        query = query.ilike('name', '%$search%');
      }
      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }
      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }
      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }

      // Sort
      final (col, ascending) = _kSortMap[sort] ?? ('created_at', false);
      final response = await query
          .order(col, ascending: ascending)
          .range(from, to);

      return (response as List)
          .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to load products: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _client
          .from('core_products')
          .select(_kProductDetailSelect)
          .eq('id', id)
          .single();

      return ProductModel.fromJson(Map<String, dynamic>.from(response as Map));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') throw const NotFoundException('Product not found');
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Failed to load product: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductCategory>> getCategories() async {
    try {
      final response = await _client
          .from('core_category')
          .select('id, name')
          .order('name');

      return (response as List).map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return ProductCategory(id: m['id'] as String, name: m['name'] as String);
      }).toList();
    } catch (e) {
      // Non-fatal — return empty list so filters just don't show
      return [];
    }
  }
}
