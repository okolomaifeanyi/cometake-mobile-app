import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/supabase/supabase_module.dart';
import '../models/vtu_model.dart';

class VtuDatasource {
  final Dio _dio;
  final SupabaseClient _client;

  const VtuDatasource(this._dio, this._client);

  Future<List<VtuServiceModel>> fetchServices(String category) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
          '/api/v1/vtu/services/$category',);
      final content = res.data?['content'];
      if (content == null) return [];
      final list = content is List ? content : (content as Map)['content'] ?? [];
      return (list as List)
          .map((e) => VtuServiceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data?['error']?.toString() ?? 'Failed to load services',);
    }
  }

  Future<List<VtuVariationModel>> fetchVariations(String serviceId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
          '/api/v1/vtu/variations/$serviceId',);
      final content = res.data?['content'];
      if (content == null) return [];
      // VTPass: { content: { varations: [...] } }
      final variations = content is Map ? content['varations'] : content;
      if (variations == null) return [];
      return (variations as List)
          .map((e) => VtuVariationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data?['error']?.toString() ?? 'Failed to load bundles',);
    }
  }

  Future<VtuMerchantModel?> verifyMerchant({
    required String serviceId,
    required String billersCode,
    String? type,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/vtu/verify-merchant',
        data: {
          'serviceID': serviceId,
          'billersCode': billersCode,
          if (type != null) 'type': type,
        },
      );
      final content = res.data?['content'];
      if (content == null) return null;
      return VtuMerchantModel.fromJson(content as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data?['error']?.toString() ?? 'Verification failed',);
    }
  }

  Future<Map<String, dynamic>> purchase({
    required String serviceType,
    required String provider,
    required double amount,
    required String recipient,
    String? variationCode,
    String? billersCode,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/vtu/purchase',
        data: {
          'serviceType': serviceType,
          'provider': provider,
          'amount': amount,
          'recipient': recipient,
          if (variationCode != null) 'variationCode': variationCode,
          if (billersCode != null) 'billersCode': billersCode,
          'paymentMethod': 'WALLET',
        },
      );
      return res.data ?? {};
    } on DioException catch (e) {
      final msg = e.response?.data?['error']?.toString() ?? 'Purchase failed';
      throw ServerException(msg, statusCode: e.response?.statusCode);
    }
  }

  Future<List<VtuTransactionModel>> fetchHistory() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw const AuthException('Not authenticated');

      // Read directly from Supabase — vtu_transactions has user_id with RLS
      final rows = await _client
          .from('vtu_transactions')
          .select(
              'id, service_type, provider, amount, recipient, status, reference, created_at',)
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return (rows as List).map((r) {
        final m = r as Map<String, dynamic>;
        return VtuTransactionModel(
          id: m['id'] as String,
          serviceType: m['service_type'] as String,
          provider: m['provider'] as String,
          amount: double.parse(m['amount'].toString()),
          recipient: m['recipient'] as String,
          status: m['status'] as String,
          reference: m['reference'] as String,
          createdAt: m['created_at'] as String,
        );
      }).toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }
}

final vtuDatasourceProvider = Provider<VtuDatasource>((ref) {
  return VtuDatasource(ref.watch(dioProvider), ref.watch(supabaseClientProvider));
});
