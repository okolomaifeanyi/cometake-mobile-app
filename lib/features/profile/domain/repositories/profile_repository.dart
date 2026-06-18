import '../../../auth/domain/entities/auth_user.dart';

abstract class ProfileRepository {
  Future<AuthUser> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
  });

  Future<AuthUser> updateAvatarUrl({
    required String userId,
    required String avatarUrl,
  });
}
