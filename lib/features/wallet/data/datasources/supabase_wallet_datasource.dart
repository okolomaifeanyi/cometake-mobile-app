import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../core/constants/payment_source.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/supabase/supabase_module.dart';
import '../../domain/entities/wallet_verify_result.dart';
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

  /// Initialize a Paystack top-up via Next.js backend.
  /// Inserts a `payments` row so the verify route can find it later.
  Future<TopupResultModel> initiateTopup(double amount) async {
    try {
      final resp = await _dio.post<Map<String, dynamic>>(
        '/api/v1/wallet/topup',
        data: {'amount': amount},
      );
      final data = resp.data!;
      return TopupResultModel.fromJson(data);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['error'] ?? e.message ?? 'Top-up failed';
      throw ServerException(msg.toString(), statusCode: e.response?.statusCode);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }

  /// Verify a Paystack top-up via Next.js backend.
  /// Returns a [WalletVerifyResult] — never throws; errors are wrapped in [VerifyError].
  Future<WalletVerifyResult> verifyTopupStatus(String reference) async {
    try {
      final resp = await _dio.post<Map<String, dynamic>>(
        '/api/v1/payments/verify',
        data: {'reference': reference, 'source': PaymentSource.flutter},
      );

      final data = resp.data ?? {};
      final status = data['status'] as String? ?? '';

      switch (status) {
        case 'success':
          return VerifySuccess(
            message: data['message'] as String? ?? 'Wallet topped up',
            paymentType: data['paymentType'] as String?,
            credited: data['credited'] as bool? ?? false,
          );
        case 'pending':
          return VerifyPending(
            retryAfterSeconds: (data['retryAfterSeconds'] as num?)?.toInt() ?? 4,
          );
        default:
          return VerifyFailed(
            data['message'] as String? ?? 'Payment not successful',
          );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        return const VerifyError('Session expired — please log in again', isUnauthorized: true);
      }
      if (statusCode == 404) {
        return const VerifyFailed('Payment record not found');
      }
      final isNetwork = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout;
      final msg = (e.response?.data as Map?)?['error'] ?? e.message ?? 'Verification failed';
      return VerifyError(msg.toString(), isNetwork: isNetwork);
    } catch (e) {
      return VerifyError(e.toString());
    }
  }
}

final walletDatasourceProvider = Provider<SupabaseWalletDatasource>((ref) {
  return SupabaseWalletDatasource(
    ref.watch(supabaseClientProvider),
    ref.watch(dioProvider),
  );
});
