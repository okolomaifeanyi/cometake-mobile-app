import '../../../auth/domain/entities/auth_user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDatasource _datasource;
  const ProfileRepositoryImpl(this._datasource);

  @override
  Future<AuthUser> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
  }) async {
    final model = await _datasource.updateProfile(
      userId: userId,
      fullName: fullName,
      phone: phone,
    );
    return model.toEntity();
  }

  @override
  Future<AuthUser> updateAvatarUrl({
    required String userId,
    required String avatarUrl,
  }) async {
    final model = await _datasource.updateAvatarUrl(
      userId: userId,
      avatarUrl: avatarUrl,
    );
    return model.toEntity();
  }
}
