import 'package:freezed_annotation/freezed_annotation.dart';

part 'vtu.freezed.dart';

enum VtuServiceType {
  airtime,
  data,
  electricity,
  cable;

  String get displayName => switch (this) {
        VtuServiceType.airtime => 'Airtime',
        VtuServiceType.data => 'Data',
        VtuServiceType.electricity => 'Electricity',
        VtuServiceType.cable => 'Cable TV',
      };

  String get category => switch (this) {
        VtuServiceType.airtime => 'airtime',
        VtuServiceType.data => 'data',
        VtuServiceType.electricity => 'electricity-bill',
        VtuServiceType.cable => 'tv-subscription',
      };

  bool get hasVariations => this == VtuServiceType.data || this == VtuServiceType.cable;
  bool get needsMerchantVerify => this == VtuServiceType.electricity || this == VtuServiceType.cable;
  bool get amountFromVariation => this == VtuServiceType.data || this == VtuServiceType.cable;
}

enum VtuStatus {
  pending,
  completed,
  failed;

  static VtuStatus fromString(String s) => switch (s.toLowerCase()) {
        'completed' => VtuStatus.completed,
        'failed' => VtuStatus.failed,
        _ => VtuStatus.pending,
      };

  String get displayName => name[0].toUpperCase() + name.substring(1);
}

@freezed
class VtuService with _$VtuService {
  const factory VtuService({
    required String serviceId,
    required String name,
    String? image,
  }) = _VtuService;
}

@freezed
class VtuVariation with _$VtuVariation {
  const factory VtuVariation({
    required String name,
    required String variationCode,
    required double amount,
    required bool isFixedPrice,
  }) = _VtuVariation;
}

@freezed
class VtuMerchantInfo with _$VtuMerchantInfo {
  const factory VtuMerchantInfo({
    required String customerName,
    String? address,
    String? meterNumber,
  }) = _VtuMerchantInfo;
}

@freezed
class VtuTransaction with _$VtuTransaction {
  const factory VtuTransaction({
    required String id,
    required String serviceType,
    required String provider,
    required double amount,
    required String recipient,
    required VtuStatus status,
    required String reference,
    required DateTime createdAt,
  }) = _VtuTransaction;
}
