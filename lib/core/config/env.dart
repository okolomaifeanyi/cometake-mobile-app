abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const nextApiBaseUrl = String.fromEnvironment('NEXT_API_BASE_URL');
  static const cloudinaryCloudName = String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
  static const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'development');

  static bool get isValid =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      nextApiBaseUrl.isNotEmpty &&
      cloudinaryCloudName.isNotEmpty;
}
