// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vtu.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$VtuService {
  String get serviceId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;

  /// Create a copy of VtuService
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VtuServiceCopyWith<VtuService> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VtuServiceCopyWith<$Res> {
  factory $VtuServiceCopyWith(
          VtuService value, $Res Function(VtuService) then) =
      _$VtuServiceCopyWithImpl<$Res, VtuService>;
  @useResult
  $Res call({String serviceId, String name, String? image});
}

/// @nodoc
class _$VtuServiceCopyWithImpl<$Res, $Val extends VtuService>
    implements $VtuServiceCopyWith<$Res> {
  _$VtuServiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VtuService
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
abstract class _$$VtuServiceImplCopyWith<$Res>
    implements $VtuServiceCopyWith<$Res> {
  factory _$$VtuServiceImplCopyWith(
          _$VtuServiceImpl value, $Res Function(_$VtuServiceImpl) then) =
      __$$VtuServiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String serviceId, String name, String? image});
}

/// @nodoc
class __$$VtuServiceImplCopyWithImpl<$Res>
    extends _$VtuServiceCopyWithImpl<$Res, _$VtuServiceImpl>
    implements _$$VtuServiceImplCopyWith<$Res> {
  __$$VtuServiceImplCopyWithImpl(
      _$VtuServiceImpl _value, $Res Function(_$VtuServiceImpl) _then)
      : super(_value, _then);

  /// Create a copy of VtuService
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceId = null,
    Object? name = null,
    Object? image = freezed,
  }) {
    return _then(_$VtuServiceImpl(
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

class _$VtuServiceImpl implements _VtuService {
  const _$VtuServiceImpl(
      {required this.serviceId, required this.name, this.image});

  @override
  final String serviceId;
  @override
  final String name;
  @override
  final String? image;

  @override
  String toString() {
    return 'VtuService(serviceId: $serviceId, name: $name, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VtuServiceImpl &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.image, image) || other.image == image));
  }

  @override
  int get hashCode => Object.hash(runtimeType, serviceId, name, image);

  /// Create a copy of VtuService
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VtuServiceImplCopyWith<_$VtuServiceImpl> get copyWith =>
      __$$VtuServiceImplCopyWithImpl<_$VtuServiceImpl>(this, _$identity);
}

abstract class _VtuService implements VtuService {
  const factory _VtuService(
      {required final String serviceId,
      required final String name,
      final String? image}) = _$VtuServiceImpl;

  @override
  String get serviceId;
  @override
  String get name;
  @override
  String? get image;

  /// Create a copy of VtuService
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VtuServiceImplCopyWith<_$VtuServiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$VtuVariation {
  String get name => throw _privateConstructorUsedError;
  String get variationCode => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  bool get isFixedPrice => throw _privateConstructorUsedError;

  /// Create a copy of VtuVariation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VtuVariationCopyWith<VtuVariation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VtuVariationCopyWith<$Res> {
  factory $VtuVariationCopyWith(
          VtuVariation value, $Res Function(VtuVariation) then) =
      _$VtuVariationCopyWithImpl<$Res, VtuVariation>;
  @useResult
  $Res call(
      {String name, String variationCode, double amount, bool isFixedPrice});
}

/// @nodoc
class _$VtuVariationCopyWithImpl<$Res, $Val extends VtuVariation>
    implements $VtuVariationCopyWith<$Res> {
  _$VtuVariationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VtuVariation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? variationCode = null,
    Object? amount = null,
    Object? isFixedPrice = null,
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
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      isFixedPrice: null == isFixedPrice
          ? _value.isFixedPrice
          : isFixedPrice // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VtuVariationImplCopyWith<$Res>
    implements $VtuVariationCopyWith<$Res> {
  factory _$$VtuVariationImplCopyWith(
          _$VtuVariationImpl value, $Res Function(_$VtuVariationImpl) then) =
      __$$VtuVariationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name, String variationCode, double amount, bool isFixedPrice});
}

/// @nodoc
class __$$VtuVariationImplCopyWithImpl<$Res>
    extends _$VtuVariationCopyWithImpl<$Res, _$VtuVariationImpl>
    implements _$$VtuVariationImplCopyWith<$Res> {
  __$$VtuVariationImplCopyWithImpl(
      _$VtuVariationImpl _value, $Res Function(_$VtuVariationImpl) _then)
      : super(_value, _then);

  /// Create a copy of VtuVariation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? variationCode = null,
    Object? amount = null,
    Object? isFixedPrice = null,
  }) {
    return _then(_$VtuVariationImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      variationCode: null == variationCode
          ? _value.variationCode
          : variationCode // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      isFixedPrice: null == isFixedPrice
          ? _value.isFixedPrice
          : isFixedPrice // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$VtuVariationImpl implements _VtuVariation {
  const _$VtuVariationImpl(
      {required this.name,
      required this.variationCode,
      required this.amount,
      required this.isFixedPrice});

  @override
  final String name;
  @override
  final String variationCode;
  @override
  final double amount;
  @override
  final bool isFixedPrice;

  @override
  String toString() {
    return 'VtuVariation(name: $name, variationCode: $variationCode, amount: $amount, isFixedPrice: $isFixedPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VtuVariationImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.variationCode, variationCode) ||
                other.variationCode == variationCode) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.isFixedPrice, isFixedPrice) ||
                other.isFixedPrice == isFixedPrice));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, name, variationCode, amount, isFixedPrice);

  /// Create a copy of VtuVariation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VtuVariationImplCopyWith<_$VtuVariationImpl> get copyWith =>
      __$$VtuVariationImplCopyWithImpl<_$VtuVariationImpl>(this, _$identity);
}

abstract class _VtuVariation implements VtuVariation {
  const factory _VtuVariation(
      {required final String name,
      required final String variationCode,
      required final double amount,
      required final bool isFixedPrice}) = _$VtuVariationImpl;

  @override
  String get name;
  @override
  String get variationCode;
  @override
  double get amount;
  @override
  bool get isFixedPrice;

  /// Create a copy of VtuVariation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VtuVariationImplCopyWith<_$VtuVariationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$VtuMerchantInfo {
  String get customerName => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get meterNumber => throw _privateConstructorUsedError;

  /// Create a copy of VtuMerchantInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VtuMerchantInfoCopyWith<VtuMerchantInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VtuMerchantInfoCopyWith<$Res> {
  factory $VtuMerchantInfoCopyWith(
          VtuMerchantInfo value, $Res Function(VtuMerchantInfo) then) =
      _$VtuMerchantInfoCopyWithImpl<$Res, VtuMerchantInfo>;
  @useResult
  $Res call({String customerName, String? address, String? meterNumber});
}

/// @nodoc
class _$VtuMerchantInfoCopyWithImpl<$Res, $Val extends VtuMerchantInfo>
    implements $VtuMerchantInfoCopyWith<$Res> {
  _$VtuMerchantInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VtuMerchantInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerName = null,
    Object? address = freezed,
    Object? meterNumber = freezed,
  }) {
    return _then(_value.copyWith(
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$VtuMerchantInfoImplCopyWith<$Res>
    implements $VtuMerchantInfoCopyWith<$Res> {
  factory _$$VtuMerchantInfoImplCopyWith(_$VtuMerchantInfoImpl value,
          $Res Function(_$VtuMerchantInfoImpl) then) =
      __$$VtuMerchantInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String customerName, String? address, String? meterNumber});
}

/// @nodoc
class __$$VtuMerchantInfoImplCopyWithImpl<$Res>
    extends _$VtuMerchantInfoCopyWithImpl<$Res, _$VtuMerchantInfoImpl>
    implements _$$VtuMerchantInfoImplCopyWith<$Res> {
  __$$VtuMerchantInfoImplCopyWithImpl(
      _$VtuMerchantInfoImpl _value, $Res Function(_$VtuMerchantInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of VtuMerchantInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerName = null,
    Object? address = freezed,
    Object? meterNumber = freezed,
  }) {
    return _then(_$VtuMerchantInfoImpl(
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
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

class _$VtuMerchantInfoImpl implements _VtuMerchantInfo {
  const _$VtuMerchantInfoImpl(
      {required this.customerName, this.address, this.meterNumber});

  @override
  final String customerName;
  @override
  final String? address;
  @override
  final String? meterNumber;

  @override
  String toString() {
    return 'VtuMerchantInfo(customerName: $customerName, address: $address, meterNumber: $meterNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VtuMerchantInfoImpl &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.meterNumber, meterNumber) ||
                other.meterNumber == meterNumber));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, customerName, address, meterNumber);

  /// Create a copy of VtuMerchantInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VtuMerchantInfoImplCopyWith<_$VtuMerchantInfoImpl> get copyWith =>
      __$$VtuMerchantInfoImplCopyWithImpl<_$VtuMerchantInfoImpl>(
          this, _$identity);
}

abstract class _VtuMerchantInfo implements VtuMerchantInfo {
  const factory _VtuMerchantInfo(
      {required final String customerName,
      final String? address,
      final String? meterNumber}) = _$VtuMerchantInfoImpl;

  @override
  String get customerName;
  @override
  String? get address;
  @override
  String? get meterNumber;

  /// Create a copy of VtuMerchantInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VtuMerchantInfoImplCopyWith<_$VtuMerchantInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$VtuTransaction {
  String get id => throw _privateConstructorUsedError;
  String get serviceType => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get recipient => throw _privateConstructorUsedError;
  VtuStatus get status => throw _privateConstructorUsedError;
  String get reference => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of VtuTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VtuTransactionCopyWith<VtuTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VtuTransactionCopyWith<$Res> {
  factory $VtuTransactionCopyWith(
          VtuTransaction value, $Res Function(VtuTransaction) then) =
      _$VtuTransactionCopyWithImpl<$Res, VtuTransaction>;
  @useResult
  $Res call(
      {String id,
      String serviceType,
      String provider,
      double amount,
      String recipient,
      VtuStatus status,
      String reference,
      DateTime createdAt});
}

/// @nodoc
class _$VtuTransactionCopyWithImpl<$Res, $Val extends VtuTransaction>
    implements $VtuTransactionCopyWith<$Res> {
  _$VtuTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VtuTransaction
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
              as VtuStatus,
      reference: null == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VtuTransactionImplCopyWith<$Res>
    implements $VtuTransactionCopyWith<$Res> {
  factory _$$VtuTransactionImplCopyWith(_$VtuTransactionImpl value,
          $Res Function(_$VtuTransactionImpl) then) =
      __$$VtuTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String serviceType,
      String provider,
      double amount,
      String recipient,
      VtuStatus status,
      String reference,
      DateTime createdAt});
}

/// @nodoc
class __$$VtuTransactionImplCopyWithImpl<$Res>
    extends _$VtuTransactionCopyWithImpl<$Res, _$VtuTransactionImpl>
    implements _$$VtuTransactionImplCopyWith<$Res> {
  __$$VtuTransactionImplCopyWithImpl(
      _$VtuTransactionImpl _value, $Res Function(_$VtuTransactionImpl) _then)
      : super(_value, _then);

  /// Create a copy of VtuTransaction
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
    return _then(_$VtuTransactionImpl(
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
              as VtuStatus,
      reference: null == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$VtuTransactionImpl implements _VtuTransaction {
  const _$VtuTransactionImpl(
      {required this.id,
      required this.serviceType,
      required this.provider,
      required this.amount,
      required this.recipient,
      required this.status,
      required this.reference,
      required this.createdAt});

  @override
  final String id;
  @override
  final String serviceType;
  @override
  final String provider;
  @override
  final double amount;
  @override
  final String recipient;
  @override
  final VtuStatus status;
  @override
  final String reference;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'VtuTransaction(id: $id, serviceType: $serviceType, provider: $provider, amount: $amount, recipient: $recipient, status: $status, reference: $reference, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VtuTransactionImpl &&
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

  @override
  int get hashCode => Object.hash(runtimeType, id, serviceType, provider,
      amount, recipient, status, reference, createdAt);

  /// Create a copy of VtuTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VtuTransactionImplCopyWith<_$VtuTransactionImpl> get copyWith =>
      __$$VtuTransactionImplCopyWithImpl<_$VtuTransactionImpl>(
          this, _$identity);
}

abstract class _VtuTransaction implements VtuTransaction {
  const factory _VtuTransaction(
      {required final String id,
      required final String serviceType,
      required final String provider,
      required final double amount,
      required final String recipient,
      required final VtuStatus status,
      required final String reference,
      required final DateTime createdAt}) = _$VtuTransactionImpl;

  @override
  String get id;
  @override
  String get serviceType;
  @override
  String get provider;
  @override
  double get amount;
  @override
  String get recipient;
  @override
  VtuStatus get status;
  @override
  String get reference;
  @override
  DateTime get createdAt;

  /// Create a copy of VtuTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VtuTransactionImplCopyWith<_$VtuTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
