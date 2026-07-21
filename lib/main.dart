import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

import 'core/config/remote_config.dart';
import 'core/router/app_router.dart';
import 'core/supabase/supabase_module.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    var crashlyticsReady = false;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      crashlyticsReady = true;
    } catch (e, stack) {
      // Never block first paint on telemetry setup failures.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: e,
          stack: stack,
          informationCollector: () sync* {
            yield ErrorDescription('Firebase initialization failed at startup');
          },
        ),
      );
    }

    // Catch Flutter framework errors (widget build errors, layout overflows, etc.)
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      if (crashlyticsReady) {
        FirebaseCrashlytics.instance.recordFlutterError(details);
      }
    };

    // Catch uncaught async errors that Flutter doesn't intercept via onError above
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      if (crashlyticsReady) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
      return true; // returning true marks the error as handled
    };

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Show the app shell immediately so the screen is never blank.
    // RemoteConfig + Supabase init happens inside _AppLoader below.
    runApp(const ProviderScope(child: _AppLoader()));
  }, (error, stack) {
    // Catches errors that occur outside the Flutter framework's error zone
    // (e.g. errors thrown before Firebase/Crashlytics is ready).
    if (Firebase.apps.isNotEmpty) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
  });
}

// ─── Bootstrap widget ──────────────────────────────────────────────────────────
// Runs RemoteConfig.fetch() + Supabase.initialize() asynchronously and shows
// a loading spinner while they complete, or an error screen if they fail.

class _AppLoader extends StatefulWidget {
  const _AppLoader();

  @override
  State<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<_AppLoader> {
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      await RemoteConfig.fetch();
      await SupabaseModule.initialize();
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return const CometakeApp();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: _error == null
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          size: 48, color: Colors.grey,),
                      const SizedBox(height: 16),
                      const Text(
                        'Could not connect to server',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600,),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => setState(() {
                          _error = null;
                          _boot();
                        }),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Main app ─────────────────────────────────────────────────────────────────

class CometakeApp extends ConsumerWidget {
  const CometakeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Cometake',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
