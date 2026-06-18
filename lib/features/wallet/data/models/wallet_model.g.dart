// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletModelImpl _$$WalletModelImplFromJson(Map<String, dynamic> json) =>
    _$WalletModelImpl(
      id: json['id'] as String,
      balance: (json['balance'] as num).toDouble(),
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$$WalletModelImplToJson(_$WalletModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'balance': instance.balance,
      'updated_at': instance.updatedAt,
    };

_$WalletTransactionModelImpl _$$WalletTransactionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$WalletTransactionModelImpl(
      id: json['id'] as String,
      walletId: json['wallet_id'] as String,
      transactionType: json['transaction_type'] as String,
      amount: (json['amount'] as num).toDouble(),
      balanceBefore: (json['balance_before'] as num?)?.toDouble(),
      balanceAfter: (json['balance_after'] as num?)?.toDouble(),
      description: json['description'] as String,
      reference: json['reference'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$$WalletTransactionModelImplToJson(
        _$WalletTransactionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'wallet_id': instance.walletId,
      'transaction_type': instance.transactionType,
      'amount': instance.amount,
      'balance_before': instance.balanceBefore,
      'balance_after': instance.balanceAfter,
      'description': instance.description,
      'reference': instance.reference,
      'created_at': instance.createdAt,
    };

_$TopupResultModelImpl _$$TopupResultModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TopupResultModelImpl(
      authorizationUrl: json['authorization_url'] as String,
      reference: json['reference'] as String,
    );

Map<String, dynamic> _$$TopupResultModelImplToJson(
        _$TopupResultModelImpl instance) =>
    <String, dynamic>{
      'authorization_url': instance.authorizationUrl,
      'reference': instance.reference,
    };
