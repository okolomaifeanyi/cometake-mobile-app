import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/config/remote_config.dart';
import '../../domain/entities/cart.dart';

part 'cart_model.freezed.dart';
part 'cart_model.g.dart';

// Nested product snapshot from the join
@freezed
class CartProductModel with _$CartProductModel {
  const factory CartProductModel({
    required String id,
    required String name,
    required double price,
    @JsonKey(name: 'compare_price') double? comparePrice,
    @JsonKey(name: 'in_stock') @Default(true) bool inStock,
    CartCoverModel? cover,
  }) = _CartProductModel;

  factory CartProductModel.fromJson(Map<String, dynamic> json) =>
      _$CartProductModelFromJson(json);
}

@freezed
class CartCoverModel with _$CartCoverModel {
  const factory CartCoverModel({
    required String media,
  }) = _CartCoverModel;

  factory CartCoverModel.fromJson(Map<String, dynamic> json) =>
      _$CartCoverModelFromJson(json);
}

@freezed
class CartItemModel with _$CartItemModel {
  const factory CartItemModel({
    required String id,
    @JsonKey(name: 'product_id') required String productId,
    required int quantity,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    // Joined product data — aliased as "product" in the select string
    CartProductModel? product,
  }) = _CartItemModel;

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);
}

extension CartItemModelX on CartItemModel {
  CartItem toEntity() {
    final coverRaw = product?.cover?.media;
    final imageUrl = coverRaw != null ? _mediaToUrl(coverRaw) : null;
    return CartItem(
      id: id,
      productId: productId,
      productName: product?.name ?? '',
      price: product?.price ?? 0,
      comparePrice: product?.comparePrice,
      imageUrl: imageUrl,
      quantity: quantity,
      inStock: product?.inStock ?? true,
    );
  }

  static String _mediaToUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final withoutExt = path.replaceAll(RegExp(r'\.[^/.]+$'), '');
    final cloud = RemoteConfig.instance.cloudinaryCloudName.isNotEmpty
        ? RemoteConfig.instance.cloudinaryCloudName
        : 'dxi9khzro';
    return 'https://res.cloudinary.com/$cloud/image/upload/f_auto,q_auto,w_400,c_fill/$withoutExt';
  }
}
