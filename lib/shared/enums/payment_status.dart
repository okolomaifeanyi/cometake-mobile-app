enum PaymentStatus {
  pending,
  success,
  failed,
  refunded;

  static PaymentStatus fromString(String value) {
    // Handle web API variants: COMPLETED → success, PAID → success
    final lower = value.toLowerCase();
    if (lower == 'completed' || lower == 'paid') return PaymentStatus.success;
    return PaymentStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == lower,
      orElse: () => PaymentStatus.pending,
    );
  }

  String get displayName => switch (this) {
        PaymentStatus.pending => 'Pending',
        PaymentStatus.success => 'Success',
        PaymentStatus.failed => 'Failed',
        PaymentStatus.refunded => 'Refunded',
      };

  bool get isSuccessful => this == PaymentStatus.success;
  bool get isFailed => this == PaymentStatus.failed;
}
