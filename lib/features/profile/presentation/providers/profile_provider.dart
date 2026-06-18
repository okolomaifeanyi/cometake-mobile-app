import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/services/cloudinary_service.dart';
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

// ─── Profile actions (extending AuthNotifier) ─────────────────────────────────
// These are free functions that call the AuthNotifier and ProfileRepository.
// They keep AuthNotifier as the single source of truth for the current user.

/// Update the user's display name and/or phone. Does NOT set AsyncLoading
/// globally — the caller manages its own loading flag.
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
    ref.read(authNotifierProvider.notifier).setError(
          ErrorHandler.handle(e),
          st,
        );
    rethrow;
  }
}

/// Upload a new avatar image and update the profile. The caller manages
/// its own loading state.
Future<void> uploadAndUpdateAvatar(
  WidgetRef ref, {
  required String userId,
  required File imageFile,
}) async {
  try {
    // 1. Upload to Cloudinary
    final avatarUrl = await ref.read(cloudinaryServiceProvider).uploadImage(
          file: imageFile,
          folder: 'avatars',
          publicId: userId,
        );

    // 2. Persist in core_user
    final updatedUser =
        await ref.read(profileRepositoryProvider).updateAvatarUrl(
              userId: userId,
              avatarUrl: avatarUrl,
            );

    ref.read(authNotifierProvider.notifier).updateUser(updatedUser);
  } catch (e, st) {
    ref.read(authNotifierProvider.notifier).setError(
          ErrorHandler.handle(e),
          st,
        );
    rethrow;
  }
}
