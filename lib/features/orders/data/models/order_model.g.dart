// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderCoverModelImpl _$$OrderCoverModelImplFromJson(
        Map<String, dynamic> json) =>
    _$OrderCoverModelImpl(
      media: json['media'] as String,
    );

Map<String, dynamic> _$$OrderCoverModelImplToJson(
        _$OrderCoverModelImpl instance) =>
    <String, dynamic>{
      'media': instance.media,
    };

_$OrderProductModelImpl _$$OrderProductModelImplFromJson(
        Map<String, dynamic> json) =>
    _$OrderProductModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      cover: json['cover'] == null
          ? null
          : OrderCoverModel.fromJson(json['cover'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$OrderProductModelImplToJson(
        _$OrderProductModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cover': instance.cover,
    };

_$OrderItemModelImpl _$$OrderItemModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemModelImpl(
      id: json['id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      product: json['product'] == null
          ? null
          : OrderProductModel.fromJson(json['product'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$OrderItemModelImplToJson(
        _$OrderItemModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quantity': instance.quantity,
      'price': instance.price,
      'total': instance.total,
      'product': instance.product,
    };

_$OrderModelImpl _$$OrderModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderModelImpl(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String? ?? 'PENDING',
      paymentStatus: json['payment_status'] as String? ?? 'PENDING',
      createdAt: DateTime.parse(json['created_at'] as String),
      orderItems: (json['order_items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$OrderModelImplToJson(_$OrderModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_number': instance.orderNumber,
      'total': instance.total,
      'status': instance.status,
      'payment_status': instance.paymentStatus,
      'created_at': instance.createdAt.toIso8601String(),
      'order_items': instance.orderItems,
    };

_$AddressModelImpl _$$AddressModelImplFromJson(Map<String, dynamic> json) =>
    _$AddressModelImpl(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String? ?? 'Nigeria',
      postalCode: json['postal_code'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
    );

Map<String, dynamic> _$$AddressModelImplToJson(_$AddressModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'postal_code': instance.postalCode,
      'is_default': instance.isDefault,
    };
