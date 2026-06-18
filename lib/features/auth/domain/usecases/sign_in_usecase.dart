import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repository;
  const SignInUseCase(this._repository);

  Future<AuthUser> execute({
    required String email,
    required String password,
  }) =>
      _repository.signIn(email: email, password: password);
}
