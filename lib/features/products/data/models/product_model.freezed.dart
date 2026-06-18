// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProductCategoryModel _$ProductCategoryModelFromJson(Map<String, dynamic> json) {
  return _ProductCategoryModel.fromJson(json);
}

/// @nodoc
mixin _$ProductCategoryModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this ProductCategoryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCategoryModelCopyWith<ProductCategoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCategoryModelCopyWith<$Res> {
  factory $ProductCategoryModelCopyWith(ProductCategoryModel value,
          $Res Function(ProductCategoryModel) then) =
      _$ProductCategoryModelCopyWithImpl<$Res, ProductCategoryModel>;
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class _$ProductCategoryModelCopyWithImpl<$Res,
        $Val extends ProductCategoryModel>
    implements $ProductCategoryModelCopyWith<$Res> {
  _$ProductCategoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductCategoryModel
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
abstract class _$$ProductCategoryModelImplCopyWith<$Res>
    implements $ProductCategoryModelCopyWith<$Res> {
  factory _$$ProductCategoryModelImplCopyWith(_$ProductCategoryModelImpl value,
          $Res Function(_$ProductCategoryModelImpl) then) =
      __$$ProductCategoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class __$$ProductCategoryModelImplCopyWithImpl<$Res>
    extends _$ProductCategoryModelCopyWithImpl<$Res, _$ProductCategoryModelImpl>
    implements _$$ProductCategoryModelImplCopyWith<$Res> {
  __$$ProductCategoryModelImplCopyWithImpl(_$ProductCategoryModelImpl _value,
      $Res Function(_$ProductCategoryModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_$ProductCategoryModelImpl(
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
@JsonSerializable()
class _$ProductCategoryModelImpl implements _ProductCategoryModel {
  const _$ProductCategoryModelImpl({required this.id, required this.name});

  factory _$ProductCategoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductCategoryModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;

  @override
  String toString() {
    return 'ProductCategoryModel(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductCategoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of ProductCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductCategoryModelImplCopyWith<_$ProductCategoryModelImpl>
      get copyWith =>
          __$$ProductCategoryModelImplCopyWithImpl<_$ProductCategoryModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductCategoryModelImplToJson(
      this,
    );
  }
}

abstract class _ProductCategoryModel implements ProductCategoryModel {
  const factory _ProductCategoryModel(
      {required final String id,
      required final String name}) = _$ProductCategoryModelImpl;

  factory _ProductCategoryModel.fromJson(Map<String, dynamic> json) =
      _$ProductCategoryModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;

  /// Create a copy of ProductCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductCategoryModelImplCopyWith<_$ProductCategoryModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ProductVendorModel _$ProductVendorModelFromJson(Map<String, dynamic> json) {
  return _ProductVendorModel.fromJson(json);
}

/// @nodoc
mixin _$ProductVendorModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String get lastName => throw _privateConstructorUsedError;

  /// Serializes this ProductVendorModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductVendorModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductVendorModelCopyWith<ProductVendorModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductVendorModelCopyWith<$Res> {
  factory $ProductVendorModelCopyWith(
          ProductVendorModel value, $Res Function(ProductVendorModel) then) =
      _$ProductVendorModelCopyWithImpl<$Res, ProductVendorModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName});
}

/// @nodoc
class _$ProductVendorModelCopyWithImpl<$Res, $Val extends ProductVendorModel>
    implements $ProductVendorModelCopyWith<$Res> {
  _$ProductVendorModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductVendorModel
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
abstract class _$$ProductVendorModelImplCopyWith<$Res>
    implements $ProductVendorModelCopyWith<$Res> {
  factory _$$ProductVendorModelImplCopyWith(_$ProductVendorModelImpl value,
          $Res Function(_$ProductVendorModelImpl) then) =
      __$$ProductVendorModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String lastName});
}

/// @nodoc
class __$$ProductVendorModelImplCopyWithImpl<$Res>
    extends _$ProductVendorModelCopyWithImpl<$Res, _$ProductVendorModelImpl>
    implements _$$ProductVendorModelImplCopyWith<$Res> {
  __$$ProductVendorModelImplCopyWithImpl(_$ProductVendorModelImpl _value,
      $Res Function(_$ProductVendorModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductVendorModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
  }) {
    return _then(_$ProductVendorModelImpl(
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
@JsonSerializable()
class _$ProductVendorModelImpl implements _ProductVendorModel {
  const _$ProductVendorModelImpl(
      {required this.id,
      @JsonKey(name: 'first_name') this.firstName = '',
      @JsonKey(name: 'last_name') this.lastName = ''});

  factory _$ProductVendorModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductVendorModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'first_name')
  final String firstName;
  @override
  @JsonKey(name: 'last_name')
  final String lastName;

  @override
  String toString() {
    return 'ProductVendorModel(id: $id, firstName: $firstName, lastName: $lastName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductVendorModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, firstName, lastName);

  /// Create a copy of ProductVendorModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductVendorModelImplCopyWith<_$ProductVendorModelImpl> get copyWith =>
      __$$ProductVendorModelImplCopyWithImpl<_$ProductVendorModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductVendorModelImplToJson(
      this,
    );
  }
}

abstract class _ProductVendorModel implements ProductVendorModel {
  const factory _ProductVendorModel(
          {required final String id,
          @JsonKey(name: 'first_name') final String firstName,
          @JsonKey(name: 'last_name') final String lastName}) =
      _$ProductVendorModelImpl;

  factory _ProductVendorModel.fromJson(Map<String, dynamic> json) =
      _$ProductVendorModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'first_name')
  String get firstName;
  @override
  @JsonKey(name: 'last_name')
  String get lastName;

  /// Create a copy of ProductVendorModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductVendorModelImplCopyWith<_$ProductVendorModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductCoverModel _$ProductCoverModelFromJson(Map<String, dynamic> json) {
  return _ProductCoverModel.fromJson(json);
}

/// @nodoc
mixin _$ProductCoverModel {
  String get media => throw _privateConstructorUsedError;

  /// Serializes this ProductCoverModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductCoverModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCoverModelCopyWith<ProductCoverModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCoverModelCopyWith<$Res> {
  factory $ProductCoverModelCopyWith(
          ProductCoverModel value, $Res Function(ProductCoverModel) then) =
      _$ProductCoverModelCopyWithImpl<$Res, ProductCoverModel>;
  @useResult
  $Res call({String media});
}

/// @nodoc
class _$ProductCoverModelCopyWithImpl<$Res, $Val extends ProductCoverModel>
    implements $ProductCoverModelCopyWith<$Res> {
  _$ProductCoverModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductCoverModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? media = null,
  }) {
    return _then(_value.copyWith(
      media: null == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductCoverModelImplCopyWith<$Res>
    implements $ProductCoverModelCopyWith<$Res> {
  factory _$$ProductCoverModelImplCopyWith(_$ProductCoverModelImpl value,
          $Res Function(_$ProductCoverModelImpl) then) =
      __$$ProductCoverModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String media});
}

/// @nodoc
class __$$ProductCoverModelImplCopyWithImpl<$Res>
    extends _$ProductCoverModelCopyWithImpl<$Res, _$ProductCoverModelImpl>
    implements _$$ProductCoverModelImplCopyWith<$Res> {
  __$$ProductCoverModelImplCopyWithImpl(_$ProductCoverModelImpl _value,
      $Res Function(_$ProductCoverModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductCoverModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? media = null,
  }) {
    return _then(_$ProductCoverModelImpl(
      media: null == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductCoverModelImpl implements _ProductCoverModel {
  const _$ProductCoverModelImpl({required this.media});

  factory _$ProductCoverModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductCoverModelImplFromJson(json);

  @override
  final String media;

  @override
  String toString() {
    return 'ProductCoverModel(media: $media)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductCoverModelImpl &&
            (identical(other.media, media) || other.media == media));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, media);

  /// Create a copy of ProductCoverModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductCoverModelImplCopyWith<_$ProductCoverModelImpl> get copyWith =>
      __$$ProductCoverModelImplCopyWithImpl<_$ProductCoverModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductCoverModelImplToJson(
      this,
    );
  }
}

abstract class _ProductCoverModel implements ProductCoverModel {
  const factory _ProductCoverModel({required final String media}) =
      _$ProductCoverModelImpl;

  factory _ProductCoverModel.fromJson(Map<String, dynamic> json) =
      _$ProductCoverModelImpl.fromJson;

  @override
  String get media;

  /// Create a copy of ProductCoverModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductCoverModelImplCopyWith<_$ProductCoverModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) {
  return _ProductModel.fromJson(json);
}

/// @nodoc
mixin _$ProductModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double? get weight => throw _privateConstructorUsedError;
  @JsonKey(name: 'in_stock')
  bool get inStock => throw _privateConstructorUsedError;
  bool get unlist => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get sku => throw _privateConstructorUsedError;
  @JsonKey(name: 'compare_price')
  double? get comparePrice => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_featured')
  bool get isFeatured => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String? get categoryId => throw _privateConstructorUsedError;
  @JsonKey(name: 'seller_id')
  String? get sellerId => throw _privateConstructorUsedError;
  ProductCategoryModel? get category => throw _privateConstructorUsedError;
  ProductVendorModel? get seller => throw _privateConstructorUsedError;
  ProductCoverModel? get cover => throw _privateConstructorUsedError;

  /// Serializes this ProductModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductModelCopyWith<ProductModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductModelCopyWith<$Res> {
  factory $ProductModelCopyWith(
          ProductModel value, $Res Function(ProductModel) then) =
      _$ProductModelCopyWithImpl<$Res, ProductModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      double price,
      String description,
      double? weight,
      @JsonKey(name: 'in_stock') bool inStock,
      bool unlist,
      @JsonKey(name: 'created_at') DateTime createdAt,
      String sku,
      @JsonKey(name: 'compare_price') double? comparePrice,
      List<String> tags,
      @JsonKey(name: 'is_featured') bool isFeatured,
      @JsonKey(name: 'category_id') String? categoryId,
      @JsonKey(name: 'seller_id') String? sellerId,
      ProductCategoryModel? category,
      ProductVendorModel? seller,
      ProductCoverModel? cover});

  $ProductCategoryModelCopyWith<$Res>? get category;
  $ProductVendorModelCopyWith<$Res>? get seller;
  $ProductCoverModelCopyWith<$Res>? get cover;
}

/// @nodoc
class _$ProductModelCopyWithImpl<$Res, $Val extends ProductModel>
    implements $ProductModelCopyWith<$Res> {
  _$ProductModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? price = null,
    Object? description = null,
    Object? weight = freezed,
    Object? inStock = null,
    Object? unlist = null,
    Object? createdAt = null,
    Object? sku = null,
    Object? comparePrice = freezed,
    Object? tags = null,
    Object? isFeatured = null,
    Object? categoryId = freezed,
    Object? sellerId = freezed,
    Object? category = freezed,
    Object? seller = freezed,
    Object? cover = freezed,
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
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      inStock: null == inStock
          ? _value.inStock
          : inStock // ignore: cast_nullable_to_non_nullable
              as bool,
      unlist: null == unlist
          ? _value.unlist
          : unlist // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      comparePrice: freezed == comparePrice
          ? _value.comparePrice
          : comparePrice // ignore: cast_nullable_to_non_nullable
              as double?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerId: freezed == sellerId
          ? _value.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ProductCategoryModel?,
      seller: freezed == seller
          ? _value.seller
          : seller // ignore: cast_nullable_to_non_nullable
              as ProductVendorModel?,
      cover: freezed == cover
          ? _value.cover
          : cover // ignore: cast_nullable_to_non_nullable
              as ProductCoverModel?,
    ) as $Val);
  }

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductCategoryModelCopyWith<$Res>? get category {
    if (_value.category == null) {
      return null;
    }

    return $ProductCategoryModelCopyWith<$Res>(_value.category!, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductVendorModelCopyWith<$Res>? get seller {
    if (_value.seller == null) {
      return null;
    }

    return $ProductVendorModelCopyWith<$Res>(_value.seller!, (value) {
      return _then(_value.copyWith(seller: value) as $Val);
    });
  }

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductCoverModelCopyWith<$Res>? get cover {
    if (_value.cover == null) {
      return null;
    }

    return $ProductCoverModelCopyWith<$Res>(_value.cover!, (value) {
      return _then(_value.copyWith(cover: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductModelImplCopyWith<$Res>
    implements $ProductModelCopyWith<$Res> {
  factory _$$ProductModelImplCopyWith(
          _$ProductModelImpl value, $Res Function(_$ProductModelImpl) then) =
      __$$ProductModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      double price,
      String description,
      double? weight,
      @JsonKey(name: 'in_stock') bool inStock,
      bool unlist,
      @JsonKey(name: 'created_at') DateTime createdAt,
      String sku,
      @JsonKey(name: 'compare_price') double? comparePrice,
      List<String> tags,
      @JsonKey(name: 'is_featured') bool isFeatured,
      @JsonKey(name: 'category_id') String? categoryId,
      @JsonKey(name: 'seller_id') String? sellerId,
      ProductCategoryModel? category,
      ProductVendorModel? seller,
      ProductCoverModel? cover});

  @override
  $ProductCategoryModelCopyWith<$Res>? get category;
  @override
  $ProductVendorModelCopyWith<$Res>? get seller;
  @override
  $ProductCoverModelCopyWith<$Res>? get cover;
}

/// @nodoc
class __$$ProductModelImplCopyWithImpl<$Res>
    extends _$ProductModelCopyWithImpl<$Res, _$ProductModelImpl>
    implements _$$ProductModelImplCopyWith<$Res> {
  __$$ProductModelImplCopyWithImpl(
      _$ProductModelImpl _value, $Res Function(_$ProductModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? price = null,
    Object? description = null,
    Object? weight = freezed,
    Object? inStock = null,
    Object? unlist = null,
    Object? createdAt = null,
    Object? sku = null,
    Object? comparePrice = freezed,
    Object? tags = null,
    Object? isFeatured = null,
    Object? categoryId = freezed,
    Object? sellerId = freezed,
    Object? category = freezed,
    Object? seller = freezed,
    Object? cover = freezed,
  }) {
    return _then(_$ProductModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      inStock: null == inStock
          ? _value.inStock
          : inStock // ignore: cast_nullable_to_non_nullable
              as bool,
      unlist: null == unlist
          ? _value.unlist
          : unlist // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      comparePrice: freezed == comparePrice
          ? _value.comparePrice
          : comparePrice // ignore: cast_nullable_to_non_nullable
              as double?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerId: freezed == sellerId
          ? _value.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ProductCategoryModel?,
      seller: freezed == seller
          ? _value.seller
          : seller // ignore: cast_nullable_to_non_nullable
              as ProductVendorModel?,
      cover: freezed == cover
          ? _value.cover
          : cover // ignore: cast_nullable_to_non_nullable
              as ProductCoverModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductModelImpl implements _ProductModel {
  const _$ProductModelImpl(
      {required this.id,
      required this.name,
      required this.price,
      this.description = '',
      this.weight,
      @JsonKey(name: 'in_stock') this.inStock = true,
      this.unlist = false,
      @JsonKey(name: 'created_at') required this.createdAt,
      this.sku = '',
      @JsonKey(name: 'compare_price') this.comparePrice,
      final List<String> tags = const [],
      @JsonKey(name: 'is_featured') this.isFeatured = false,
      @JsonKey(name: 'category_id') this.categoryId,
      @JsonKey(name: 'seller_id') this.sellerId,
      this.category,
      this.seller,
      this.cover})
      : _tags = tags;

  factory _$ProductModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double price;
  @override
  @JsonKey()
  final String description;
  @override
  final double? weight;
  @override
  @JsonKey(name: 'in_stock')
  final bool inStock;
  @override
  @JsonKey()
  final bool unlist;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey()
  final String sku;
  @override
  @JsonKey(name: 'compare_price')
  final double? comparePrice;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @override
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @override
  @JsonKey(name: 'seller_id')
  final String? sellerId;
  @override
  final ProductCategoryModel? category;
  @override
  final ProductVendorModel? seller;
  @override
  final ProductCoverModel? cover;

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price, description: $description, weight: $weight, inStock: $inStock, unlist: $unlist, createdAt: $createdAt, sku: $sku, comparePrice: $comparePrice, tags: $tags, isFeatured: $isFeatured, categoryId: $categoryId, sellerId: $sellerId, category: $category, seller: $seller, cover: $cover)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.inStock, inStock) || other.inStock == inStock) &&
            (identical(other.unlist, unlist) || other.unlist == unlist) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.comparePrice, comparePrice) ||
                other.comparePrice == comparePrice) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.sellerId, sellerId) ||
                other.sellerId == sellerId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.seller, seller) || other.seller == seller) &&
            (identical(other.cover, cover) || other.cover == cover));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      price,
      description,
      weight,
      inStock,
      unlist,
      createdAt,
      sku,
      comparePrice,
      const DeepCollectionEquality().hash(_tags),
      isFeatured,
      categoryId,
      sellerId,
      category,
      seller,
      cover);

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      __$$ProductModelImplCopyWithImpl<_$ProductModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductModelImplToJson(
      this,
    );
  }
}

abstract class _ProductModel implements ProductModel {
  const factory _ProductModel(
      {required final String id,
      required final String name,
      required final double price,
      final String description,
      final double? weight,
      @JsonKey(name: 'in_stock') final bool inStock,
      final bool unlist,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      final String sku,
      @JsonKey(name: 'compare_price') final double? comparePrice,
      final List<String> tags,
      @JsonKey(name: 'is_featured') final bool isFeatured,
      @JsonKey(name: 'category_id') final String? categoryId,
      @JsonKey(name: 'seller_id') final String? sellerId,
      final ProductCategoryModel? category,
      final ProductVendorModel? seller,
      final ProductCoverModel? cover}) = _$ProductModelImpl;

  factory _ProductModel.fromJson(Map<String, dynamic> json) =
      _$ProductModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get price;
  @override
  String get description;
  @override
  double? get weight;
  @override
  @JsonKey(name: 'in_stock')
  bool get inStock;
  @override
  bool get unlist;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  String get sku;
  @override
  @JsonKey(name: 'compare_price')
  double? get comparePrice;
  @override
  List<String> get tags;
  @override
  @JsonKey(name: 'is_featured')
  bool get isFeatured;
  @override
  @JsonKey(name: 'category_id')
  String? get categoryId;
  @override
  @JsonKey(name: 'seller_id')
  String? get sellerId;
  @override
  ProductCategoryModel? get category;
  @override
  ProductVendorModel? get seller;
  @override
  ProductCoverModel? get cover;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
