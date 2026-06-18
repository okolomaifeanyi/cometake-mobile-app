import 'env.dart';

enum AppEnvironment { development, staging, production }

abstract final class AppConfig {
  static AppEnvironment get environment => switch (Env.appEnv) {
        'production' => AppEnvironment.production,
        'staging' => AppEnvironment.staging,
        _ => AppEnvironment.development,
      };

  static bool get isDevelopment => environment == AppEnvironment.development;
  static bool get isStaging => environment == AppEnvironment.staging;
  static bool get isProduction => environment == AppEnvironment.production;

  static String get appName => switch (environment) {
        AppEnvironment.production => 'Cometake',
        AppEnvironment.staging => 'Cometake (Staging)',
        AppEnvironment.development => 'Cometake (Dev)',
      };

  static bool get enableLogging => !isProduction;
}
