sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

final class AuthException extends AppException {
  const AuthException(super.message);
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized — please sign in again']);
}

final class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
}

final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);
}

final class ValidationException extends AppException {
  const ValidationException(super.message);
}

final class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

final class UploadException extends AppException {
  const UploadException([super.message = 'File upload failed']);
}
