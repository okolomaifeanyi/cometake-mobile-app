import '../models/auth_user_model.dart';

abstract class AuthDatasource {
  Future<AuthUserModel?> getCurrentUser();
  Future<AuthUserModel> signIn({required String email, required String password});
  Future<AuthUserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });
  Future<void> signOut();
  Future<void> sendPhoneOtp({required String phone});
  Future<void> verifyPhoneOtp({required String phone, required String token});
  Future<void> resetPassword({required String email});
  Future<void> signInWithGoogle();
}
