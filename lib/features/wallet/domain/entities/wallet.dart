import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet.freezed.dart';

enum WalletTxType {
  credit,
  debit;

  static WalletTxType fromString(String s) =>
      s.toLowerCase() == 'credit' ? WalletTxType.credit : WalletTxType.debit;

  String get displayName => name[0].toUpperCase() + name.substring(1);
}

@freezed
class Wallet with _$Wallet {
  const factory Wallet({
    required String id,
    required double balance,
    required DateTime updatedAt,
  }) = _Wallet;
}

@freezed
class WalletTransaction with _$WalletTransaction {
  const WalletTransaction._();

  const factory WalletTransaction({
    required String id,
    required String walletId,
    required WalletTxType type,
    required double amount,
    required double balanceBefore,
    required double balanceAfter,
    required String description,
    required String reference,
    required DateTime createdAt,
  }) = _WalletTransaction;

  bool get isCredit => type == WalletTxType.credit;
}

@freezed
class TopupResult with _$TopupResult {
  const factory TopupResult({
    required String authorizationUrl,
    required String reference,
  }) = _TopupResult;
}
