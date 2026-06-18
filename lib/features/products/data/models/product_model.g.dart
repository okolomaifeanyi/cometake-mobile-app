// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductCategoryModelImpl _$$ProductCategoryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ProductCategoryModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$$ProductCategoryModelImplToJson(
        _$ProductCategoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

_$ProductVendorModelImpl _$$ProductVendorModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ProductVendorModelImpl(
      id: json['id'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
    );

Map<String, dynamic> _$$ProductVendorModelImplToJson(
        _$ProductVendorModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
    };

_$ProductCoverModelImpl _$$ProductCoverModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ProductCoverModelImpl(
      media: json['media'] as String,
    );

Map<String, dynamic> _$$ProductCoverModelImplToJson(
        _$ProductCoverModelImpl instance) =>
    <String, dynamic>{
      'media': instance.media,
    };

_$ProductModelImpl _$$ProductModelImplFromJson(Map<String, dynamic> json) =>
    _$ProductModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble(),
      inStock: json['in_stock'] as bool? ?? true,
      unlist: json['unlist'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      sku: json['sku'] as String? ?? '',
      comparePrice: (json['compare_price'] as num?)?.toDouble(),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      isFeatured: json['is_featured'] as bool? ?? false,
      categoryId: json['category_id'] as String?,
      sellerId: json['seller_id'] as String?,
      category: json['category'] == null
          ? null
          : ProductCategoryModel.fromJson(
              json['category'] as Map<String, dynamic>),
      seller: json['seller'] == null
          ? null
          : ProductVendorModel.fromJson(json['seller'] as Map<String, dynamic>),
      cover: json['cover'] == null
          ? null
          : ProductCoverModel.fromJson(json['cover'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ProductModelImplToJson(_$ProductModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'description': instance.description,
      'weight': instance.weight,
      'in_stock': instance.inStock,
      'unlist': instance.unlist,
      'created_at': instance.createdAt.toIso8601String(),
      'sku': instance.sku,
      'compare_price': instance.comparePrice,
      'tags': instance.tags,
      'is_featured': instance.isFeatured,
      'category_id': instance.categoryId,
      'seller_id': instance.sellerId,
      'category': instance.category,
      'seller': instance.seller,
      'cover': instance.cover,
    };
