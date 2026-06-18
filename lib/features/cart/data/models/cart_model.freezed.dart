// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CartProductModel _$CartProductModelFromJson(Map<String, dynamic> json) {
  return _CartProductModel.fromJson(json);
}

/// @nodoc
mixin _$CartProductModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'compare_price')
  double? get comparePrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'in_stock')
  bool get inStock => throw _privateConstructorUsedError;
  CartCoverModel? get cover => throw _privateConstructorUsedError;

  /// Serializes this CartProductModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CartProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartProductModelCopyWith<CartProductModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartProductModelCopyWith<$Res> {
  factory $CartProductModelCopyWith(
          CartProductModel value, $Res Function(CartProductModel) then) =
      _$CartProductModelCopyWithImpl<$Res, CartProductModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      double price,
      @JsonKey(name: 'compare_price') double? comparePrice,
      @JsonKey(name: 'in_stock') bool inStock,
      CartCoverModel? cover});

  $CartCoverModelCopyWith<$Res>? get cover;
}

/// @nodoc
class _$CartProductModelCopyWithImpl<$Res, $Val extends CartProductModel>
    implements $CartProductModelCopyWith<$Res> {
  _$CartProductModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? price = null,
    Object? comparePrice = freezed,
    Object? inStock = null,
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
      comparePrice: freezed == comparePrice
          ? _value.comparePrice
          : comparePrice // ignore: cast_nullable_to_non_nullable
              as double?,
      inStock: null == inStock
          ? _value.inStock
          : inStock // ignore: cast_nullable_to_non_nullable
              as bool,
      cover: freezed == cover
          ? _value.cover
          : cover // ignore: cast_nullable_to_non_nullable
              as CartCoverModel?,
    ) as $Val);
  }

  /// Create a copy of CartProductModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CartCoverModelCopyWith<$Res>? get cover {
    if (_value.cover == null) {
      return null;
    }

    return $CartCoverModelCopyWith<$Res>(_value.cover!, (value) {
      return _then(_value.copyWith(cover: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CartProductModelImplCopyWith<$Res>
    implements $CartProductModelCopyWith<$Res> {
  factory _$$CartProductModelImplCopyWith(_$CartProductModelImpl value,
          $Res Function(_$CartProductModelImpl) then) =
      __$$CartProductModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      double price,
      @JsonKey(name: 'compare_price') double? comparePrice,
      @JsonKey(name: 'in_stock') bool inStock,
      CartCoverModel? cover});

  @override
  $CartCoverModelCopyWith<$Res>? get cover;
}

/// @nodoc
class __$$CartProductModelImplCopyWithImpl<$Res>
    extends _$CartProductModelCopyWithImpl<$Res, _$CartProductModelImpl>
    implements _$$CartProductModelImplCopyWith<$Res> {
  __$$CartProductModelImplCopyWithImpl(_$CartProductModelImpl _value,
      $Res Function(_$CartProductModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CartProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? price = null,
    Object? comparePrice = freezed,
    Object? inStock = null,
    Object? cover = freezed,
  }) {
    return _then(_$CartProductModelImpl(
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
      comparePrice: freezed == comparePrice
          ? _value.comparePrice
          : comparePrice // ignore: cast_nullable_to_non_nullable
              as double?,
      inStock: null == inStock
          ? _value.inStock
          : inStock // ignore: cast_nullable_to_non_nullable
              as bool,
      cover: freezed == cover
          ? _value.cover
          : cover // ignore: cast_nullable_to_non_nullable
              as CartCoverModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CartProductModelImpl implements _CartProductModel {
  const _$CartProductModelImpl(
      {required this.id,
      required this.name,
      required this.price,
      @JsonKey(name: 'compare_price') this.comparePrice,
      @JsonKey(name: 'in_stock') this.inStock = true,
      this.cover});

  factory _$CartProductModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartProductModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double price;
  @override
  @JsonKey(name: 'compare_price')
  final double? comparePrice;
  @override
  @JsonKey(name: 'in_stock')
  final bool inStock;
  @override
  final CartCoverModel? cover;

  @override
  String toString() {
    return 'CartProductModel(id: $id, name: $name, price: $price, comparePrice: $comparePrice, inStock: $inStock, cover: $cover)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartProductModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.comparePrice, comparePrice) ||
                other.comparePrice == comparePrice) &&
            (identical(other.inStock, inStock) || other.inStock == inStock) &&
            (identical(other.cover, cover) || other.cover == cover));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, price, comparePrice, inStock, cover);

  /// Create a copy of CartProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartProductModelImplCopyWith<_$CartProductModelImpl> get copyWith =>
      __$$CartProductModelImplCopyWithImpl<_$CartProductModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartProductModelImplToJson(
      this,
    );
  }
}

abstract class _CartProductModel implements CartProductModel {
  const factory _CartProductModel(
      {required final String id,
      required final String name,
      required final double price,
      @JsonKey(name: 'compare_price') final double? comparePrice,
      @JsonKey(name: 'in_stock') final bool inStock,
      final CartCoverModel? cover}) = _$CartProductModelImpl;

  factory _CartProductModel.fromJson(Map<String, dynamic> json) =
      _$CartProductModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get price;
  @override
  @JsonKey(name: 'compare_price')
  double? get comparePrice;
  @override
  @JsonKey(name: 'in_stock')
  bool get inStock;
  @override
  CartCoverModel? get cover;

  /// Create a copy of CartProductModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartProductModelImplCopyWith<_$CartProductModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CartCoverModel _$CartCoverModelFromJson(Map<String, dynamic> json) {
  return _CartCoverModel.fromJson(json);
}

/// @nodoc
mixin _$CartCoverModel {
  String get media => throw _privateConstructorUsedError;

  /// Serializes this CartCoverModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CartCoverModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartCoverModelCopyWith<CartCoverModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartCoverModelCopyWith<$Res> {
  factory $CartCoverModelCopyWith(
          CartCoverModel value, $Res Function(CartCoverModel) then) =
      _$CartCoverModelCopyWithImpl<$Res, CartCoverModel>;
  @useResult
  $Res call({String media});
}

/// @nodoc
class _$CartCoverModelCopyWithImpl<$Res, $Val extends CartCoverModel>
    implements $CartCoverModelCopyWith<$Res> {
  _$CartCoverModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartCoverModel
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
abstract class _$$CartCoverModelImplCopyWith<$Res>
    implements $CartCoverModelCopyWith<$Res> {
  factory _$$CartCoverModelImplCopyWith(_$CartCoverModelImpl value,
          $Res Function(_$CartCoverModelImpl) then) =
      __$$CartCoverModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String media});
}

/// @nodoc
class __$$CartCoverModelImplCopyWithImpl<$Res>
    extends _$CartCoverModelCopyWithImpl<$Res, _$CartCoverModelImpl>
    implements _$$CartCoverModelImplCopyWith<$Res> {
  __$$CartCoverModelImplCopyWithImpl(
      _$CartCoverModelImpl _value, $Res Function(_$CartCoverModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CartCoverModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? media = null,
  }) {
    return _then(_$CartCoverModelImpl(
      media: null == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CartCoverModelImpl implements _CartCoverModel {
  const _$CartCoverModelImpl({required this.media});

  factory _$CartCoverModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartCoverModelImplFromJson(json);

  @override
  final String media;

  @override
  String toString() {
    return 'CartCoverModel(media: $media)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartCoverModelImpl &&
            (identical(other.media, media) || other.media == media));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, media);

  /// Create a copy of CartCoverModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartCoverModelImplCopyWith<_$CartCoverModelImpl> get copyWith =>
      __$$CartCoverModelImplCopyWithImpl<_$CartCoverModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartCoverModelImplToJson(
      this,
    );
  }
}

abstract class _CartCoverModel implements CartCoverModel {
  const factory _CartCoverModel({required final String media}) =
      _$CartCoverModelImpl;

  factory _CartCoverModel.fromJson(Map<String, dynamic> json) =
      _$CartCoverModelImpl.fromJson;

  @override
  String get media;

  /// Create a copy of CartCoverModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartCoverModelImplCopyWith<_$CartCoverModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) {
  return _CartItemModel.fromJson(json);
}

/// @nodoc
mixin _$CartItemModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_id')
  String get productId => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // Joined product data — aliased as "product" in the select string
  CartProductModel? get product => throw _privateConstructorUsedError;

  /// Serializes this CartItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartItemModelCopyWith<CartItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartItemModelCopyWith<$Res> {
  factory $CartItemModelCopyWith(
          CartItemModel value, $Res Function(CartItemModel) then) =
      _$CartItemModelCopyWithImpl<$Res, CartItemModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'product_id') String productId,
      int quantity,
      @JsonKey(name: 'created_at') DateTime createdAt,
      CartProductModel? product});

  $CartProductModelCopyWith<$Res>? get product;
}

/// @nodoc
class _$CartItemModelCopyWithImpl<$Res, $Val extends CartItemModel>
    implements $CartItemModelCopyWith<$Res> {
  _$CartItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? quantity = null,
    Object? createdAt = null,
    Object? product = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      product: freezed == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as CartProductModel?,
    ) as $Val);
  }

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CartProductModelCopyWith<$Res>? get product {
    if (_value.product == null) {
      return null;
    }

    return $CartProductModelCopyWith<$Res>(_value.product!, (value) {
      return _then(_value.copyWith(product: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CartItemModelImplCopyWith<$Res>
    implements $CartItemModelCopyWith<$Res> {
  factory _$$CartItemModelImplCopyWith(
          _$CartItemModelImpl value, $Res Function(_$CartItemModelImpl) then) =
      __$$CartItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'product_id') String productId,
      int quantity,
      @JsonKey(name: 'created_at') DateTime createdAt,
      CartProductModel? product});

  @override
  $CartProductModelCopyWith<$Res>? get product;
}

/// @nodoc
class __$$CartItemModelImplCopyWithImpl<$Res>
    extends _$CartItemModelCopyWithImpl<$Res, _$CartItemModelImpl>
    implements _$$CartItemModelImplCopyWith<$Res> {
  __$$CartItemModelImplCopyWithImpl(
      _$CartItemModelImpl _value, $Res Function(_$CartItemModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? quantity = null,
    Object? createdAt = null,
    Object? product = freezed,
  }) {
    return _then(_$CartItemModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      product: freezed == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as CartProductModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CartItemModelImpl implements _CartItemModel {
  const _$CartItemModelImpl(
      {required this.id,
      @JsonKey(name: 'product_id') required this.productId,
      required this.quantity,
      @JsonKey(name: 'created_at') required this.createdAt,
      this.product});

  factory _$CartItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartItemModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'product_id')
  final String productId;
  @override
  final int quantity;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
// Joined product data — aliased as "product" in the select string
  @override
  final CartProductModel? product;

  @override
  String toString() {
    return 'CartItemModel(id: $id, productId: $productId, quantity: $quantity, createdAt: $createdAt, product: $product)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.product, product) || other.product == product));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, productId, quantity, createdAt, product);

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartItemModelImplCopyWith<_$CartItemModelImpl> get copyWith =>
      __$$CartItemModelImplCopyWithImpl<_$CartItemModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartItemModelImplToJson(
      this,
    );
  }
}

abstract class _CartItemModel implements CartItemModel {
  const factory _CartItemModel(
      {required final String id,
      @JsonKey(name: 'product_id') required final String productId,
      required final int quantity,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      final CartProductModel? product}) = _$CartItemModelImpl;

  factory _CartItemModel.fromJson(Map<String, dynamic> json) =
      _$CartItemModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'product_id')
  String get productId;
  @override
  int get quantity;
  @override
  @JsonKey(name: 'created_at')
  DateTime
      get createdAt; // Joined product data — aliased as "product" in the select string
  @override
  CartProductModel? get product;

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartItemModelImplCopyWith<_$CartItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
