enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded;

  static OrderStatus fromString(String value) => OrderStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == value.toLowerCase(),
        orElse: () => OrderStatus.pending,
      );

  String get displayName => switch (this) {
        OrderStatus.pending => 'Pending',
        OrderStatus.confirmed => 'Confirmed',
        OrderStatus.processing => 'Processing',
        OrderStatus.shipped => 'Shipped',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.cancelled => 'Cancelled',
        OrderStatus.refunded => 'Refunded',
      };

  bool get isActive =>
      this == OrderStatus.confirmed || this == OrderStatus.processing || this == OrderStatus.shipped;

  bool get isFinal =>
      this == OrderStatus.delivered ||
      this == OrderStatus.cancelled ||
      this == OrderStatus.refunded;
}
