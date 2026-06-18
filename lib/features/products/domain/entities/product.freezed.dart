// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Product {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  double? get comparePrice => throw _privateConstructorUsedError;
  String get sku => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  bool get inStock => throw _privateConstructorUsedError;
  bool get isUnlisted => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  double? get weight => throw _privateConstructorUsedError;
  bool get isFeatured => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  ProductCategory? get category => throw _privateConstructorUsedError;
  String? get vendorId => throw _privateConstructorUsedError;
  ProductVendor? get vendor => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCopyWith<Product> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCopyWith<$Res> {
  factory $ProductCopyWith(Product value, $Res Function(Product) then) =
      _$ProductCopyWithImpl<$Res, Product>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      double price,
      double? comparePrice,
      String sku,
      List<String> images,
      bool inStock,
      bool isUnlisted,
      String? categoryId,
      bool isActive,
      double? weight,
      bool isFeatured,
      List<String> tags,
      ProductCategory? category,
      String? vendorId,
      ProductVendor? vendor,
      DateTime createdAt});

  $ProductCategoryCopyWith<$Res>? get category;
  $ProductVendorCopyWith<$Res>? get vendor;
}

/// @nodoc
class _$ProductCopyWithImpl<$Res, $Val extends Product>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? price = null,
    Object? comparePrice = freezed,
    Object? sku = null,
    Object? images = null,
    Object? inStock = null,
    Object? isUnlisted = null,
    Object? categoryId = freezed,
    Object? isActive = null,
    Object? weight = freezed,
    Object? isFeatured = null,
    Object? tags = null,
    Object? category = freezed,
    Object? vendorId = freezed,
    Object? vendor = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      comparePrice: freezed == comparePrice
          ? _value.comparePrice
          : comparePrice // ignore: cast_nullable_to_non_nullable
              as double?,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      inStock: null == inStock
          ? _value.inStock
          : inStock // ignore: cast_nullable_to_non_nullable
              as bool,
      isUnlisted: null == isUnlisted
          ? _value.isUnlisted
          : isUnlisted // ignore: cast_nullable_to_non_nullable
              as bool,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ProductCategory?,
      vendorId: freezed == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as String?,
      vendor: freezed == vendor
          ? _value.vendor
          : vendor // ignore: cast_nullable_to_non_nullable
              as ProductVendor?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductCategoryCopyWith<$Res>? get category {
    if (_value.category == null) {
      return null;
    }

    return $ProductCategoryCopyWith<$Res>(_value.category!, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductVendorCopyWith<$Res>? get vendor {
    if (_value.vendor == null) {
      return null;
    }

    return $ProductVendorCopyWith<$Res>(_value.vendor!, (value) {
      return _then(_value.copyWith(vendor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductImplCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$$ProductImplCopyWith(
          _$ProductImpl value, $Res Function(_$ProductImpl) then) =
      __$$ProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      double price,
      double? comparePrice,
      String sku,
      List<String> images,
      bool inStock,
      bool isUnlisted,
      String? categoryId,
      bool isActive,
      double? weight,
      bool isFeatured,
      List<String> tags,
      ProductCategory? category,
      String? vendorId,
      ProductVendor? vendor,
      DateTime createdAt});

  @override
  $ProductCategoryCopyWith<$Res>? get category;
  @override
  $ProductVendorCopyWith<$Res>? get vendor;
}

/// @nodoc
class __$$ProductImplCopyWithImpl<$Res>
    extends _$ProductCopyWithImpl<$Res, _$ProductImpl>
    implements _$$ProductImplCopyWith<$Res> {
  __$$ProductImplCopyWithImpl(
      _$ProductImpl _value, $Res Function(_$ProductImpl) _then)
      : super(_value, _then);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? price = null,
    Object? comparePrice = freezed,
    Object? sku = null,
    Object? images = null,
    Object? inStock = null,
    Object? isUnlisted = null,
    Object? categoryId = freezed,
    Object? isActive = null,
    Object? weight = freezed,
    Object? isFeatured = null,
    Object? tags = null,
    Object? category = freezed,
    Object? vendorId = freezed,
    Object? vendor = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$ProductImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      comparePrice: freezed == comparePrice
          ? _value.comparePrice
          : comparePrice // ignore: cast_nullable_to_non_nullable
              as double?,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      inStock: null == inStock
          ? _value.inStock
          : inStock // ignore: cast_nullable_to_non_nullable
              as bool,
      isUnlisted: null == isUnlisted
          ? _value.isUnlisted
          : isUnlisted // ignore: cast_nullable_to_non_nullable
              as bool,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ProductCategory?,
      vendorId: freezed == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as String?,
      vendor: freezed == vendor
          ? _value.vendor
          : vendor // ignore: cast_nullable_to_non_nullable
              as ProductVendor?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$ProductImpl extends _Product {
  const _$ProductImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.price,
      this.comparePrice,
      required this.sku,
      final List<String> images = const [],
      this.inStock = true,
      this.isUnlisted = false,
      this.categoryId,
      this.isActive = true,
      this.weight,
      this.isFeatured = false,
      final List<String> tags = const [],
      this.category,
      this.vendorId,
      this.vendor,
      required this.createdAt})
      : _images = images,
        _tags = tags,
        super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final double price;
  @override
  final double? comparePrice;
  @override
  final String sku;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  @JsonKey()
  final bool inStock;
  @override
  @JsonKey()
  final bool isUnlisted;
  @override
  final String? categoryId;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final double? weight;
  @override
  @JsonKey()
  final bool isFeatured;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final ProductCategory? category;
  @override
  final String? vendorId;
  @override
  final ProductVendor? vendor;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, description: $description, price: $price, comparePrice: $comparePrice, sku: $sku, images: $images, inStock: $inStock, isUnlisted: $isUnlisted, categoryId: $categoryId, isActive: $isActive, weight: $weight, isFeatured: $isFeatured, tags: $tags, category: $category, vendorId: $vendorId, vendor: $vendor, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.comparePrice, comparePrice) ||
                other.comparePrice == comparePrice) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.inStock, inStock) || other.inStock == inStock) &&
            (identical(other.isUnlisted, isUnlisted) ||
                other.isUnlisted == isUnlisted) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.vendor, vendor) || other.vendor == vendor) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      price,
      comparePrice,
      sku,
      const DeepCollectionEquality().hash(_images),
      inStock,
      isUnlisted,
      categoryId,
      isActive,
      weight,
      isFeatured,
      const DeepCollectionEquality().hash(_tags),
      category,
      vendorId,
      vendor,
      createdAt);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      __$$ProductImplCopyWithImpl<_$ProductImpl>(this, _$identity);
}

abstract class _Product extends Product {
  const factory _Product(
      {required final String id,
      required final String name,
      required final String description,
      required final double price,
      final double? comparePrice,
      required final String sku,
      final List<String> images,
      final bool inStock,
      final bool isUnlisted,
      final String? categoryId,
      final bool isActive,
      final double? weight,
      final bool isFeatured,
      final List<String> tags,
      final ProductCategory? category,
      final String? vendorId,
      final ProductVendor? vendor,
      required final DateTime createdAt}) = _$ProductImpl;
  const _Product._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  double get price;
  @override
  double? get comparePrice;
  @override
  String get sku;
  @override
  List<String> get images;
  @override
  bool get inStock;
  @override
  bool get isUnlisted;
  @override
  String? get categoryId;
  @override
  bool get isActive;
  @override
  double? get weight;
  @override
  bool get isFeatured;
  @override
  List<String> get tags;
  @override
  ProductCategory? get category;
  @override
  String? get vendorId;
  @override
  ProductVendor? get vendor;
  @override
  DateTime get createdAt;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ProductCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Create a copy of ProductCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCategoryCopyWith<ProductCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCategoryCopyWith<$Res> {
  factory $ProductCategoryCopyWith(
          ProductCategory value, $Res Function(ProductCategory) then) =
      _$ProductCategoryCopyWithImpl<$Res, ProductCategory>;
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class _$ProductCategoryCopyWithImpl<$Res, $Val extends ProductCategory>
    implements $ProductCategoryCopyWith<$Res> {
  _$ProductCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductCategoryImplCopyWith<$Res>
    implements $ProductCategoryCopyWith<$Res> {
  factory _$$ProductCategoryImplCopyWith(_$ProductCategoryImpl value,
          $Res Function(_$ProductCategoryImpl) then) =
      __$$ProductCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class __$$ProductCategoryImplCopyWithImpl<$Res>
    extends _$ProductCategoryCopyWithImpl<$Res, _$ProductCategoryImpl>
    implements _$$ProductCategoryImplCopyWith<$Res> {
  __$$ProductCategoryImplCopyWithImpl(
      _$ProductCategoryImpl _value, $Res Function(_$ProductCategoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_$ProductCategoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ProductCategoryImpl implements _ProductCategory {
  const _$ProductCategoryImpl({required this.id, required this.name});

  @override
  final String id;
  @override
  final String name;

  @override
  String toString() {
    return 'ProductCategory(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of ProductCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductCategoryImplCopyWith<_$ProductCategoryImpl> get copyWith =>
      __$$ProductCategoryImplCopyWithImpl<_$ProductCategoryImpl>(
          this, _$identity);
}

abstract class _ProductCategory implements ProductCategory {
  const factory _ProductCategory(
      {required final String id,
      required final String name}) = _$ProductCategoryImpl;

  @override
  String get id;
  @override
  String get name;

  /// Create a copy of ProductCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductCategoryImplCopyWith<_$ProductCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ProductVendor {
  String get id => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;

  /// Create a copy of ProductVendor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductVendorCopyWith<ProductVendor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductVendorCopyWith<$Res> {
  factory $ProductVendorCopyWith(
          ProductVendor value, $Res Function(ProductVendor) then) =
      _$ProductVendorCopyWithImpl<$Res, ProductVendor>;
  @useResult
  $Res call({String id, String firstName, String lastName});
}

/// @nodoc
class _$ProductVendorCopyWithImpl<$Res, $Val extends ProductVendor>
    implements $ProductVendorCopyWith<$Res> {
  _$ProductVendorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductVendor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductVendorImplCopyWith<$Res>
    implements $ProductVendorCopyWith<$Res> {
  factory _$$ProductVendorImplCopyWith(
          _$ProductVendorImpl value, $Res Function(_$ProductVendorImpl) then) =
      __$$ProductVendorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String firstName, String lastName});
}

/// @nodoc
class __$$ProductVendorImplCopyWithImpl<$Res>
    extends _$ProductVendorCopyWithImpl<$Res, _$ProductVendorImpl>
    implements _$$ProductVendorImplCopyWith<$Res> {
  __$$ProductVendorImplCopyWithImpl(
      _$ProductVendorImpl _value, $Res Function(_$ProductVendorImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductVendor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
  }) {
    return _then(_$ProductVendorImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ProductVendorImpl extends _ProductVendor {
  const _$ProductVendorImpl(
      {required this.id, required this.firstName, required this.lastName})
      : super._();

  @override
  final String id;
  @override
  final String firstName;
  @override
  final String lastName;

  @override
  String toString() {
    return 'ProductVendor(id: $id, firstName: $firstName, lastName: $lastName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductVendorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, firstName, lastName);

  /// Create a copy of ProductVendor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductVendorImplCopyWith<_$ProductVendorImpl> get copyWith =>
      __$$ProductVendorImplCopyWithImpl<_$ProductVendorImpl>(this, _$identity);
}

abstract class _ProductVendor extends ProductVendor {
  const factory _ProductVendor(
      {required final String id,
      required final String firstName,
      required final String lastName}) = _$ProductVendorImpl;
  const _ProductVendor._() : super._();

  @override
  String get id;
  @override
  String get firstName;
  @override
  String get lastName;

  /// Create a copy of ProductVendor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductVendorImplCopyWith<_$ProductVendorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
