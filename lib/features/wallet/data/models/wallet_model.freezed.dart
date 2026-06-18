// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WalletModel _$WalletModelFromJson(Map<String, dynamic> json) {
  return _WalletModel.fromJson(json);
}

/// @nodoc
mixin _$WalletModel {
  String get id => throw _privateConstructorUsedError;
  double get balance => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this WalletModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WalletModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletModelCopyWith<WalletModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletModelCopyWith<$Res> {
  factory $WalletModelCopyWith(
          WalletModel value, $Res Function(WalletModel) then) =
      _$WalletModelCopyWithImpl<$Res, WalletModel>;
  @useResult
  $Res call(
      {String id,
      double balance,
      @JsonKey(name: 'updated_at') String updatedAt});
}

/// @nodoc
class _$WalletModelCopyWithImpl<$Res, $Val extends WalletModel>
    implements $WalletModelCopyWith<$Res> {
  _$WalletModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WalletModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? balance = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WalletModelImplCopyWith<$Res>
    implements $WalletModelCopyWith<$Res> {
  factory _$$WalletModelImplCopyWith(
          _$WalletModelImpl value, $Res Function(_$WalletModelImpl) then) =
      __$$WalletModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      double balance,
      @JsonKey(name: 'updated_at') String updatedAt});
}

/// @nodoc
class __$$WalletModelImplCopyWithImpl<$Res>
    extends _$WalletModelCopyWithImpl<$Res, _$WalletModelImpl>
    implements _$$WalletModelImplCopyWith<$Res> {
  __$$WalletModelImplCopyWithImpl(
      _$WalletModelImpl _value, $Res Function(_$WalletModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of WalletModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? balance = null,
    Object? updatedAt = null,
  }) {
    return _then(_$WalletModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WalletModelImpl implements _WalletModel {
  const _$WalletModelImpl(
      {required this.id,
      required this.balance,
      @JsonKey(name: 'updated_at') required this.updatedAt});

  factory _$WalletModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletModelImplFromJson(json);

  @override
  final String id;
  @override
  final double balance;
  @override
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  @override
  String toString() {
    return 'WalletModel(id: $id, balance: $balance, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, balance, updatedAt);

  /// Create a copy of WalletModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletModelImplCopyWith<_$WalletModelImpl> get copyWith =>
      __$$WalletModelImplCopyWithImpl<_$WalletModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletModelImplToJson(
      this,
    );
  }
}

abstract class _WalletModel implements WalletModel {
  const factory _WalletModel(
          {required final String id,
          required final double balance,
          @JsonKey(name: 'updated_at') required final String updatedAt}) =
      _$WalletModelImpl;

  factory _WalletModel.fromJson(Map<String, dynamic> json) =
      _$WalletModelImpl.fromJson;

  @override
  String get id;
  @override
  double get balance;
  @override
  @JsonKey(name: 'updated_at')
  String get updatedAt;

  /// Create a copy of WalletModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletModelImplCopyWith<_$WalletModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WalletTransactionModel _$WalletTransactionModelFromJson(
    Map<String, dynamic> json) {
  return _WalletTransactionModel.fromJson(json);
}

/// @nodoc
mixin _$WalletTransactionModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'wallet_id')
  String get walletId => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_type')
  String get transactionType => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'balance_before')
  double? get balanceBefore => throw _privateConstructorUsedError;
  @JsonKey(name: 'balance_after')
  double? get balanceAfter => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get reference => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this WalletTransactionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WalletTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletTransactionModelCopyWith<WalletTransactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletTransactionModelCopyWith<$Res> {
  factory $WalletTransactionModelCopyWith(WalletTransactionModel value,
          $Res Function(WalletTransactionModel) then) =
      _$WalletTransactionModelCopyWithImpl<$Res, WalletTransactionModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'wallet_id') String walletId,
      @JsonKey(name: 'transaction_type') String transactionType,
      double amount,
      @JsonKey(name: 'balance_before') double? balanceBefore,
      @JsonKey(name: 'balance_after') double? balanceAfter,
      String description,
      String? reference,
      @JsonKey(name: 'created_at') String createdAt});
}

/// @nodoc
class _$WalletTransactionModelCopyWithImpl<$Res,
        $Val extends WalletTransactionModel>
    implements $WalletTransactionModelCopyWith<$Res> {
  _$WalletTransactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WalletTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? walletId = null,
    Object? transactionType = null,
    Object? amount = null,
    Object? balanceBefore = freezed,
    Object? balanceAfter = freezed,
    Object? description = null,
    Object? reference = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      walletId: null == walletId
          ? _value.walletId
          : walletId // ignore: cast_nullable_to_non_nullable
              as String,
      transactionType: null == transactionType
          ? _value.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      balanceBefore: freezed == balanceBefore
          ? _value.balanceBefore
          : balanceBefore // ignore: cast_nullable_to_non_nullable
              as double?,
      balanceAfter: freezed == balanceAfter
          ? _value.balanceAfter
          : balanceAfter // ignore: cast_nullable_to_non_nullable
              as double?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      reference: freezed == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WalletTransactionModelImplCopyWith<$Res>
    implements $WalletTransactionModelCopyWith<$Res> {
  factory _$$WalletTransactionModelImplCopyWith(
          _$WalletTransactionModelImpl value,
          $Res Function(_$WalletTransactionModelImpl) then) =
      __$$WalletTransactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'wallet_id') String walletId,
      @JsonKey(name: 'transaction_type') String transactionType,
      double amount,
      @JsonKey(name: 'balance_before') double? balanceBefore,
      @JsonKey(name: 'balance_after') double? balanceAfter,
      String description,
      String? reference,
      @JsonKey(name: 'created_at') String createdAt});
}

/// @nodoc
class __$$WalletTransactionModelImplCopyWithImpl<$Res>
    extends _$WalletTransactionModelCopyWithImpl<$Res,
        _$WalletTransactionModelImpl>
    implements _$$WalletTransactionModelImplCopyWith<$Res> {
  __$$WalletTransactionModelImplCopyWithImpl(
      _$WalletTransactionModelImpl _value,
      $Res Function(_$WalletTransactionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of WalletTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? walletId = null,
    Object? transactionType = null,
    Object? amount = null,
    Object? balanceBefore = freezed,
    Object? balanceAfter = freezed,
    Object? description = null,
    Object? reference = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$WalletTransactionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      walletId: null == walletId
          ? _value.walletId
          : walletId // ignore: cast_nullable_to_non_nullable
              as String,
      transactionType: null == transactionType
          ? _value.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      balanceBefore: freezed == balanceBefore
          ? _value.balanceBefore
          : balanceBefore // ignore: cast_nullable_to_non_nullable
              as double?,
      balanceAfter: freezed == balanceAfter
          ? _value.balanceAfter
          : balanceAfter // ignore: cast_nullable_to_non_nullable
              as double?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      reference: freezed == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WalletTransactionModelImpl implements _WalletTransactionModel {
  const _$WalletTransactionModelImpl(
      {required this.id,
      @JsonKey(name: 'wallet_id') required this.walletId,
      @JsonKey(name: 'transaction_type') required this.transactionType,
      required this.amount,
      @JsonKey(name: 'balance_before') this.balanceBefore,
      @JsonKey(name: 'balance_after') this.balanceAfter,
      required this.description,
      this.reference,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$WalletTransactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletTransactionModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'wallet_id')
  final String walletId;
  @override
  @JsonKey(name: 'transaction_type')
  final String transactionType;
  @override
  final double amount;
  @override
  @JsonKey(name: 'balance_before')
  final double? balanceBefore;
  @override
  @JsonKey(name: 'balance_after')
  final double? balanceAfter;
  @override
  final String description;
  @override
  final String? reference;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;

  @override
  String toString() {
    return 'WalletTransactionModel(id: $id, walletId: $walletId, transactionType: $transactionType, amount: $amount, balanceBefore: $balanceBefore, balanceAfter: $balanceAfter, description: $description, reference: $reference, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletTransactionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.walletId, walletId) ||
                other.walletId == walletId) &&
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.balanceBefore, balanceBefore) ||
                other.balanceBefore == balanceBefore) &&
            (identical(other.balanceAfter, balanceAfter) ||
                other.balanceAfter == balanceAfter) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, walletId, transactionType,
      amount, balanceBefore, balanceAfter, description, reference, createdAt);

  /// Create a copy of WalletTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletTransactionModelImplCopyWith<_$WalletTransactionModelImpl>
      get copyWith => __$$WalletTransactionModelImplCopyWithImpl<
          _$WalletTransactionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletTransactionModelImplToJson(
      this,
    );
  }
}

abstract class _WalletTransactionModel implements WalletTransactionModel {
  const factory _WalletTransactionModel(
      {required final String id,
      @JsonKey(name: 'wallet_id') required final String walletId,
      @JsonKey(name: 'transaction_type') required final String transactionType,
      required final double amount,
      @JsonKey(name: 'balance_before') final double? balanceBefore,
      @JsonKey(name: 'balance_after') final double? balanceAfter,
      required final String description,
      final String? reference,
      @JsonKey(name: 'created_at')
      required final String createdAt}) = _$WalletTransactionModelImpl;

  factory _WalletTransactionModel.fromJson(Map<String, dynamic> json) =
      _$WalletTransactionModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'wallet_id')
  String get walletId;
  @override
  @JsonKey(name: 'transaction_type')
  String get transactionType;
  @override
  double get amount;
  @override
  @JsonKey(name: 'balance_before')
  double? get balanceBefore;
  @override
  @JsonKey(name: 'balance_after')
  double? get balanceAfter;
  @override
  String get description;
  @override
  String? get reference;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;

  /// Create a copy of WalletTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletTransactionModelImplCopyWith<_$WalletTransactionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TopupResultModel _$TopupResultModelFromJson(Map<String, dynamic> json) {
  return _TopupResultModel.fromJson(json);
}

/// @nodoc
mixin _$TopupResultModel {
  @JsonKey(name: 'authorization_url')
  String get authorizationUrl => throw _privateConstructorUsedError;
  String get reference => throw _privateConstructorUsedError;

  /// Serializes this TopupResultModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TopupResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TopupResultModelCopyWith<TopupResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopupResultModelCopyWith<$Res> {
  factory $TopupResultModelCopyWith(
          TopupResultModel value, $Res Function(TopupResultModel) then) =
      _$TopupResultModelCopyWithImpl<$Res, TopupResultModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'authorization_url') String authorizationUrl,
      String reference});
}

/// @nodoc
class _$TopupResultModelCopyWithImpl<$Res, $Val extends TopupResultModel>
    implements $TopupResultModelCopyWith<$Res> {
  _$TopupResultModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TopupResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authorizationUrl = null,
    Object? reference = null,
  }) {
    return _then(_value.copyWith(
      authorizationUrl: null == authorizationUrl
          ? _value.authorizationUrl
          : authorizationUrl // ignore: cast_nullable_to_non_nullable
              as String,
      reference: null == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TopupResultModelImplCopyWith<$Res>
    implements $TopupResultModelCopyWith<$Res> {
  factory _$$TopupResultModelImplCopyWith(_$TopupResultModelImpl value,
          $Res Function(_$TopupResultModelImpl) then) =
      __$$TopupResultModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'authorization_url') String authorizationUrl,
      String reference});
}

/// @nodoc
class __$$TopupResultModelImplCopyWithImpl<$Res>
    extends _$TopupResultModelCopyWithImpl<$Res, _$TopupResultModelImpl>
    implements _$$TopupResultModelImplCopyWith<$Res> {
  __$$TopupResultModelImplCopyWithImpl(_$TopupResultModelImpl _value,
      $Res Function(_$TopupResultModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TopupResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authorizationUrl = null,
    Object? reference = null,
  }) {
    return _then(_$TopupResultModelImpl(
      authorizationUrl: null == authorizationUrl
          ? _value.authorizationUrl
          : authorizationUrl // ignore: cast_nullable_to_non_nullable
              as String,
      reference: null == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TopupResultModelImpl implements _TopupResultModel {
  const _$TopupResultModelImpl(
      {@JsonKey(name: 'authorization_url') required this.authorizationUrl,
      required this.reference});

  factory _$TopupResultModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopupResultModelImplFromJson(json);

  @override
  @JsonKey(name: 'authorization_url')
  final String authorizationUrl;
  @override
  final String reference;

  @override
  String toString() {
    return 'TopupResultModel(authorizationUrl: $authorizationUrl, reference: $reference)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopupResultModelImpl &&
            (identical(other.authorizationUrl, authorizationUrl) ||
                other.authorizationUrl == authorizationUrl) &&
            (identical(other.reference, reference) ||
                other.reference == reference));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, authorizationUrl, reference);

  /// Create a copy of TopupResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TopupResultModelImplCopyWith<_$TopupResultModelImpl> get copyWith =>
      __$$TopupResultModelImplCopyWithImpl<_$TopupResultModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TopupResultModelImplToJson(
      this,
    );
  }
}

abstract class _TopupResultModel implements TopupResultModel {
  const factory _TopupResultModel(
      {@JsonKey(name: 'authorization_url')
      required final String authorizationUrl,
      required final String reference}) = _$TopupResultModelImpl;

  factory _TopupResultModel.fromJson(Map<String, dynamic> json) =
      _$TopupResultModelImpl.fromJson;

  @override
  @JsonKey(name: 'authorization_url')
  String get authorizationUrl;
  @override
  String get reference;

  /// Create a copy of TopupResultModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopupResultModelImplCopyWith<_$TopupResultModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
