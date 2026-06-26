import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthInterceptor extends Interceptor {
  final SupabaseClient _client;
  final Dio _dio;

  bool _isRefreshing = false;
  final _pending = <({DioException err, ErrorInterceptorHandler handler})>[];

  AuthInterceptor(this._client, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final session = _client.auth.currentSession;
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    // Prevent infinite retry loops — only refresh once per request chain.
    final alreadyRetried = err.requestOptions.extra['_authRetried'] == true;

    if (!is401 || alreadyRetried) {
      handler.next(err);
      return;
    }

    // Queue subsequent 401s while a refresh is in flight.
    if (_isRefreshing) {
      _pending.add((err: err, handler: handler));
      return;
    }

    _isRefreshing = true;
    try {
      final res = await _client.auth.refreshSession();
      final newToken = res.session?.accessToken;
      if (newToken == null) throw Exception('refreshSession returned no session');

      handler.resolve(await _retry(err.requestOptions, newToken));

      for (final item in List.of(_pending)) {
        try {
          item.handler.resolve(await _retry(item.err.requestOptions, newToken));
        } catch (_) {
          item.handler.next(item.err);
        }
      }
    } catch (_) {
      // Refresh failed — surface errors as-is. Do NOT call signOut() here.
      // A transient refresh failure (e.g. no internet) must not kill the session.
      handler.next(err);
      for (final item in List.of(_pending)) {
        item.handler.next(item.err);
      }
    } finally {
      _pending.clear();
      _isRefreshing = false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions options, String token) {
    return _dio.fetch<dynamic>(
      options
        ..headers['Authorization'] = 'Bearer $token'
        ..extra['_authRetried'] = true,
    );
  }
}
