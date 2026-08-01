import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/supabase/supabase_module.dart';
import '../../../products/data/models/product_model.dart';
import '../models/subscription_checkout_result_model.dart';
import '../models/subscription_models.dart';

class VendorDatasource {
  final Dio _dio;
  final SupabaseClient _client;

  // Omit seller join — core_user has no SELECT RLS policy; the join kills the
  // entire query even for authenticated users. Vendor doesn't need their own info.
  static const _productSelect =
      'id, name, description, price, compare_price, in_stock, unlist, created_at, '
      'sku, category_id, seller_id, '
      'category:core_category!category_id(id, name), '
      'cover:core_media!product_cover_image_id(media)';

  const VendorDatasource(this._dio, this._client);

  Future<List<ProductModel>> fetchMyProducts({int page = 1, int limit = 20}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw const AuthException('Not authenticated');

      final from = (page - 1) * limit;
      final to = from + limit - 1;

      final rows = await _client
          .from('core_products')
          .select(_productSelect)
          .eq('seller_id', userId)
          .order('created_at', ascending: false)
          .range(from, to);

      return (rows as List)
          .map((r) => ProductModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<Map<String, dynamic>> createProduct(
      Map<String, dynamic> dto,) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/products',
        data: dto,
      );
      return res.data ?? {};
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data?['error']?.toString() ?? 'Failed to create product',
          statusCode: e.response?.statusCode,);
    }
  }

  Future<Map<String, dynamic>> updateProduct(
      String id, Map<String, dynamic> dto,) async {
    try {
      final res = await _dio.put<Map<String, dynamic>>(
        '/api/v1/products/$id',
        data: dto,
      );
      return res.data ?? {};
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data?['error']?.toString() ?? 'Failed to update product',
          statusCode: e.response?.statusCode,);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete<void>('/api/v1/products/$id');
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data?['error']?.toString() ?? 'Failed to delete product',
          statusCode: e.response?.statusCode,);
    }
  }

  Future<List<SubscriptionPlan>> getPlans() async {
    try {
      final res = await _dio.get<List<dynamic>>('/api/v1/subscriptions/plans');
      final rows = res.data ?? [];
      return rows
          .map((r) => SubscriptionPlan.fromJson(r as Map<String, dynamic>))
          .where((p) => p.isActive)
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['error']?.toString() ?? 'Failed to load plans',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<VendorSubscription?> getMySubscription() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/subscriptions/vendor/$userId',
      );
      return VendorSubscription.fromJson(res.data ?? {});
    } on DioException catch (e) {
      // 404 means "no subscription yet" — a valid, expected state, not an error.
      if (e.response?.statusCode == 404) return null;
      throw ServerException(
        e.response?.data?['error']?.toString() ?? 'Failed to load subscription',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<SubscriptionCheckoutResultModel> checkoutPlan(String planId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw const AuthException('Not authenticated');
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/subscriptions/vendor/$userId/checkout/$planId',
      );
      return SubscriptionCheckoutResultModel.fromJson(res.data ?? {});
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['error']?.toString() ?? 'Checkout failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

final vendorDatasourceProvider = Provider<VendorDatasource>((ref) {
  return VendorDatasource(
    ref.watch(dioProvider),
    ref.watch(supabaseClientProvider),
  );
});
