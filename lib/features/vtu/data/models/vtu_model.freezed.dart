// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vtu_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VtuServiceModel _$VtuServiceModelFromJson(Map<String, dynamic> json) {
  return _VtuServiceModel.fromJson(json);
}

/// @nodoc
mixin _$VtuServiceModel {
  @JsonKey(name: 'serviceID')
  String get serviceId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;

  /// Serializes this VtuServiceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VtuServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VtuServiceModelCopyWith<VtuServiceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VtuServiceModelCopyWith<$Res> {
  factory $VtuServiceModelCopyWith(
          VtuServiceModel value, $Res Function(VtuServiceModel) then) =
      _$VtuServiceModelCopyWithImpl<$Res, VtuServiceModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'serviceID') String serviceId,
      String name,
      String? image});
}

/// @nodoc
class _$VtuServiceModelCopyWithImpl<$Res, $Val extends VtuServiceModel>
    implements $VtuServiceModelCopyWith<$Res> {
  _$VtuServiceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VtuServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceId = null,
    Object? name = null,
    Object? image = freezed,
  }) {
    return _then(_value.copyWith(
      serviceId: null == serviceId
          ? _value.serviceId
          : serviceId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VtuServiceModelImplCopyWith<$Res>
    implements $VtuServiceModelCopyWith<$Res> {
  factory _$$VtuServiceModelImplCopyWith(_$VtuServiceModelImpl value,
          $Res Function(_$VtuServiceModelImpl) then) =
      __$$VtuServiceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'serviceID') String serviceId,
      String name,
      String? image});
}

/// @nodoc
class __$$VtuServiceModelImplCopyWithImpl<$Res>
    extends _$VtuServiceModelCopyWithImpl<$Res, _$VtuServiceModelImpl>
    implements _$$VtuServiceModelImplCopyWith<$Res> {
  __$$VtuServiceModelImplCopyWithImpl(
      _$VtuServiceModelImpl _value, $Res Function(_$VtuServiceModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of VtuServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceId = null,
    Object? name = null,
    Object? image = freezed,
  }) {
    return _then(_$VtuServiceModelImpl(
      serviceId: null == serviceId
          ? _value.serviceId
          : serviceId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VtuServiceModelImpl implements _VtuServiceModel {
  const _$VtuServiceModelImpl(
      {@JsonKey(name: 'serviceID') required this.serviceId,
      required this.name,
      this.image});

  factory _$VtuServiceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VtuServiceModelImplFromJson(json);

  @override
  @JsonKey(name: 'serviceID')
  final String serviceId;
  @override
  final String name;
  @override
  final String? image;

  @override
  String toString() {
    return 'VtuServiceModel(serviceId: $serviceId, name: $name, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VtuServiceModelImpl &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.image, image) || other.image == image));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, serviceId, name, image);

  /// Create a copy of VtuServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VtuServiceModelImplCopyWith<_$VtuServiceModelImpl> get copyWith =>
      __$$VtuServiceModelImplCopyWithImpl<_$VtuServiceModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VtuServiceModelImplToJson(
      this,
    );
  }
}

abstract class _VtuServiceModel implements VtuServiceModel {
  const factory _VtuServiceModel(
      {@JsonKey(name: 'serviceID') required final String serviceId,
      required final String name,
      final String? image}) = _$VtuServiceModelImpl;

  factory _VtuServiceModel.fromJson(Map<String, dynamic> json) =
      _$VtuServiceModelImpl.fromJson;

  @override
  @JsonKey(name: 'serviceID')
  String get serviceId;
  @override
  String get name;
  @override
  String? get image;

  /// Create a copy of VtuServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VtuServiceModelImplCopyWith<_$VtuServiceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VtuVariationModel _$VtuVariationModelFromJson(Map<String, dynamic> json) {
  return _VtuVariationModel.fromJson(json);
}

/// @nodoc
mixin _$VtuVariationModel {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'variation_code')
  String get variationCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'variation_amount')
  String get variationAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'fixedPrice')
  String? get fixedPrice => throw _privateConstructorUsedError;

  /// Serializes this VtuVariationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VtuVariationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VtuVariationModelCopyWith<VtuVariationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VtuVariationModelCopyWith<$Res> {
  factory $VtuVariationModelCopyWith(
          VtuVariationModel value, $Res Function(VtuVariationModel) then) =
      _$VtuVariationModelCopyWithImpl<$Res, VtuVariationModel>;
  @useResult
  $Res call(
      {String name,
      @JsonKey(name: 'variation_code') String variationCode,
      @JsonKey(name: 'variation_amount') String variationAmount,
      @JsonKey(name: 'fixedPrice') String? fixedPrice});
}

/// @nodoc
class _$VtuVariationModelCopyWithImpl<$Res, $Val extends VtuVariationModel>
    implements $VtuVariationModelCopyWith<$Res> {
  _$VtuVariationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VtuVariationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? variationCode = null,
    Object? variationAmount = null,
    Object? fixedPrice = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      variationCode: null == variationCode
          ? _value.variationCode
          : variationCode // ignore: cast_nullable_to_non_nullable
              as String,
      variationAmount: null == variationAmount
          ? _value.variationAmount
          : variationAmount // ignore: cast_nullable_to_non_nullable
              as String,
      fixedPrice: freezed == fixedPrice
          ? _value.fixedPrice
          : fixedPrice // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VtuVariationModelImplCopyWith<$Res>
    implements $VtuVariationModelCopyWith<$Res> {
  factory _$$VtuVariationModelImplCopyWith(_$VtuVariationModelImpl value,
          $Res Function(_$VtuVariationModelImpl) then) =
      __$$VtuVariationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      @JsonKey(name: 'variation_code') String variationCode,
      @JsonKey(name: 'variation_amount') String variationAmount,
      @JsonKey(name: 'fixedPrice') String? fixedPrice});
}

/// @nodoc
class __$$VtuVariationModelImplCopyWithImpl<$Res>
    extends _$VtuVariationModelCopyWithImpl<$Res, _$VtuVariationModelImpl>
    implements _$$VtuVariationModelImplCopyWith<$Res> {
  __$$VtuVariationModelImplCopyWithImpl(_$VtuVariationModelImpl _value,
      $Res Function(_$VtuVariationModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of VtuVariationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? variationCode = null,
    Object? variationAmount = null,
    Object? fixedPrice = freezed,
  }) {
    return _then(_$VtuVariationModelImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      variationCode: null == variationCode
          ? _value.variationCode
          : variationCode // ignore: cast_nullable_to_non_nullable
              as String,
      variationAmount: null == variationAmount
          ? _value.variationAmount
          : variationAmount // ignore: cast_nullable_to_non_nullable
              as String,
      fixedPrice: freezed == fixedPrice
          ? _value.fixedPrice
          : fixedPrice // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VtuVariationModelImpl implements _VtuVariationModel {
  const _$VtuVariationModelImpl(
      {required this.name,
      @JsonKey(name: 'variation_code') required this.variationCode,
      @JsonKey(name: 'variation_amount') required this.variationAmount,
      @JsonKey(name: 'fixedPrice') this.fixedPrice});

  factory _$VtuVariationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VtuVariationModelImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(name: 'variation_code')
  final String variationCode;
  @override
  @JsonKey(name: 'variation_amount')
  final String variationAmount;
  @override
  @JsonKey(name: 'fixedPrice')
  final String? fixedPrice;

  @override
  String toString() {
    return 'VtuVariationModel(name: $name, variationCode: $variationCode, variationAmount: $variationAmount, fixedPrice: $fixedPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VtuVariationModelImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.variationCode, variationCode) ||
                other.variationCode == variationCode) &&
            (identical(other.variationAmount, variationAmount) ||
                other.variationAmount == variationAmount) &&
            (identical(other.fixedPrice, fixedPrice) ||
                other.fixedPrice == fixedPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, variationCode, variationAmount, fixedPrice);

  /// Create a copy of VtuVariationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VtuVariationModelImplCopyWith<_$VtuVariationModelImpl> get copyWith =>
      __$$VtuVariationModelImplCopyWithImpl<_$VtuVariationModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VtuVariationModelImplToJson(
      this,
    );
  }
}

abstract class _VtuVariationModel implements VtuVariationModel {
  const factory _VtuVariationModel(
      {required final String name,
      @JsonKey(name: 'variation_code') required final String variationCode,
      @JsonKey(name: 'variation_amount') required final String variationAmount,
      @JsonKey(name: 'fixedPrice')
      final String? fixedPrice}) = _$VtuVariationModelImpl;

  factory _VtuVariationModel.fromJson(Map<String, dynamic> json) =
      _$VtuVariationModelImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(name: 'variation_code')
  String get variationCode;
  @override
  @JsonKey(name: 'variation_amount')
  String get variationAmount;
  @override
  @JsonKey(name: 'fixedPrice')
  String? get fixedPrice;

  /// Create a copy of VtuVariationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VtuVariationModelImplCopyWith<_$VtuVariationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VtuMerchantModel _$VtuMerchantModelFromJson(Map<String, dynamic> json) {
  return _VtuMerchantModel.fromJson(json);
}

/// @nodoc
mixin _$VtuMerchantModel {
  @JsonKey(name: 'Customer_Name')
  String? get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'Address')
  String? get address => throw _privateConstructorUsedError;
  @JsonKey(name: 'Meter_Number')
  String? get meterNumber => throw _privateConstructorUsedError;

  /// Serializes this VtuMerchantModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VtuMerchantModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VtuMerchantModelCopyWith<VtuMerchantModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VtuMerchantModelCopyWith<$Res> {
  factory $VtuMerchantModelCopyWith(
          VtuMerchantModel value, $Res Function(VtuMerchantModel) then) =
      _$VtuMerchantModelCopyWithImpl<$Res, VtuMerchantModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Customer_Name') String? customerName,
      @JsonKey(name: 'Address') String? address,
      @JsonKey(name: 'Meter_Number') String? meterNumber});
}

/// @nodoc
class _$VtuMerchantModelCopyWithImpl<$Res, $Val extends VtuMerchantModel>
    implements $VtuMerchantModelCopyWith<$Res> {
  _$VtuMerchantModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VtuMerchantModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerName = freezed,
    Object? address = freezed,
    Object? meterNumber = freezed,
  }) {
    return _then(_value.copyWith(
      customerName: freezed == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      meterNumber: freezed == meterNumber
          ? _value.meterNumber
          : meterNumber // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VtuMerchantModelImplCopyWith<$Res>
    implements $VtuMerchantModelCopyWith<$Res> {
  factory _$$VtuMerchantModelImplCopyWith(_$VtuMerchantModelImpl value,
          $Res Function(_$VtuMerchantModelImpl) then) =
      __$$VtuMerchantModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Customer_Name') String? customerName,
      @JsonKey(name: 'Address') String? address,
      @JsonKey(name: 'Meter_Number') String? meterNumber});
}

/// @nodoc
class __$$VtuMerchantModelImplCopyWithImpl<$Res>
    extends _$VtuMerchantModelCopyWithImpl<$Res, _$VtuMerchantModelImpl>
    implements _$$VtuMerchantModelImplCopyWith<$Res> {
  __$$VtuMerchantModelImplCopyWithImpl(_$VtuMerchantModelImpl _value,
      $Res Function(_$VtuMerchantModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of VtuMerchantModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerName = freezed,
    Object? address = freezed,
    Object? meterNumber = freezed,
  }) {
    return _then(_$VtuMerchantModelImpl(
      customerName: freezed == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      meterNumber: freezed == meterNumber
          ? _value.meterNumber
          : meterNumber // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VtuMerchantModelImpl implements _VtuMerchantModel {
  const _$VtuMerchantModelImpl(
      {@JsonKey(name: 'Customer_Name') this.customerName,
      @JsonKey(name: 'Address') this.address,
      @JsonKey(name: 'Meter_Number') this.meterNumber});

  factory _$VtuMerchantModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VtuMerchantModelImplFromJson(json);

  @override
  @JsonKey(name: 'Customer_Name')
  final String? customerName;
  @override
  @JsonKey(name: 'Address')
  final String? address;
  @override
  @JsonKey(name: 'Meter_Number')
  final String? meterNumber;

  @override
  String toString() {
    return 'VtuMerchantModel(customerName: $customerName, address: $address, meterNumber: $meterNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VtuMerchantModelImpl &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.meterNumber, meterNumber) ||
                other.meterNumber == meterNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, customerName, address, meterNumber);

  /// Create a copy of VtuMerchantModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VtuMerchantModelImplCopyWith<_$VtuMerchantModelImpl> get copyWith =>
      __$$VtuMerchantModelImplCopyWithImpl<_$VtuMerchantModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VtuMerchantModelImplToJson(
      this,
    );
  }
}

abstract class _VtuMerchantModel implements VtuMerchantModel {
  const factory _VtuMerchantModel(
          {@JsonKey(name: 'Customer_Name') final String? customerName,
          @JsonKey(name: 'Address') final String? address,
          @JsonKey(name: 'Meter_Number') final String? meterNumber}) =
      _$VtuMerchantModelImpl;

  factory _VtuMerchantModel.fromJson(Map<String, dynamic> json) =
      _$VtuMerchantModelImpl.fromJson;

  @override
  @JsonKey(name: 'Customer_Name')
  String? get customerName;
  @override
  @JsonKey(name: 'Address')
  String? get address;
  @override
  @JsonKey(name: 'Meter_Number')
  String? get meterNumber;

  /// Create a copy of VtuMerchantModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VtuMerchantModelImplCopyWith<_$VtuMerchantModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VtuTransactionModel _$VtuTransactionModelFromJson(Map<String, dynamic> json) {
  return _VtuTransactionModel.fromJson(json);
}

/// @nodoc
mixin _$VtuTransactionModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'serviceType')
  String get serviceType => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get recipient => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get reference => throw _privateConstructorUsedError;
  @JsonKey(name: 'createdAt')
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this VtuTransactionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VtuTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VtuTransactionModelCopyWith<VtuTransactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VtuTransactionModelCopyWith<$Res> {
  factory $VtuTransactionModelCopyWith(
          VtuTransactionModel value, $Res Function(VtuTransactionModel) then) =
      _$VtuTransactionModelCopyWithImpl<$Res, VtuTransactionModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'serviceType') String serviceType,
      String provider,
      double amount,
      String recipient,
      String status,
      String reference,
      @JsonKey(name: 'createdAt') String createdAt});
}

/// @nodoc
class _$VtuTransactionModelCopyWithImpl<$Res, $Val extends VtuTransactionModel>
    implements $VtuTransactionModelCopyWith<$Res> {
  _$VtuTransactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VtuTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serviceType = null,
    Object? provider = null,
    Object? amount = null,
    Object? recipient = null,
    Object? status = null,
    Object? reference = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      serviceType: null == serviceType
          ? _value.serviceType
          : serviceType // ignore: cast_nullable_to_non_nullable
              as String,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      recipient: null == recipient
          ? _value.recipient
          : recipient // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      reference: null == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VtuTransactionModelImplCopyWith<$Res>
    implements $VtuTransactionModelCopyWith<$Res> {
  factory _$$VtuTransactionModelImplCopyWith(_$VtuTransactionModelImpl value,
          $Res Function(_$VtuTransactionModelImpl) then) =
      __$$VtuTransactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'serviceType') String serviceType,
      String provider,
      double amount,
      String recipient,
      String status,
      String reference,
      @JsonKey(name: 'createdAt') String createdAt});
}

/// @nodoc
class __$$VtuTransactionModelImplCopyWithImpl<$Res>
    extends _$VtuTransactionModelCopyWithImpl<$Res, _$VtuTransactionModelImpl>
    implements _$$VtuTransactionModelImplCopyWith<$Res> {
  __$$VtuTransactionModelImplCopyWithImpl(_$VtuTransactionModelImpl _value,
      $Res Function(_$VtuTransactionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of VtuTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serviceType = null,
    Object? provider = null,
    Object? amount = null,
    Object? recipient = null,
    Object? status = null,
    Object? reference = null,
    Object? createdAt = null,
  }) {
    return _then(_$VtuTransactionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      serviceType: null == serviceType
          ? _value.serviceType
          : serviceType // ignore: cast_nullable_to_non_nullable
              as String,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      recipient: null == recipient
          ? _value.recipient
          : recipient // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      reference: null == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VtuTransactionModelImpl implements _VtuTransactionModel {
  const _$VtuTransactionModelImpl(
      {required this.id,
      @JsonKey(name: 'serviceType') required this.serviceType,
      required this.provider,
      required this.amount,
      required this.recipient,
      required this.status,
      required this.reference,
      @JsonKey(name: 'createdAt') required this.createdAt});

  factory _$VtuTransactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VtuTransactionModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'serviceType')
  final String serviceType;
  @override
  final String provider;
  @override
  final double amount;
  @override
  final String recipient;
  @override
  final String status;
  @override
  final String reference;
  @override
  @JsonKey(name: 'createdAt')
  final String createdAt;

  @override
  String toString() {
    return 'VtuTransactionModel(id: $id, serviceType: $serviceType, provider: $provider, amount: $amount, recipient: $recipient, status: $status, reference: $reference, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VtuTransactionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.serviceType, serviceType) ||
                other.serviceType == serviceType) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.recipient, recipient) ||
                other.recipient == recipient) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, serviceType, provider,
      amount, recipient, status, reference, createdAt);

  /// Create a copy of VtuTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VtuTransactionModelImplCopyWith<_$VtuTransactionModelImpl> get copyWith =>
      __$$VtuTransactionModelImplCopyWithImpl<_$VtuTransactionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VtuTransactionModelImplToJson(
      this,
    );
  }
}

abstract class _VtuTransactionModel implements VtuTransactionModel {
  const factory _VtuTransactionModel(
          {required final String id,
          @JsonKey(name: 'serviceType') required final String serviceType,
          required final String provider,
          required final double amount,
          required final String recipient,
          required final String status,
          required final String reference,
          @JsonKey(name: 'createdAt') required final String createdAt}) =
      _$VtuTransactionModelImpl;

  factory _VtuTransactionModel.fromJson(Map<String, dynamic> json) =
      _$VtuTransactionModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'serviceType')
  String get serviceType;
  @override
  String get provider;
  @override
  double get amount;
  @override
  String get recipient;
  @override
  String get status;
  @override
  String get reference;
  @override
  @JsonKey(name: 'createdAt')
  String get createdAt;

  /// Create a copy of VtuTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VtuTransactionModelImplCopyWith<_$VtuTransactionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
