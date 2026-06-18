import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/wallet.dart';

part 'wallet_model.freezed.dart';
part 'wallet_model.g.dart';

@freezed
class WalletModel with _$WalletModel {
  const factory WalletModel({
    required String id,
    required double balance,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _WalletModel;

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);
}

@freezed
class WalletTransactionModel with _$WalletTransactionModel {
  const factory WalletTransactionModel({
    required String id,
    @JsonKey(name: 'wallet_id') required String walletId,
    @JsonKey(name: 'transaction_type') required String transactionType,
    required double amount,
    @JsonKey(name: 'balance_before') double? balanceBefore,
    @JsonKey(name: 'balance_after') double? balanceAfter,
    required String description,
    String? reference,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _WalletTransactionModel;

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionModelFromJson(json);
}

@freezed
class TopupResultModel with _$TopupResultModel {
  const factory TopupResultModel({
    @JsonKey(name: 'authorization_url') required String authorizationUrl,
    required String reference,
  }) = _TopupResultModel;

  factory TopupResultModel.fromJson(Map<String, dynamic> json) =>
      _$TopupResultModelFromJson(json);
}

extension WalletModelX on WalletModel {
  Wallet toEntity() => Wallet(
        id: id,
        balance: balance,
        updatedAt: DateTime.parse(updatedAt),
      );
}

extension WalletTransactionModelX on WalletTransactionModel {
  WalletTransaction toEntity() => WalletTransaction(
        id: id,
        walletId: walletId,
        type: WalletTxType.fromString(transactionType),
        amount: amount,
        balanceBefore: balanceBefore ?? 0,
        balanceAfter: balanceAfter ?? 0,
        description: description,
        reference: reference ?? '',
        createdAt: DateTime.parse(createdAt),
      );
}

extension TopupResultModelX on TopupResultModel {
  TopupResult toEntity() => TopupResult(
        authorizationUrl: authorizationUrl,
        reference: reference,
      );
}
