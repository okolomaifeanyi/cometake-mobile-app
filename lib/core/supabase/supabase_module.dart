import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
  name: 'supabaseClientProvider',
);

abstract final class SupabaseModule {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      // PKCE is the default and the only flow that reliably works on Android:
      // Android Intents strip URL fragments, so implicit flow (tokens in #fragment)
      // never reaches the app. PKCE sends a one-time ?code= in the query string
      // which Android preserves, then exchanges it server-side.
    );
  }
}
