class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final String? description;
  final List<String> features;
  final int productLimit;
  final bool isActive;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.features,
    required this.productLimit,
    required this.isActive,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final raw = json['plan_description'];
    final features = raw is List
        ? raw
            .map((e) => (e as Map)['body'] as String? ?? '')
            .where((s) => s.isNotEmpty)
            .toList()
        : <String>[];
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      features: features,
      productLimit: (json['no_of_product_upload_per_month'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
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

  const VendorSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  bool get isActive => status == 'ACTIVE' && endDate.isAfter(DateTime.now());

  factory VendorSubscription.fromJson(Map<String, dynamic> json) {
    return VendorSubscription(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      planId: json['plan_id'] as String,
      status: json['status'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }
}
