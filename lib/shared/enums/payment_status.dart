enum PaymentStatus {
  pending,
  success,
  failed,
  refunded;

  static PaymentStatus fromString(String value) =>
      PaymentStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == value.toLowerCase(),
        orElse: () => PaymentStatus.pending,
      );

  String get displayName => switch (this) {
        PaymentStatus.pending => 'Pending',
        PaymentStatus.success => 'Success',
        PaymentStatus.failed => 'Failed',
        PaymentStatus.refunded => 'Refunded',
      };

  bool get isSuccessful => this == PaymentStatus.success;
  bool get isFailed => this == PaymentStatus.failed;
}
