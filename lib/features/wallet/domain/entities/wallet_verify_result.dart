/// Sealed result type for wallet top-up verification.
///
/// Backend returns:
///   200 { status: 'success', paymentType, reference, credited } → [VerifySuccess]
///   200 { status: 'pending', retryAfterSeconds }                → [VerifyPending]
///   200 { status: 'failed', message }                           → [VerifyFailed]
///   401                                                          → [VerifyError] (isUnauthorized)
///   404                                                          → [VerifyFailed] (not found)
///   4xx / 5xx / network                                         → [VerifyError]
sealed class WalletVerifyResult {
  const WalletVerifyResult();
}

final class VerifySuccess extends WalletVerifyResult {
  const VerifySuccess({required this.message, this.paymentType, this.credited = false});
  final String message;
  final String? paymentType;
  final bool credited;
}

final class VerifyPending extends WalletVerifyResult {
  const VerifyPending({this.retryAfterSeconds = 4});
  final int retryAfterSeconds;
}

final class VerifyFailed extends WalletVerifyResult {
  const VerifyFailed(this.message);
  final String message;
}

final class VerifyError extends WalletVerifyResult {
  const VerifyError(this.message, {this.isNetwork = false, this.isUnauthorized = false});
  final String message;
  final bool isNetwork;
  final bool isUnauthorized;
}
