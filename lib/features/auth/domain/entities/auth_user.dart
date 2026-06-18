import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/enums/user_role.dart';

part 'auth_user.freezed.dart';

@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String email,
    required String fullName,
    String? phone,
    String? avatarUrl,
    @Default(UserRole.customer) UserRole role,
    @Default(false) bool isVerified,
    DateTime? createdAt,
  }) = _AuthUser;
}
