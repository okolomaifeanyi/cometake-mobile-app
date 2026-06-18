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
      return AuthUserModel.fromJson(profile as Map<String, dynamic>);
    } catch (_) {
      // Profile row not yet created — fall back to auth metadata
      return AuthUserModel(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] as String? ?? '',
        phone: user.phone,
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

      return AuthUserModel.fromJson(profile as Map<String, dynamic>);
    } on sb.AuthException catch (e) {
      throw AuthException(_friendlyAuthMessage(e.message));
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Sign in failed. Please try again.');
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

      // Upsert profile — handles retry if row already exists
      final profileData = <String, dynamic>{
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'role': 'customer',
        'is_verified': false,
      };
      await _client.from('core_user').upsert(profileData);

      if (response.session == null) {
        // Email confirmation is enabled — account created but not yet active
        throw const AuthException(
          'Account created! Please check your email to confirm your account before signing in.',
        );
      }

      final profile = await _client
          .from('core_user')
          .select()
          .eq('id', response.user!.id)
          .single();

      return AuthUserModel.fromJson(profile as Map<String, dynamic>);
    } on sb.AuthException catch (e) {
      throw AuthException(_friendlyAuthMessage(e.message));
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Registration failed. Please try again.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      // Clear local session regardless of server errors
    }
  }

  @override
  Future<void> sendPhoneOtp({required String phone}) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
    } on sb.AuthException catch (e) {
      throw AuthException(_friendlyAuthMessage(e.message));
    } catch (e) {
      throw AuthException('Failed to send OTP. Please try again.');
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
      throw AuthException('OTP verification failed. Please try again.');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on sb.AuthException catch (e) {
      throw AuthException(_friendlyAuthMessage(e.message));
    } catch (e) {
      throw AuthException('Failed to send reset email. Please try again.');
    }
  }

  // Map Supabase's terse error messages to user-facing copy
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
