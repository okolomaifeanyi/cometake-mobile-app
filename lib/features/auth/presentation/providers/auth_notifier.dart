import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthChangeEvent, AuthState;

import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/supabase/supabase_module.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/datasources/supabase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

// ─── Infrastructure providers ────────────────────────────────────────────────

final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  return SupabaseAuthDatasource(
    ref.watch(supabaseClientProvider),
    ref.watch(dioProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDatasourceProvider));
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>((ref) {
  return VerifyOtpUseCase(ref.watch(authRepositoryProvider));
});

// ─── Primary auth provider ────────────────────────────────────────────────────

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthUser?>(() => AuthNotifier());

// ─── Derived convenience providers ───────────────────────────────────────────

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).valueOrNull != null;
});

final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authNotifierProvider).valueOrNull;
});

// ─── Notifier ─────────────────────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() async {
    // Subscribe once so that OAuth redirects and sign-outs update this notifier
    // independently of the GoRouter refresh notifier.
    final client = ref.read(supabaseClientProvider);
    final sub = client.auth.onAuthStateChange.listen((AuthState event) {
      if (event.event == AuthChangeEvent.signedIn && !state.isLoading) {
        ref.invalidateSelf();
      }
      if (event.event == AuthChangeEvent.signedOut) {
        state = const AsyncData(null);
      }
    });
    ref.onDispose(sub.cancel);
    return ref.read(authRepositoryProvider).getCurrentUser();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final user = await ref
          .read(signInUseCaseProvider)
          .execute(email: email, password: password);
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(ErrorHandler.handle(e), st);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    state = const AsyncLoading();
    try {
      final user = await ref.read(signUpUseCaseProvider).execute(
            email: email,
            password: password,
            fullName: fullName,
            phone: phone,
          );
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(ErrorHandler.handle(e), st);
    }
  }

  Future<void> signOut() async {
    await ref.read(signOutUseCaseProvider).execute();
    state = const AsyncData(null);
  }

  // Returns Future so the screen can catch errors and show local feedback
  Future<void> sendPhoneOtp({required String phone}) =>
      ref.read(authRepositoryProvider).sendPhoneOtp(phone: phone);

  Future<void> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    await ref
        .read(verifyOtpUseCaseProvider)
        .execute(phone: phone, token: token);
    // Invalidate so build() re-fetches the newly authenticated user
    ref.invalidateSelf();
  }

  Future<void> resetPassword({required String email}) =>
      ref.read(authRepositoryProvider).resetPassword(email: email);

  Future<void> signInWithGoogle() async {
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (e, st) {
      state = AsyncError(ErrorHandler.handle(e), st);
    }
  }

  // ─── Profile bridge ─────────────────────────────────────────────────────────
  // Called by profile_provider.dart after a successful profile update so that
  // AuthNotifier remains the single source of truth for the current user.

  void updateUser(AuthUser user) {
    state = AsyncData(user);
  }

  void setError(Object error, StackTrace stackTrace) {
    state = AsyncError(error, stackTrace);
  }
}
