import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/data/models/auth_user_model.dart';
import 'profile_datasource.dart';

class SupabaseProfileDatasource implements ProfileDatasource {
  final SupabaseClient _client;
  const SupabaseProfileDatasource(this._client);

  @override
  Future<AuthUserModel> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      if (fullName != null && fullName.isNotEmpty) {
        updates['full_name'] = fullName;
      }
      if (phone != null) {
        updates['phone'] = phone.isEmpty ? null : phone;
      }

      final result = await _client
          .from('core_user')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return AuthUserModel.fromJson(result as Map<String, dynamic>);
    } catch (e) {
      throw ServerException('Failed to update profile. Please try again.');
    }
  }

  @override
  Future<AuthUserModel> updateAvatarUrl({
    required String userId,
    required String avatarUrl,
  }) async {
    try {
      final result = await _client
          .from('core_user')
          .update({
            'avatar_url': avatarUrl,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      return AuthUserModel.fromJson(result as Map<String, dynamic>);
    } catch (e) {
      throw ServerException('Failed to update avatar. Please try again.');
    }
  }
}
