import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/config/env.dart';
import '../../domain/entities/product.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

// ─── Nested models ─────────────────────────────────────────────────────────

@freezed
class ProductCategoryModel with _$ProductCategoryModel {
  const factory ProductCategoryModel({
    required String id,
    required String name,
  }) = _ProductCategoryModel;

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoryModelFromJson(json);
}

@freezed
class ProductVendorModel with _$ProductVendorModel {
  const factory ProductVendorModel({
    required String id,
    @JsonKey(name: 'first_name') @Default('') String firstName,
    @JsonKey(name: 'last_name') @Default('') String lastName,
  }) = _ProductVendorModel;

  factory ProductVendorModel.fromJson(Map<String, dynamic> json) =>
      _$ProductVendorModelFromJson(json);
}

@freezed
class ProductCoverModel with _$ProductCoverModel {
  const factory ProductCoverModel({
    required String media,
  }) = _ProductCoverModel;

  factory ProductCoverModel.fromJson(Map<String, dynamic> json) =>
      _$ProductCoverModelFromJson(json);
}

// ─── Main model ─────────────────────────────────────────────────────────────

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required double price,
    @Default('') String description,
    double? weight,
    @JsonKey(name: 'in_stock') @Default(true) bool inStock,
    @Default(false) bool unlist,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default('') String sku,
    @JsonKey(name: 'compare_price') double? comparePrice,
    @Default([]) List<String> tags,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'seller_id') String? sellerId,
    ProductCategoryModel? category,
    ProductVendorModel? seller,
    ProductCoverModel? cover,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

extension ProductModelX on ProductModel {
  Product toEntity() {
    final coverRaw = cover?.media;
    final images = coverRaw != null ? [_mediaToUrl(coverRaw)] : <String>[];

    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      comparePrice: comparePrice,
      sku: sku.isEmpty ? id : sku,
      images: images,
      inStock: inStock,
      isUnlisted: unlist,
      categoryId: categoryId,
      isActive: !unlist,
      weight: weight,
      isFeatured: isFeatured,
      tags: tags,
      category: category != null
          ? ProductCategory(id: category!.id, name: category!.name)
          : null,
      vendorId: sellerId,
      vendor: seller != null
          ? ProductVendor(
              id: seller!.id,
              firstName: seller!.firstName,
              lastName: seller!.lastName,
            )
          : null,
      createdAt: createdAt,
    );
  }

  static String _mediaToUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    // Legacy storage path — strip extension, prepend Cloudinary base
    final withoutExt = path.replaceAll(RegExp(r'\.[^/.]+$'), '');
    final cloud = Env.cloudinaryCloudName.isNotEmpty
        ? Env.cloudinaryCloudName
        : 'dxi9khzro';
    return 'https://res.cloudinary.com/$cloud/image/upload/f_auto,q_auto,w_1200,c_limit/$withoutExt';
  }
}
