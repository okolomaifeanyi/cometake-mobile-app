import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'app_exception.dart';
import 'failure.dart';

final _log = Logger();

abstract final class ErrorHandler {
  static Failure handle(Object error, {StackTrace? stackTrace}) {
    if (kDebugMode) _log.e('Error caught', error: error, stackTrace: stackTrace);

    return switch (error) {
      final AuthException e => Failure.auth(message: e.message),
      final UnauthorizedException e => Failure.unauthorized(message: e.message),
      final NetworkException e => Failure.network(message: e.message),
      final ServerException e =>
        Failure.server(message: e.message, statusCode: e.statusCode),
      NotFoundException _ => const Failure.notFound(),
      final ValidationException e => Failure.validation(message: e.message),
      final UploadException e => Failure.upload(message: e.message),
      CacheException _ => const Failure.unknown(),
      final DioException e => _fromDio(e),
      _ => const Failure.unknown(),
    };
  }

  static Failure _fromDio(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.connectionError =>
        const Failure.network(),
      DioExceptionType.badResponse => _fromResponse(e),
      DioExceptionType.cancel =>
        const Failure.unknown(message: 'Request cancelled'),
      _ => const Failure.network(),
    };
  }

  static Failure _fromResponse(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final message = _extractMessage(data) ?? 'Server error';

    return switch (statusCode) {
      401 => const Failure.unauthorized(),
      403 => const Failure.auth(message: 'Access denied'),
      404 => const Failure.notFound(),
      422 => Failure.validation(message: message),
      _ => Failure.server(message: message, statusCode: statusCode),
    };
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? data['error'] ?? data['detail'])?.toString();
    }
    return null;
  }
}
