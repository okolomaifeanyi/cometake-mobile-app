import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/supabase_cart_datasource.dart';
import '../models/cart_model.dart';

class CartRepositoryImpl implements CartRepository {
  final SupabaseCartDatasource _datasource;
  const CartRepositoryImpl(this._datasource);

  Cart _toCart(List<CartItemModel> models) =>
      Cart(items: models.map((m) => m.toEntity()).toList());

  @override
  Future<Cart> getCart(String userId) async {
    try {
      return _toCart(await _datasource.getCartItems(userId));
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ServerException('Could not load cart.');
    }
  }

  @override
  Future<Cart> addItem({
    required String userId,
    required String productId,
    int quantity = 1,
  }) async {
    try {
      return _toCart(await _datasource.addItem(
          userId: userId, productId: productId, quantity: quantity,),);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ServerException('Could not add item to cart.');
    }
  }

  @override
  Future<Cart> updateQuantity({
    required String userId,
    required String itemId,
    required int quantity,
  }) async {
    try {
      return _toCart(await _datasource.updateQuantity(
          userId: userId, itemId: itemId, quantity: quantity,),);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ServerException('Could not update quantity.');
    }
  }

  @override
  Future<Cart> removeItem({
    required String userId,
    required String itemId,
  }) async {
    try {
      return _toCart(
          await _datasource.removeItem(userId: userId, itemId: itemId),);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ServerException('Could not remove item.');
    }
  }

  @override
  Future<void> clearCart(String userId) async {
    try {
      await _datasource.clearCart(userId);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ServerException('Could not clear cart.');
    }
  }
}
