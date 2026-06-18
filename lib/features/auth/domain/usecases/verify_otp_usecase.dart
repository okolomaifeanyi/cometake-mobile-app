import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository _repository;
  const VerifyOtpUseCase(this._repository);

  Future<void> execute({required String phone, required String token}) =>
      _repository.verifyPhoneOtp(phone: phone, token: token);
}
