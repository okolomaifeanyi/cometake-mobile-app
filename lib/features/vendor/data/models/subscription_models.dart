class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final String? description;
  final List<String> features;
  final int productLimit;
  final bool isActive;
  final String billingPeriod;
  final int? durationDays;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.features,
    required this.productLimit,
    required this.isActive,
    required this.billingPeriod,
    this.durationDays,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'];
    final features = rawFeatures is List
        ? rawFeatures.map((e) => e.toString()).toList()
        : <String>[];
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      features: features,
      productLimit: (json['productLimit'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      billingPeriod: json['billingPeriod'] as String? ?? 'yearly',
      durationDays: (json['durationDays'] as num?)?.toInt(),
    );
  }
}

class VendorSubscription {
  final String id;
  final String userId;
  final String planId;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final SubscriptionPlan? plan;

  const VendorSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.plan,
  });

  bool get isActive => status == 'ACTIVE' && endDate.isAfter(DateTime.now());

  factory VendorSubscription.fromJson(Map<String, dynamic> json) {
    final rawPlan = json['plan'];
    return VendorSubscription(
      id: json['id'] as String,
      userId: json['userId'] as String,
      planId: json['planId'] as String,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      plan: rawPlan is Map<String, dynamic>
          ? SubscriptionPlan.fromJson(rawPlan)
          : null,
    );
  }
}
