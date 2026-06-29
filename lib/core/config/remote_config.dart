import 'package:dio/dio.dart';

/// Runtime config fetched from the backend at app startup.
/// All credentials come exclusively from the /api/v1/config endpoint —
/// no keys are embedded in the binary. If the endpoint is unreachable the app
/// surfaces a retry screen rather than proceeding with stale credentials.
class RemoteConfig {
  static RemoteConfig? _instance;

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String cloudinaryCloudName;

  RemoteConfig._({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.cloudinaryCloudName,
  });

  static RemoteConfig get instance {
    assert(_instance != null, 'RemoteConfig.fetch() must be called first');
    return _instance!;
  }

  /// Fetches runtime config from the server. Throws on failure — callers should
  /// catch and show a user-friendly retry screen rather than proceeding without config.
  static Future<void> fetch({String baseUrl = 'https://cometake.net'}) async {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),);
    final res = await dio.get<Map<String, dynamic>>('/api/v1/config');
    final data = res.data;
    if (data == null) throw Exception('Config endpoint returned empty response');

    final supabaseUrl = data['url'] as String?;
    final supabaseAnonKey = data['anonKey'] as String?;
    final cloudinaryCloudName = data['cloudinaryCloudName'] as String?;

    if (supabaseUrl == null || supabaseUrl.isEmpty) {
      throw Exception('Config missing supabaseUrl');
    }
    if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
      throw Exception('Config missing supabaseAnonKey');
    }

    _instance = RemoteConfig._(
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      cloudinaryCloudName: cloudinaryCloudName ?? '',
    );
  }
}
