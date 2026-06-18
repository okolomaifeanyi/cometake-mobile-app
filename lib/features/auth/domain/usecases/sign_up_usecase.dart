import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;
  const SignUpUseCase(this._repository);

  Future<AuthUser> execute({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) =>
      _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
}
