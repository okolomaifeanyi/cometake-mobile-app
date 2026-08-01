class SubscriptionCheckoutResultModel {
  final String? authorizationUrl;
  final String? reference;

  const SubscriptionCheckoutResultModel({
    this.authorizationUrl,
    this.reference,
  });

  factory SubscriptionCheckoutResultModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionCheckoutResultModel(
      authorizationUrl: json['authorization_url'] as String?,
      reference: json['reference'] as String?,
    );
  }
}
