import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;

  RetryInterceptor(this._dio, {this.maxRetries = 1});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra['_retryCount'] as int?) ?? 0;

    final shouldRetry = attempt < maxRetries &&
        (err.type == DioExceptionType.connectionError ||
            err.type == DioExceptionType.connectionTimeout ||
            (err.response?.statusCode != null &&
                err.response!.statusCode! >= 500));

    if (shouldRetry) {
      options.extra['_retryCount'] = attempt + 1;
      await Future<void>.delayed(
        Duration(milliseconds: 600 * (attempt + 1)),
      );
      try {
        final response = await _dio.fetch<dynamic>(options);
        handler.resolve(response);
        return;
      } catch (_) {
        // Fall through to original error
      }
    }

    handler.next(err);
  }
}
