import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/supabase/supabase_module.dart';
import '../models/wallet_model.dart';

class SupabaseWalletDatasource {
  final SupabaseClient _client;
  final Dio _dio;

  const SupabaseWalletDatasource(this._client, this._dio);

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
        // Return zero-balance placeholder; wallet is created server-side on first topup
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
              'id, wallet_id, transaction_type, amount, balance_before, balance_after, description, reference, created_at')
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

  Future<TopupResultModel> initiateTopup(double amount) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/wallet/topup',
        data: {'amount': amount},
      );
      return TopupResultModel.fromJson(response.data!);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Top-up failed';
      throw ServerException(msg.toString(), statusCode: e.response?.statusCode);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }
}

final walletDatasourceProvider = Provider<SupabaseWalletDatasource>((ref) {
  return SupabaseWalletDatasource(
    ref.watch(supabaseClientProvider),
    ref.watch(dioProvider),
  );
});
