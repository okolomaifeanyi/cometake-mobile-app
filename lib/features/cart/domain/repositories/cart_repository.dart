import '../entities/cart.dart';

abstract class CartRepository {
  Future<Cart> getCart(String userId);
  Future<Cart> addItem({required String userId, required String productId, int quantity = 1});
  Future<Cart> updateQuantity({required String userId, required String itemId, required int quantity});
  Future<Cart> removeItem({required String userId, required String itemId});
  Future<void> clearCart(String userId);
}
