enum UserRole {
  customer,
  vendor,
  admin;

  static UserRole fromString(String value) => UserRole.values.firstWhere(
        (r) => r.name.toLowerCase() == value.toLowerCase(),
        orElse: () => UserRole.customer,
      );

  bool get isVendor => this == UserRole.vendor;
  bool get isAdmin => this == UserRole.admin;
  bool get isCustomer => this == UserRole.customer;
  bool get canSell => isVendor || isAdmin;
}
