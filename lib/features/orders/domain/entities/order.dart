import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/enums/order_status.dart';
import '../../../../shared/enums/payment_status.dart';

part 'order.freezed.dart';

@freezed
class OrderProduct with _$OrderProduct {
  const factory OrderProduct({
    required String id,
    required String name,
    String? imageUrl,
  }) = _OrderProduct;
}

@freezed
class OrderItem with _$OrderItem {
  const OrderItem._();

  const factory OrderItem({
    required String id,
    required int quantity,
    required double price,
    required double total,
    OrderProduct? product,
  }) = _OrderItem;
}

@freezed
class Order with _$Order {
  const Order._();

  const factory Order({
    required String id,
    required String orderNumber,
    required double total,
    @Default(OrderStatus.pending) OrderStatus status,
    @Default(PaymentStatus.pending) PaymentStatus paymentStatus,
    required DateTime createdAt,
    @Default([]) List<OrderItem> items,
  }) = _Order;

  int get itemCount => items.fold(0, (s, i) => s + i.quantity);
}

@freezed
class Address with _$Address {
  const Address._();

  const factory Address({
    required String id,
    required String fullName,
    required String phone,
    required String street,
    required String city,
    required String state,
    @Default('Nigeria') String country,
    String? postalCode,
    @Default(false) bool isDefault,
  }) = _Address;

  String get summary => '$street, $city, $state';
}
