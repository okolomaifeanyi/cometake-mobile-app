abstract final class Env {
  // The only value hardcoded in the binary — a public URL, not a secret.
  // All other config (Supabase URL/key, Cloudinary name) is fetched at runtime
  // from this server via RemoteConfig, so nothing sensitive is in the APK.
  static const nextApiBaseUrl = 'https://cometake.net';
}
