import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@freezed
class Product with _$Product {
  const Product._();

  const factory Product({
    required String id,
    required String name,
    required String description,
    required double price,
    double? comparePrice,
    required String sku,
    @Default([]) List<String> images,
    @Default(true) bool inStock,
    @Default(false) bool isUnlisted,
    String? categoryId,
    @Default(true) bool isActive,
    double? weight,
    @Default(false) bool isFeatured,
    @Default([]) List<String> tags,
    ProductCategory? category,
    String? vendorId,
    ProductVendor? vendor,
    required DateTime createdAt,
  }) = _Product;

  bool get hasDiscount =>
      comparePrice != null && comparePrice! > price && comparePrice! > 0;

  int get discountPercent => hasDiscount
      ? ((comparePrice! - price) / comparePrice! * 100).round()
      : 0;

  String? get thumbnailUrl => images.isNotEmpty ? images.first : null;
}

@freezed
class ProductCategory with _$ProductCategory {
  const factory ProductCategory({
    required String id,
    required String name,
  }) = _ProductCategory;
}

@freezed
class ProductVendor with _$ProductVendor {
  const ProductVendor._();

  const factory ProductVendor({
    required String id,
    required String firstName,
    required String lastName,
  }) = _ProductVendor;

  String get fullName => '$firstName $lastName'.trim();
}
