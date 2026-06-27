class CheckoutResultModel {
  final String orderId;
  final String paymentId;
  final String? authorizationUrl;
  final String? reference;
  final String correlationId;
  final bool cached;

  const CheckoutResultModel({
    required this.orderId,
    required this.paymentId,
    this.authorizationUrl,
    this.reference,
    required this.correlationId,
    this.cached = false,
  });

  factory CheckoutResultModel.fromJson(Map<String, dynamic> json) =>
      CheckoutResultModel(
        orderId:          json['orderId'] as String,
        paymentId:        json['paymentId'] as String,
        authorizationUrl: json['authorizationUrl'] as String?,
        reference:        json['reference'] as String?,
        correlationId:    json['correlationId'] as String,
        cached:           json['cached'] as bool? ?? false,
      );
}
