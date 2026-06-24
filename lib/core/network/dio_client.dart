import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../config/env.dart';
import '../supabase/supabase_module.dart';
import 'auth_interceptor.dart';
import 'retry_interceptor.dart';

final dioProvider = Provider<Dio>(
  (ref) {
    final client = ref.watch(supabaseClientProvider);
    final dio = DioClient.create(client);
    ref.onDispose(dio.close);
    return dio;
  },
  name: 'dioProvider',
);

abstract final class DioClient {
  static Dio create(SupabaseClient supabaseClient) {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.nextApiBaseUrl,
        connectTimeout:
            const Duration(seconds: AppConstants.connectTimeoutSeconds),
        receiveTimeout:
            const Duration(seconds: AppConstants.receiveTimeoutSeconds),
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(supabaseClient),
      RetryInterceptor(dio),
      if (kDebugMode)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
        ),
    ]);

    return dio;
  }
}
