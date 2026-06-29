enum AppEnvironment { development, production }

abstract final class AppConfig {
  // Production is the default — dev builds can override via run args if needed.
  static const AppEnvironment environment = AppEnvironment.production;

  static bool get isDevelopment => environment == AppEnvironment.development;
  static bool get isProduction => environment == AppEnvironment.production;

  static String get appName =>
      isDevelopment ? 'Cometake (Dev)' : 'Cometake';

  static bool get enableLogging => isDevelopment;
}
