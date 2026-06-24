import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../core/errors/app_exception.dart';
import '../../../../core/supabase/supabase_module.dart';
import '../models/wallet_model.dart';

class SupabaseWalletDatasource {
  final SupabaseClient _client;

  const SupabaseWalletDatasource(this._client);

  Future<WalletModel> fetchWallet() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw const AuthException('Not authenticated');

      final data = await _client
          .from('core_wallet')
          .select('id, balance, updated_at')
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) {
        return WalletModel(
          id: '',
          balance: 0,
          updatedAt: DateTime.now().toIso8601String(),
        );
      }
      return WalletModel.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<List<WalletTransactionModel>> fetchTransactions(String walletId) async {
    try {
      if (walletId.isEmpty) return [];
      final rows = await _client
          .from('core_wallettransaction')
          .select(
            'id, wallet_id, transaction_type, amount, balance_before, balance_after, description, reference, created_at',
          )
          .eq('wallet_id', walletId)
          .order('created_at', ascending: false)
          .limit(50);

      return (rows as List)
          .map((r) => WalletTransactionModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }

  /// Initialize a Paystack top-up via Supabase Edge Function.
  /// Returns [TopupResultModel] with authorization_url + reference.
  Future<TopupResultModel> initiateTopup(double amount) async {
    try {
      final response = await _client.functions.invoke(
        'paystack-topup',
        body: {'amount': amount},
      );

      if (response.status != 200) {
        final err = (response.data as Map<String, dynamic>?)?['error'] ?? 'Top-up failed';
        throw ServerException(err.toString(), statusCode: response.status);
      }

      final data = response.data as Map<String, dynamic>;
      return TopupResultModel.fromJson(data);
    } on FunctionException catch (e) {
      final msg = (e.details as Map<String, dynamic>?)?['error'] ?? e.reasonPhrase ?? 'Top-up failed';
      throw ServerException(msg.toString());
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }

  /// Verify a Paystack payment and credit the wallet via Supabase Edge Function.
  Future<void> verifyTopup(String reference) async {
    try {
      final response = await _client.functions.invoke(
        'paystack-verify',
        body: {'reference': reference},
      );

      if (response.status != 200) {
        final err = (response.data as Map<String, dynamic>?)?['error'] ?? 'Verification failed';
        throw ServerException(err.toString(), statusCode: response.status);
      }
    } on FunctionException catch (e) {
      final msg = (e.details as Map<String, dynamic>?)?['error'] ?? e.reasonPhrase ?? 'Verification failed';
      throw ServerException(msg.toString());
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }
}

final walletDatasourceProvider = Provider<SupabaseWalletDatasource>((ref) {
  return SupabaseWalletDatasource(ref.watch(supabaseClientProvider));
});
