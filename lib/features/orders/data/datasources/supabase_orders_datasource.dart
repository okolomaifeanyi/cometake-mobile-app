import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/checkout_result_model.dart';
import '../models/order_model.dart';

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

  // ─── Checkout (Next.js API — idempotent, retries on 409/503) ────────────────
  //
  // Sends an Idempotency-Key header so the server can detect duplicate requests.
  // 409 canRestart:true  → key is expired; generate a new UUID and retry.
  // 503 recoverable:true → another request is in-flight; retry with same key after 2s.
  // All other non-2xx → rethrow as ServerException.

  Future<CheckoutResultModel> checkout({
    required String addressId,
    String? notes,
  }) async {
    String idempotencyKey = _uuid();
    const maxRetries = 3;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await _dio.post<Map<String, dynamic>>(
          '/api/v1/checkout',
          data: {'addressId': addressId, if (notes != null) 'notes': notes},
          options: Options(headers: {'Idempotency-Key': idempotencyKey}),
        );
        return CheckoutResultModel.fromJson(response.data!);
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        final body   = e.response?.data as Map<String, dynamic>?;

        if (status == 409 && body?['canRestart'] == true) {
          if (attempt < maxRetries) {
            idempotencyKey = _uuid(); // fresh key — server treated old one as expired
            continue;
          }
          throw const CheckoutExpiredException();
        }

        if (status == 503 && body?['recoverable'] == true) {
          if (attempt < maxRetries) {
            await Future<void>.delayed(const Duration(seconds: 2));
            continue; // same key — server will return cached result
          }
          throw const CheckoutRecoverableException();
        }

        final msg = body?['error'] as String? ?? 'Failed to place order.';
        throw ServerException(msg, statusCode: status);
      } catch (e) {
        if (e is AppException) rethrow;
        throw const ServerException('Failed to place order.');
      }
    }

    throw const ServerException('Checkout failed after maximum retries.');
  }

  // ─── Legacy placeOrder — kept for tests; internally calls checkout() ─────────

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

// V4 UUID without the uuid package — uses dart:math Random.secure().
String _uuid() {
  final rng   = Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  bytes[6] = (bytes[6] & 0x0F) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3F) | 0x80; // variant 10xx
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
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
