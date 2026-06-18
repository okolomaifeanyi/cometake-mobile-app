// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vtu_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VtuServiceModelImpl _$$VtuServiceModelImplFromJson(
        Map<String, dynamic> json) =>
    _$VtuServiceModelImpl(
      serviceId: json['serviceID'] as String,
      name: json['name'] as String,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$$VtuServiceModelImplToJson(
        _$VtuServiceModelImpl instance) =>
    <String, dynamic>{
      'serviceID': instance.serviceId,
      'name': instance.name,
      'image': instance.image,
    };

_$VtuVariationModelImpl _$$VtuVariationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$VtuVariationModelImpl(
      name: json['name'] as String,
      variationCode: json['variation_code'] as String,
      variationAmount: json['variation_amount'] as String,
      fixedPrice: json['fixedPrice'] as String?,
    );

Map<String, dynamic> _$$VtuVariationModelImplToJson(
        _$VtuVariationModelImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'variation_code': instance.variationCode,
      'variation_amount': instance.variationAmount,
      'fixedPrice': instance.fixedPrice,
    };

_$VtuMerchantModelImpl _$$VtuMerchantModelImplFromJson(
        Map<String, dynamic> json) =>
    _$VtuMerchantModelImpl(
      customerName: json['Customer_Name'] as String?,
      address: json['Address'] as String?,
      meterNumber: json['Meter_Number'] as String?,
    );

Map<String, dynamic> _$$VtuMerchantModelImplToJson(
        _$VtuMerchantModelImpl instance) =>
    <String, dynamic>{
      'Customer_Name': instance.customerName,
      'Address': instance.address,
      'Meter_Number': instance.meterNumber,
    };

_$VtuTransactionModelImpl _$$VtuTransactionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$VtuTransactionModelImpl(
      id: json['id'] as String,
      serviceType: json['serviceType'] as String,
      provider: json['provider'] as String,
      amount: (json['amount'] as num).toDouble(),
      recipient: json['recipient'] as String,
      status: json['status'] as String,
      reference: json['reference'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$$VtuTransactionModelImplToJson(
        _$VtuTransactionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceType': instance.serviceType,
      'provider': instance.provider,
      'amount': instance.amount,
      'recipient': instance.recipient,
      'status': instance.status,
      'reference': instance.reference,
      'createdAt': instance.createdAt,
    };
