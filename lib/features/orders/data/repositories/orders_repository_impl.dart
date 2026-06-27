import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/supabase_orders_datasource.dart';
import '../models/checkout_result_model.dart';
import '../models/order_model.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final SupabaseOrdersDatasource _datasource;
  const OrdersRepositoryImpl(this._datasource);

  @override
  Future<List<Order>> getMyOrders() async {
    try {
      final models = await _datasource.getMyOrders();
      return models.map((m) => m.toEntity()).toList();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ServerException('Could not load orders.');
    }
  }

  @override
  Future<Order> getOrderById(String id) async {
    try {
      return (await _datasource.getOrderById(id)).toEntity();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ServerException('Could not load order.');
    }
  }

  @override
  Future<List<Address>> getAddresses() async {
    final models = await _datasource.getAddresses();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Address> createAddress({
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
      final model = await _datasource.createAddress(
        fullName: fullName,
        phone: phone,
        street: street,
        city: city,
        state: state,
        country: country,
        postalCode: postalCode,
        isDefault: isDefault,
      );
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ServerException('Could not save address.');
    }
  }

  @override
  Future<CheckoutResultModel> checkout({
    required String addressId,
    String? notes,
  }) async {
    try {
      return await _datasource.checkout(addressId: addressId, notes: notes);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ServerException('Could not complete checkout.');
    }
  }

  @override
  Future<Order> placeOrder({required String addressId, String? notes}) async {
    try {
      return (await _datasource.placeOrder(addressId: addressId, notes: notes))
          .toEntity();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ServerException('Could not place order.');
    }
  }
}
