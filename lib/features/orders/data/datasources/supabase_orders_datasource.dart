import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/order_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

const _kOrderSelect = '''
  id, order_number, status, payment_status, total, created_at,
  order_items(
    id, quantity, price, total,
    product:core_products!product_id(
      id, name,
      cover:core_media!product_cover_image_id(media)
    )
  )
''';

const _kAddressSelect =
    'id, full_name, phone, street, city, state, country, postal_code, is_default';

class SupabaseOrdersDatasource {
  final SupabaseClient _client;
  final Dio _dio;

  const SupabaseOrdersDatasource(this._client, this._dio);

  // ─── Orders ──────────────────────────────────────────────────────────────

  Future<List<OrderModel>> getMyOrders() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('orders')
          .select(_kOrderSelect)
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      throw ServerException('Failed to load orders: ${e.toString()}');
    }
  }

  Future<OrderModel> getOrderById(String id) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw const UnauthorizedException();

      final response = await _client
          .from('orders')
          .select(_kOrderSelect)
          .eq('id', id)
          .eq('user_id', userId)
          .single();

      return OrderModel.fromJson(Map<String, dynamic>.from(response as Map));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') throw const NotFoundException('Order not found');
      throw ServerException(e.message);
    } catch (e) {
      throw const ServerException('Failed to load order.');
    }
  }

  // ─── Addresses (direct Supabase read + write) ─────────────────────────────

  Future<List<AddressModel>> getAddresses() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('addresses')
          .select(_kAddressSelect)
          .eq('user_id', userId)
          .order('is_default', ascending: false);

      return (response as List)
          .map((e) => AddressModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<AddressModel> createAddress({
    required String fullName,
    required String phone,
    required String street,
    required String city,
    required String state,
    String country = 'Nigeria',
    String? postalCode,
    bool isDefault = false,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw const UnauthorizedException();

      if (isDefault) {
        // Clear existing default
        await _client
            .from('addresses')
            .update({'is_default': false})
            .eq('user_id', userId);
      }

      final row = await _client.from('addresses').insert({
        'user_id': userId,
        'full_name': fullName,
        'phone': phone,
        'street': street,
        'city': city,
        'state': state,
        'country': country,
        if (postalCode != null) 'postal_code': postalCode,
        'is_default': isDefault,
      }).select(_kAddressSelect).single();

      return AddressModel.fromJson(Map<String, dynamic>.from(row as Map));
    } catch (e) {
      throw const ServerException('Failed to save address.');
    }
  }

  // ─── Place order (Next.js API) ────────────────────────────────────────────

  Future<OrderModel> placeOrder({
    required String addressId,
    String? notes,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/orders',
        data: {'addressId': addressId, if (notes != null) 'notes': notes},
      );
      return OrderModel.fromJson(response.data!);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ?? 'Failed to place order.';
      throw ServerException(msg, statusCode: e.response?.statusCode);
    } catch (e) {
      throw const ServerException('Failed to place order.');
    }
  }
}

// Provider factory helper (used in orders_provider.dart)
final ordersDataSourceProvider = Provider<SupabaseOrdersDatasource>((ref) {
  final client = ref.watch(
    // Access supabase client via its provider
    Provider((r) => Supabase.instance.client),
  );
  final dio = ref.watch(dioProvider);
  return SupabaseOrdersDatasource(client, dio);
}, name: 'ordersDataSourceProvider',);
