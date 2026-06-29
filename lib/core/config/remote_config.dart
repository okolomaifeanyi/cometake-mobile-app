import 'package:dio/dio.dart';

/// Runtime config fetched from the backend at app startup.
/// Falls back to known-good production values if the endpoint is unreachable,
/// so the app always boots — even before the config route is deployed.
class RemoteConfig {
  static RemoteConfig? _instance;

  // Fallback values — these are public (anon key is protected by RLS).
  // Used when GET /api/v1/config fails or hasn't been deployed yet.
  static const _fallbackUrl = 'https://vyyhbqcxauctwqxeqwex.supabase.co';
  static const _fallbackAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ5eWhicWN4YXVjdHdxeGVxd2V4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM0NTkyMTAsImV4cCI6MjA1OTAzNTIxMH0.4FtXkl0ntna-m2t2Lrea7oVtt3nEtxjcKk-Qw-29M_I';
  static const _fallbackCloudName = 'dxi9khzro';

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

  static Future<void> fetch({String baseUrl = 'https://cometake.net'}) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),);
      final res = await dio.get<Map<String, dynamic>>('/api/v1/config');
      final data = res.data!;
      _instance = RemoteConfig._(
        supabaseUrl: data['url'] as String,
        supabaseAnonKey: data['anonKey'] as String,
        cloudinaryCloudName: data['cloudinaryCloudName'] as String? ?? _fallbackCloudName,
      );
    } catch (_) {
      // Endpoint not yet deployed or network unavailable — use known values.
      _instance = RemoteConfig._(
        supabaseUrl: _fallbackUrl,
        supabaseAnonKey: _fallbackAnonKey,
        cloudinaryCloudName: _fallbackCloudName,
      );
    }
  }
}
