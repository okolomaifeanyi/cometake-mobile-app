import '../../../auth/data/models/auth_user_model.dart';

abstract class ProfileDatasource {
  Future<AuthUserModel> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
  });

  Future<AuthUserModel> updateAvatarUrl({
    required String userId,
    required String avatarUrl,
  });
}
