import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/config/remote_config.dart';
import '../../../../shared/enums/order_status.dart';
import '../../../../shared/enums/payment_status.dart';
import '../../domain/entities/order.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

// ─── Nested models ─────────────────────────────────────────────────────────

@freezed
class OrderCoverModel with _$OrderCoverModel {
  const factory OrderCoverModel({required String media}) = _OrderCoverModel;
  factory OrderCoverModel.fromJson(Map<String, dynamic> json) =>
      _$OrderCoverModelFromJson(json);
}

@freezed
class OrderProductModel with _$OrderProductModel {
  const factory OrderProductModel({
    required String id,
    required String name,
    OrderCoverModel? cover,
  }) = _OrderProductModel;
  factory OrderProductModel.fromJson(Map<String, dynamic> json) =>
      _$OrderProductModelFromJson(json);
}

@freezed
class OrderItemModel with _$OrderItemModel {
  const factory OrderItemModel({
    required String id,
    required int quantity,
    required double price,
    required double total,
    OrderProductModel? product,
  }) = _OrderItemModel;
  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);
}

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    @JsonKey(name: 'order_number') required String orderNumber,
    required double total,
    @Default('PENDING') String status,
    @JsonKey(name: 'payment_status') @Default('PENDING') String paymentStatus,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'order_items') @Default([]) List<OrderItemModel> orderItems,
  }) = _OrderModel;
  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}

extension OrderModelX on OrderModel {
  Order toEntity() => Order(
        id: id,
        orderNumber: orderNumber,
        total: total,
        status: OrderStatus.fromString(status),
        paymentStatus: PaymentStatus.fromString(paymentStatus),
        createdAt: createdAt,
        items: orderItems.map((i) => i.toEntity()).toList(),
      );
}

extension OrderItemModelX on OrderItemModel {
  OrderItem toEntity() => OrderItem(
        id: id,
        quantity: quantity,
        price: price,
        total: total,
        product: product != null
            ? OrderProduct(
                id: product!.id,
                name: product!.name,
                imageUrl: product!.cover?.media != null
                    ? _mediaToUrl(product!.cover!.media)
                    : null,
              )
            : null,
      );

  static String _mediaToUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final withoutExt = path.replaceAll(RegExp(r'\.[^/.]+$'), '');
    final cloud = RemoteConfig.instance.cloudinaryCloudName.isNotEmpty
        ? RemoteConfig.instance.cloudinaryCloudName
        : 'dxi9khzro';
    return 'https://res.cloudinary.com/$cloud/image/upload/f_auto,q_auto,w_400,c_fill/$withoutExt';
  }
}

// ─── Address model ───────────────────────────────────────────────────────────

@freezed
class AddressModel with _$AddressModel {
  const factory AddressModel({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    required String phone,
    required String street,
    required String city,
    required String state,
    @Default('Nigeria') String country,
    @JsonKey(name: 'postal_code') String? postalCode,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
  }) = _AddressModel;
  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);
}

extension AddressModelX on AddressModel {
  Address toEntity() => Address(
        id: id,
        fullName: fullName,
        phone: phone,
        street: street,
        city: city,
        state: state,
        country: country,
        postalCode: postalCode,
        isDefault: isDefault,
      );
}
