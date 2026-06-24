import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/errors/app_exception.dart';
import '../models/auth_user_model.dart';
import 'auth_datasource.dart';

class SupabaseAuthDatasource implements AuthDatasource {
  final sb.SupabaseClient _client;
  const SupabaseAuthDatasource(this._client);

  @override
  Future<AuthUserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final profile = await _client
          .from('core_user')
          .select()
          .eq('id', user.id)
          .single();
      return authUserModelFromRow(Map<String, dynamic>.from(profile as Map));
    } catch (_) {
      // No profile row yet (first OAuth sign-in) — upsert one from auth metadata
      final name = user.userMetadata?['full_name'] as String?
          ?? user.userMetadata?['name'] as String?
          ?? '';
      final photoUrl = user.userMetadata?['avatar_url'] as String?
          ?? user.userMetadata?['picture'] as String?;
      final parts = name.trim().split(RegExp(r'\s+'));
      await _client.from('core_user').upsert({
        'id': user.id,
        'email': user.email ?? '',
        'first_name': parts.first,
        'last_name': parts.length > 1 ? parts.skip(1).join(' ') : '',
        'verified_email': true,
        'is_active': true,
        if (photoUrl != null) 'photo': photoUrl,
      });
      return AuthUserModel(
        id: user.id,
        email: user.email ?? '',
        fullName: name,
        phone: user.phone,
        avatarUrl: photoUrl,
      );
    }
  }

  @override
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Invalid email or password.');
      }

      final profile = await _client
          .from('core_user')
          .select()
          .eq('id', response.user!.id)
          .single();

      return authUserModelFromRow(Map<String, dynamic>.from(profile as Map));
    } on sb.AuthException catch (e) {
      throw AuthException(_friendlyAuthMessage(e.message));
    } on AuthException {
      rethrow;
    } catch (e) {
      throw const AuthException('Sign in failed. Please try again.');
    }
  }

  @override
  Future<AuthUserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          if (phone != null) 'phone': phone,
        },
      );

      if (response.user == null) {
        throw const AuthException('Registration failed. Please try again.');
      }

      final parts = fullName.trim().split(RegExp(r'\s+'));
      await _client.from('core_user').upsert({
        'id': response.user!.id,
        'email': email,
        'first_name': parts.first,
        'last_name': parts.length > 1 ? parts.skip(1).join(' ') : '',
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'verified_email': false,
        'is_active': true,
      });

      if (response.session == null) {
        throw const AuthException(
          'Account created! Please check your email to confirm your account before signing in.',
        );
      }

      final profile = await _client
          .from('core_user')
          .select()
          .eq('id', response.user!.id)
          .single();

      return authUserModelFromRow(Map<String, dynamic>.from(profile as Map));
    } on sb.AuthException catch (e) {
      throw AuthException(_friendlyAuthMessage(e.message));
    } on AuthException {
      rethrow;
    } catch (e) {
      throw const AuthException('Registration failed. Please try again.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {}
  }

  @override
  Future<void> sendPhoneOtp({required String phone}) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
    } on sb.AuthException catch (e) {
      throw AuthException(_friendlyAuthMessage(e.message));
    } catch (e) {
      throw const AuthException('Failed to send OTP. Please try again.');
    }
  }

  @override
  Future<void> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    try {
      await _client.auth.verifyOTP(
        phone: phone,
        token: token,
        type: sb.OtpType.sms,
      );
    } on sb.AuthException catch (e) {
      throw AuthException(_friendlyAuthMessage(e.message));
    } catch (e) {
      throw const AuthException('OTP verification failed. Please try again.');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on sb.AuthException catch (e) {
      throw AuthException(_friendlyAuthMessage(e.message));
    } catch (e) {
      throw const AuthException('Failed to send reset email. Please try again.');
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      // Native Google Sign-In: shows the OS account picker, gets an ID token,
      // then exchanges it with Supabase — no browser, no WebView, no deep links.
      // serverClientId must match the Web client ID configured in Supabase Auth.
      final googleSignIn = GoogleSignIn(
        serverClientId:
            '423246610057-tr07jd8g9j8betjec48g594ci304mj8q.apps.googleusercontent.com',
      );

      final account = await googleSignIn.signIn();
      if (account == null) return; // user cancelled

      final auth = await account.authentication;
      if (auth.idToken == null) {
        throw const AuthException('Google did not return an ID token.');
      }

      await _client.auth.signInWithIdToken(
        provider: sb.OAuthProvider.google,
        idToken: auth.idToken!,
        accessToken: auth.accessToken,
      );
    } on sb.AuthException catch (e) {
      throw AuthException(_friendlyAuthMessage(e.message));
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Google sign in failed: ${e.runtimeType}: $e');
    }
  }

  String _friendlyAuthMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid email or password')) {
      return 'Incorrect email or password.';
    }
    if (lower.contains('email already registered') ||
        lower.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please confirm your email before signing in.';
    }
    if (lower.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    return raw;
  }
}
