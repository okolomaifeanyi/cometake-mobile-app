import '../entities/order.dart';

abstract class OrdersRepository {
  Future<List<Order>> getMyOrders();
  Future<Order> getOrderById(String id);
  Future<List<Address>> getAddresses();
  Future<Address> createAddress({
    required String fullName,
    required String phone,
    required String street,
    required String city,
    required String state,
    String country = 'Nigeria',
    String? postalCode,
    bool isDefault = false,
  });
  Future<Order> placeOrder({required String addressId, String? notes});
}
