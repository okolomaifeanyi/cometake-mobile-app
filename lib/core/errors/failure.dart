import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.network({
    @Default('No internet connection') String message,
  }) = NetworkFailure;

  const factory Failure.auth({required String message}) = AuthFailure;

  const factory Failure.unauthorized({
    @Default('Session expired — please sign in again') String message,
  }) = UnauthorizedFailure;

  const factory Failure.server({
    required String message,
    int? statusCode,
  }) = ServerFailure;

  const factory Failure.notFound({
    @Default('Resource not found') String message,
  }) = NotFoundFailure;

  const factory Failure.validation({required String message}) = ValidationFailure;

  const factory Failure.upload({
    @Default('File upload failed') String message,
  }) = UploadFailure;

  const factory Failure.unknown({
    @Default('Something went wrong') String message,
  }) = UnknownFailure;
}

extension FailureMessage on Failure {
  String get displayMessage => when(
        network: (msg) => msg,
        auth: (msg) => msg,
        unauthorized: (msg) => msg,
        server: (msg, _) => msg,
        notFound: (msg) => msg,
        validation: (msg) => msg,
        upload: (msg) => msg,
        unknown: (msg) => msg,
      );
}
