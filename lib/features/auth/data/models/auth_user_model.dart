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

/// Maps a raw `core_user` Postgres row to [AuthUserModel].
/// The DB stores first_name/last_name/photo/verified_email rather than
/// the json_serializable field names used by this model.
AuthUserModel authUserModelFromRow(Map<String, dynamic> row) {
  final firstName = row['first_name'] as String? ?? '';
  final lastName = row['last_name'] as String? ?? '';
  final fullName = [firstName, lastName]
      .where((s) => s.isNotEmpty)
      .join(' ');

  String role = 'customer';
  if (row['is_superuser'] == true || row['is_staff'] == true) {
    role = 'admin';
  } else if (row['is_seller'] == true) {
    role = 'seller';
  }

  return AuthUserModel(
    id: row['id'] as String,
    email: row['email'] as String? ?? '',
    fullName: fullName,
    phone: row['phone'] as String?,
    avatarUrl: row['photo'] as String?,
    role: role,
    isVerified: row['verified_email'] as bool? ?? false,
    createdAt: row['created_at'] != null
        ? DateTime.tryParse(row['created_at'].toString())
        : null,
  );
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
