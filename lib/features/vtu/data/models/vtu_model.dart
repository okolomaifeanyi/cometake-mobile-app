import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/vtu.dart';

part 'vtu_model.freezed.dart';
part 'vtu_model.g.dart';

// VTPass service from /api/v1/vtu/services/{category}
@freezed
class VtuServiceModel with _$VtuServiceModel {
  const factory VtuServiceModel({
    @JsonKey(name: 'serviceID') required String serviceId,
    required String name,
    String? image,
  }) = _VtuServiceModel;

  factory VtuServiceModel.fromJson(Map<String, dynamic> json) =>
      _$VtuServiceModelFromJson(json);
}

// VTPass variation from /api/v1/vtu/variations/{serviceID}
@freezed
class VtuVariationModel with _$VtuVariationModel {
  const factory VtuVariationModel({
    required String name,
    @JsonKey(name: 'variation_code') required String variationCode,
    @JsonKey(name: 'variation_amount') required String variationAmount,
    @JsonKey(name: 'fixedPrice') String? fixedPrice,
  }) = _VtuVariationModel;

  factory VtuVariationModel.fromJson(Map<String, dynamic> json) =>
      _$VtuVariationModelFromJson(json);
}

// Merchant verify response
@freezed
class VtuMerchantModel with _$VtuMerchantModel {
  const factory VtuMerchantModel({
    @JsonKey(name: 'Customer_Name') String? customerName,
    @JsonKey(name: 'Address') String? address,
    @JsonKey(name: 'Meter_Number') String? meterNumber,
  }) = _VtuMerchantModel;

  factory VtuMerchantModel.fromJson(Map<String, dynamic> json) =>
      _$VtuMerchantModelFromJson(json);
}

// VTU transaction from history
@freezed
class VtuTransactionModel with _$VtuTransactionModel {
  const factory VtuTransactionModel({
    required String id,
    @JsonKey(name: 'serviceType') required String serviceType,
    required String provider,
    required double amount,
    required String recipient,
    required String status,
    required String reference,
    @JsonKey(name: 'createdAt') required String createdAt,
  }) = _VtuTransactionModel;

  factory VtuTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$VtuTransactionModelFromJson(json);
}

extension VtuServiceModelX on VtuServiceModel {
  VtuService toEntity() => VtuService(
        serviceId: serviceId,
        name: name,
        image: image,
      );
}

extension VtuVariationModelX on VtuVariationModel {
  VtuVariation toEntity() => VtuVariation(
        name: name,
        variationCode: variationCode,
        amount: double.tryParse(variationAmount) ?? 0,
        isFixedPrice: fixedPrice?.toLowerCase() == 'yes',
      );
}

extension VtuMerchantModelX on VtuMerchantModel {
  VtuMerchantInfo toEntity() => VtuMerchantInfo(
        customerName: customerName ?? 'Unknown Customer',
        address: address,
        meterNumber: meterNumber,
      );
}

extension VtuTransactionModelX on VtuTransactionModel {
  VtuTransaction toEntity() => VtuTransaction(
        id: id,
        serviceType: serviceType,
        provider: provider,
        amount: amount,
        recipient: recipient,
        status: VtuStatus.fromString(status),
        reference: reference,
        createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      );
}
