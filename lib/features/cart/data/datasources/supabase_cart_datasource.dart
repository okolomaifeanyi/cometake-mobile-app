import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/cart_model.dart';

const _kCartSelect = '''
  id, product_id, quantity, created_at,
  product:core_products!product_id(
    id, name, price, compare_price, in_stock,
    cover:core_media!product_cover_image_id(media)
  )
''';

class SupabaseCartDatasource {
  final SupabaseClient _client;
  const SupabaseCartDatasource(this._client);

  Future<List<CartItemModel>> getCartItems(String userId) async {
    try {
      final response = await _client
          .from('cart_items')
          .select(_kCartSelect)
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => CartItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      throw ServerException('Failed to load cart: ${e.toString()}');
    }
  }

  Future<List<CartItemModel>> addItem({
    required String userId,
    required String productId,
    int quantity = 1,
  }) async {
    try {
      // Read-first: check if item exists to accumulate quantity
      final existing = await _client
          .from('cart_items')
          .select('id, quantity')
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();

      if (existing != null) {
        final currentQty = (existing['quantity'] as num).toInt();
        await _client
            .from('cart_items')
            .update({'quantity': currentQty + quantity, 'updated_at': DateTime.now().toIso8601String()})
            .eq('id', existing['id'] as String);
      } else {
        await _client.from('cart_items').insert({
          'user_id': userId,
          'product_id': productId,
          'quantity': quantity,
        });
      }

      return getCartItems(userId);
    } catch (e) {
      throw ServerException('Failed to add item to cart.');
    }
  }

  Future<List<CartItemModel>> updateQuantity({
    required String userId,
    required String itemId,
    required int quantity,
  }) async {
    try {
      await _client
          .from('cart_items')
          .update({'quantity': quantity, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', itemId)
          .eq('user_id', userId);
      return getCartItems(userId);
    } catch (e) {
      throw ServerException('Failed to update quantity.');
    }
  }

  Future<List<CartItemModel>> removeItem({
    required String userId,
    required String itemId,
  }) async {
    try {
      await _client
          .from('cart_items')
          .delete()
          .eq('id', itemId)
          .eq('user_id', userId);
      return getCartItems(userId);
    } catch (e) {
      throw ServerException('Failed to remove item.');
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      await _client
          .from('cart_items')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      throw ServerException('Failed to clear cart.');
    }
  }
}
