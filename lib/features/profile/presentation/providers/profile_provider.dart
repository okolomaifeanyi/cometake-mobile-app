import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/supabase/supabase_module.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/datasources/profile_datasource.dart';
import '../../data/datasources/supabase_profile_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';

// ─── Infrastructure providers ─────────────────────────────────────────────────

final profileDatasourceProvider = Provider<ProfileDatasource>((ref) {
  return SupabaseProfileDatasource(ref.watch(supabaseClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileDatasourceProvider));
});

// ─── Profile actions ──────────────────────────────────────────────────────────

/// Update the user's display name and/or phone.
Future<void> updateProfile(
  WidgetRef ref, {
  required String userId,
  String? fullName,
  String? phone,
}) async {
  try {
    final updatedUser = await ref.read(profileRepositoryProvider).updateProfile(
          userId: userId,
          fullName: fullName,
          phone: phone,
        );
    ref.read(authNotifierProvider.notifier).updateUser(updatedUser);
  } catch (e, st) {
    ref.read(authNotifierProvider.notifier).setError(ErrorHandler.handle(e), st);
    rethrow;
  }
}

/// Upload avatar to Supabase Storage and save the public URL to core_user.photo.
Future<void> uploadAndUpdateAvatar(
  WidgetRef ref, {
  required String userId,
  required File imageFile,
}) async {
  try {
    final client = ref.read(supabaseClientProvider);

    final ext = imageFile.path.split('.').last.toLowerCase();
    final validExt = ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext) ? ext : 'jpg';
    // MIME subtype for jpg is 'jpeg', not 'jpg'
    final mimeSubtype = validExt == 'jpg' ? 'jpeg' : validExt;
    final storagePath = 'avatars/$userId.$validExt';

    await client.storage.from('avatars').upload(
          storagePath,
          imageFile,
          fileOptions: FileOptions(
            upsert: true,
            contentType: 'image/$mimeSubtype',
          ),
        );

    // Get public URL
    final avatarUrl = client.storage.from('avatars').getPublicUrl(storagePath);

    // Persist URL in core_user.photo
    final updatedUser = await ref.read(profileRepositoryProvider).updateAvatarUrl(
          userId: userId,
          avatarUrl: avatarUrl,
        );

    ref.read(authNotifierProvider.notifier).updateUser(updatedUser);
  } catch (e, st) {
    ref.read(authNotifierProvider.notifier).setError(ErrorHandler.handle(e), st);
    rethrow;
  }
}
