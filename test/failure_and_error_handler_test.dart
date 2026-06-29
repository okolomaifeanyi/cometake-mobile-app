import 'package:cometake/core/errors/app_exception.dart';
import 'package:cometake/core/errors/error_handler.dart';
import 'package:cometake/core/errors/failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Failure variants: construction ────────────────────────────────────────

  group('Failure.network', () {
    test('uses default message when none provided', () {
      const f = Failure.network();
      expect(f, isA<NetworkFailure>());
      expect(f.displayMessage, 'No internet connection');
    });

    test('accepts a custom message', () {
      const f = Failure.network(message: 'No WiFi available');
      expect(f, isA<NetworkFailure>());
      expect(f.displayMessage, 'No WiFi available');
    });
  });

  group('Failure.auth', () {
    test('stores the provided message', () {
      const f = Failure.auth(message: 'Invalid credentials');
      expect(f, isA<AuthFailure>());
      expect(f.displayMessage, 'Invalid credentials');
    });
  });

  group('Failure.unauthorized', () {
    test('uses default message when none provided', () {
      const f = Failure.unauthorized();
      expect(f, isA<UnauthorizedFailure>());
      expect(f.displayMessage, 'Session expired — please sign in again');
    });

    test('accepts a custom message', () {
      const f = Failure.unauthorized(message: 'Token revoked');
      expect(f.displayMessage, 'Token revoked');
    });
  });

  group('Failure.server', () {
    test('stores message and optional statusCode', () {
      const f = Failure.server(message: 'Gateway timeout', statusCode: 504);
      expect(f, isA<ServerFailure>());
      expect(f.displayMessage, 'Gateway timeout');
      expect((f as ServerFailure).statusCode, 504);
    });

    test('statusCode can be null', () {
      const f = Failure.server(message: 'Unknown server error');
      expect((f as ServerFailure).statusCode, isNull);
    });
  });

  group('Failure.notFound', () {
    test('uses default message', () {
      const f = Failure.notFound();
      expect(f, isA<NotFoundFailure>());
      expect(f.displayMessage, 'Resource not found');
    });
  });

  group('Failure.validation', () {
    test('stores validation message', () {
      const f = Failure.validation(message: 'Email is required');
      expect(f, isA<ValidationFailure>());
      expect(f.displayMessage, 'Email is required');
    });
  });

  group('Failure.upload', () {
    test('uses default message when none provided', () {
      const f = Failure.upload();
      expect(f, isA<UploadFailure>());
      expect(f.displayMessage, 'File upload failed');
    });

    test('accepts a custom message', () {
      const f = Failure.upload(message: 'Image too large');
      expect(f.displayMessage, 'Image too large');
    });
  });

  group('Failure.unknown', () {
    test('uses default fallback message', () {
      const f = Failure.unknown();
      expect(f, isA<UnknownFailure>());
      expect(f.displayMessage, 'Something went wrong');
    });

    test('accepts a custom message', () {
      const f = Failure.unknown(message: 'Request cancelled');
      expect(f.displayMessage, 'Request cancelled');
    });
  });

  // ── ErrorHandler.handle: AppException dispatch ────────────────────────────

  group('ErrorHandler.handle — AppException types', () {
    test('AuthException → AuthFailure with the exception message', () {
      const ex = AuthException('Invalid token');
      final f = ErrorHandler.handle(ex);
      expect(f, isA<AuthFailure>());
      expect(f.displayMessage, 'Invalid token');
    });

    test('UnauthorizedException (default) → UnauthorizedFailure', () {
      const ex = UnauthorizedException();
      final f = ErrorHandler.handle(ex);
      expect(f, isA<UnauthorizedFailure>());
    });

    test('UnauthorizedException (custom) → UnauthorizedFailure with that message', () {
      const ex = UnauthorizedException('Session timed out');
      final f = ErrorHandler.handle(ex);
      expect(f, isA<UnauthorizedFailure>());
      expect(f.displayMessage, 'Session timed out');
    });

    test('NetworkException → NetworkFailure', () {
      const ex = NetworkException();
      final f = ErrorHandler.handle(ex);
      expect(f, isA<NetworkFailure>());
    });

    test('ServerException → ServerFailure preserving statusCode', () {
      const ex = ServerException('Internal error', statusCode: 500);
      final f = ErrorHandler.handle(ex);
      expect(f, isA<ServerFailure>());
      expect(f.displayMessage, 'Internal error');
      expect((f as ServerFailure).statusCode, 500);
    });

    test('NotFoundException → NotFoundFailure', () {
      const ex = NotFoundException();
      final f = ErrorHandler.handle(ex);
      expect(f, isA<NotFoundFailure>());
    });

    test('ValidationException → ValidationFailure with message', () {
      const ex = ValidationException('Name is required');
      final f = ErrorHandler.handle(ex);
      expect(f, isA<ValidationFailure>());
      expect(f.displayMessage, 'Name is required');
    });

    test('UploadException → UploadFailure', () {
      const ex = UploadException('Image too large');
      final f = ErrorHandler.handle(ex);
      expect(f, isA<UploadFailure>());
      expect(f.displayMessage, 'Image too large');
    });

    test('CacheException → UnknownFailure (not cached)', () {
      const ex = CacheException();
      final f = ErrorHandler.handle(ex);
      expect(f, isA<UnknownFailure>());
    });

    test('arbitrary unknown error → UnknownFailure', () {
      final f = ErrorHandler.handle(Exception('something random'));
      expect(f, isA<UnknownFailure>());
    });

    test('FormatException → UnknownFailure (no special case)', () {
      final f = ErrorHandler.handle(const FormatException('bad JSON'));
      expect(f, isA<UnknownFailure>());
    });
  });

  // ── ErrorHandler.handle: DioException dispatch ────────────────────────────

  group('ErrorHandler.handle — DioException types', () {
    test('connectionTimeout → NetworkFailure', () {
      final e = DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionTimeout,
      );
      expect(ErrorHandler.handle(e), isA<NetworkFailure>());
    });

    test('receiveTimeout → NetworkFailure', () {
      final e = DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.receiveTimeout,
      );
      expect(ErrorHandler.handle(e), isA<NetworkFailure>());
    });

    test('sendTimeout → NetworkFailure', () {
      final e = DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.sendTimeout,
      );
      expect(ErrorHandler.handle(e), isA<NetworkFailure>());
    });

    test('connectionError → NetworkFailure', () {
      final e = DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionError,
      );
      expect(ErrorHandler.handle(e), isA<NetworkFailure>());
    });

    test('cancel → UnknownFailure with "cancelled" message', () {
      final e = DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.cancel,
      );
      final f = ErrorHandler.handle(e);
      expect(f, isA<UnknownFailure>());
      expect(f.displayMessage, contains('cancel'));
    });

    test('badResponse 401 → UnauthorizedFailure', () {
      final e = DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 401,
        ),
      );
      expect(ErrorHandler.handle(e), isA<UnauthorizedFailure>());
    });

    test('badResponse 403 → AuthFailure (access denied)', () {
      final e = DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 403,
        ),
      );
      expect(ErrorHandler.handle(e), isA<AuthFailure>());
    });

    test('badResponse 404 → NotFoundFailure', () {
      final e = DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 404,
        ),
      );
      expect(ErrorHandler.handle(e), isA<NotFoundFailure>());
    });

    test('badResponse 422 → ValidationFailure with "message" body key', () {
      final e = DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 422,
          data: <String, dynamic>{'message': 'Email already taken'},
        ),
      );
      final f = ErrorHandler.handle(e);
      expect(f, isA<ValidationFailure>());
      expect(f.displayMessage, 'Email already taken');
    });

    test('badResponse 500 → ServerFailure with statusCode', () {
      final e = DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 500,
          data: <String, dynamic>{'error': 'Internal server error'},
        ),
      );
      final f = ErrorHandler.handle(e);
      expect(f, isA<ServerFailure>());
      expect((f as ServerFailure).statusCode, 500);
    });
  });

  // ── _extractMessage (via DioException round-trip) ─────────────────────────

  group('_extractMessage', () {
    DioException _bad(int status, dynamic data) => DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: status,
            data: data,
          ),
        );

    test('reads "message" key from Map response body', () {
      final f = ErrorHandler.handle(_bad(422, {'message': 'Name required'}));
      expect(f.displayMessage, 'Name required');
    });

    test('reads "error" key when "message" absent', () {
      final f = ErrorHandler.handle(_bad(422, {'error': 'Bad input'}));
      expect(f.displayMessage, 'Bad input');
    });

    test('reads "detail" key as last resort', () {
      final f = ErrorHandler.handle(_bad(422, {'detail': 'Detail message'}));
      expect(f.displayMessage, 'Detail message');
    });

    test('returns "Server error" fallback for non-Map response body', () {
      final f = ErrorHandler.handle(_bad(500, 'plain string error'));
      expect(f, isA<ServerFailure>());
      expect(f.displayMessage, 'Server error');
    });

    test('returns "Server error" fallback for null response body', () {
      final f = ErrorHandler.handle(_bad(500, null));
      expect(f, isA<ServerFailure>());
      expect(f.displayMessage, 'Server error');
    });
  });
}
