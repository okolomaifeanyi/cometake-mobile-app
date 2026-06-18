// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CartProductModelImpl _$$CartProductModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CartProductModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      comparePrice: (json['compare_price'] as num?)?.toDouble(),
      inStock: json['in_stock'] as bool? ?? true,
      cover: json['cover'] == null
          ? null
          : CartCoverModel.fromJson(json['cover'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CartProductModelImplToJson(
        _$CartProductModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'compare_price': instance.comparePrice,
      'in_stock': instance.inStock,
      'cover': instance.cover,
    };

_$CartCoverModelImpl _$$CartCoverModelImplFromJson(Map<String, dynamic> json) =>
    _$CartCoverModelImpl(
      media: json['media'] as String,
    );

Map<String, dynamic> _$$CartCoverModelImplToJson(
        _$CartCoverModelImpl instance) =>
    <String, dynamic>{
      'media': instance.media,
    };

_$CartItemModelImpl _$$CartItemModelImplFromJson(Map<String, dynamic> json) =>
    _$CartItemModelImpl(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      product: json['product'] == null
          ? null
          : CartProductModel.fromJson(json['product'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CartItemModelImplToJson(_$CartItemModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'quantity': instance.quantity,
      'created_at': instance.createdAt.toIso8601String(),
      'product': instance.product,
    };
