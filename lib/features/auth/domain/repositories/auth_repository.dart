import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser?> getCurrentUser();
  Future<AuthUser> signIn({required String email, required String password});
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });
  Future<void> signOut();
  Future<void> sendPhoneOtp({required String phone});
  Future<void> verifyPhoneOtp({required String phone, required String token});
  Future<void> resetPassword({required String email});
}
