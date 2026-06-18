import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _datasource;
  const AuthRepositoryImpl(this._datasource);

  @override
  Future<AuthUser?> getCurrentUser() async {
    final model = await _datasource.getCurrentUser();
    return model?.toEntity();
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final model = await _datasource.signIn(email: email, password: password);
    return model.toEntity();
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final model = await _datasource.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
    return model.toEntity();
  }

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  Future<void> sendPhoneOtp({required String phone}) =>
      _datasource.sendPhoneOtp(phone: phone);

  @override
  Future<void> verifyPhoneOtp({
    required String phone,
    required String token,
  }) =>
      _datasource.verifyPhoneOtp(phone: phone, token: token);

  @override
  Future<void> resetPassword({required String email}) =>
      _datasource.resetPassword(email: email);
}
