import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/supabase/supabase_module.dart';
import '../../../products/data/models/product_model.dart';
import '../models/subscription_models.dart';

class VendorDatasource {
  final Dio _dio;
  final SupabaseClient _client;

  static const _productSelect =
      'id, name, description, price, compare_price, in_stock, unlist, created_at, '
      'category:core_category!category_id(id, name), '
      'seller:core_user!seller_id(id, first_name, last_name), '
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
      final rows = await _client
          .from('core_subscriptionplan')
          .select('id, title, price, no_of_product_upload_per_month, plan_description, is_active, description')
          .eq('is_active', true)
          .order('price');
      return (rows as List)
          .map((r) => SubscriptionPlan.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Failed to load plans: $e');
    }
  }

  Future<VendorSubscription?> getMySubscription() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;
      final rows = await _client
          .from('vendor_subscriptions')
          .select('id, user_id, plan_id, status, start_date, end_date')
          .eq('user_id', userId)
          .eq('status', 'ACTIVE');
      if ((rows as List).isEmpty) return null;
      return VendorSubscription.fromJson(rows.first as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> subscribeToPlan(String planId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw const AuthException('Not authenticated');
      await _dio.post<void>(
        '/api/v1/subscriptions/vendor/$userId/subscribe/$planId',
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['error']?.toString() ?? 'Subscription failed',
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
