import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart.freezed.dart';

@freezed
class CartItem with _$CartItem {
  const CartItem._();

  const factory CartItem({
    required String id,
    required String productId,
    required String productName,
    required double price,
    double? comparePrice,
    String? imageUrl,
    required int quantity,
    @Default(true) bool inStock,
  }) = _CartItem;

  double get subtotal => price * quantity;
  bool get hasDiscount =>
      comparePrice != null && comparePrice! > price && comparePrice! > 0;
}

@freezed
class Cart with _$Cart {
  const Cart._();

  const factory Cart({
    @Default([]) List<CartItem> items,
  }) = _Cart;

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.subtotal);

  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;
}
