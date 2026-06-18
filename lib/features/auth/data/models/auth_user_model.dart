import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/enums/user_role.dart';
import '../../domain/entities/auth_user.dart';

part 'auth_user_model.freezed.dart';
part 'auth_user_model.g.dart';

@freezed
class AuthUserModel with _$AuthUserModel {
  const factory AuthUserModel({
    required String id,
    required String email,
    @JsonKey(name: 'full_name') required String fullName,
    String? phone,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @Default('customer') String role,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _AuthUserModel;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) =>
      _$AuthUserModelFromJson(json);
}

extension AuthUserModelX on AuthUserModel {
  AuthUser toEntity() => AuthUser(
        id: id,
        email: email,
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
        role: UserRole.fromString(role),
        isVerified: isVerified,
        createdAt: createdAt,
      );
}
