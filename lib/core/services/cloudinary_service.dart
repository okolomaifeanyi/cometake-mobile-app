import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/remote_config.dart';
import '../errors/app_exception.dart';
import '../network/dio_client.dart';

final cloudinaryServiceProvider = Provider<CloudinaryService>(
  (ref) => CloudinaryService(ref.watch(dioProvider)),
  name: 'cloudinaryServiceProvider',
);

class CloudinaryService {
  final Dio _dio;

  const CloudinaryService(this._dio);

  Future<String> uploadImage({
    required File file,
    required String folder,
    String? publicId,
  }) async {
    try {
      // 1. Get signed upload params from Next.js API
      final signResponse = await _dio.post<Map<String, dynamic>>(
        '/api/cloudinary/sign',
        data: {
          'folder': folder,
          if (publicId != null) 'public_id': publicId,
        },
      );

      final data = signResponse.data!;
      final signature = data['signature'] as String;
      final timestamp = data['timestamp'] as int;
      final apiKey = data['api_key'] as String;
      final cloudName = data['cloud_name'] as String? ??
          RemoteConfig.instance.cloudinaryCloudName;

      // 2. Upload directly to Cloudinary
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'signature': signature,
        'timestamp': timestamp,
        'api_key': apiKey,
        'folder': folder,
        if (publicId != null) 'public_id': publicId,
      });

      final uploadDio = Dio();
      final uploadUrl =
          'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

      final uploadResponse = await uploadDio.post<Map<String, dynamic>>(
        uploadUrl,
        data: formData,
      );

      return uploadResponse.data!['secure_url'] as String;
    } on UploadException {
      rethrow;
    } catch (e) {
      throw UploadException('Upload failed: ${e.toString()}');
    }
  }

  // Transform a Cloudinary URL for display (responsive + optimized)
  static String optimized(
    String url, {
    int width = 400,
    String crop = 'fill',
    String gravity = 'auto',
  }) {
    final resolved = _resolveImageUrl(url);
    if (!resolved.contains('cloudinary.com')) return resolved;
    if (resolved.contains('/image/upload/')) return resolved;
    return resolved.replaceFirst(
      '/upload/',
      '/upload/f_auto,q_auto,w_$width,c_$crop,g_$gravity/',
    );
  }

  static String thumbnail(String url, {int size = 100}) {
    final resolved = _resolveImageUrl(url);
    if (!resolved.contains('cloudinary.com')) return resolved;
    if (resolved.contains('/image/upload/')) return resolved;
    return resolved.replaceFirst(
      '/upload/',
      '/upload/f_auto,q_auto,w_$size,h_$size,c_fill,g_auto/',
    );
  }

  static String banner(String url) => optimized(url, width: 800);

  // Normalizes legacy/supabase object paths into a Cloudinary delivery URL.
  static String _resolveImageUrl(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) return normalized;

    final supabasePublicObject = RegExp(
      r'^https?://[^/]+/storage/v1/object/public/(.+)$',
      caseSensitive: false,
    );
    final match = supabasePublicObject.firstMatch(normalized);
    if (match != null) {
      final objectPath = match.group(1) ?? '';
      if (objectPath.isNotEmpty) {
        final withoutExt = objectPath
            .replaceFirst(RegExp(r'^/+'), '')
            .replaceAll(RegExp(r'\.[^/.]+$'), '');
        return _cloudinaryBase(withoutExt);
      }
    }

    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return normalized;
    }

    final clean = normalized.replaceFirst(RegExp(r'^/+'), '');
    final withoutExt = clean.replaceAll(RegExp(r'\.[^/.]+$'), '');
    return _cloudinaryBase(withoutExt);
  }

  static String _cloudinaryBase(String pathWithoutExt) {
    final cloud = RemoteConfig.instance.cloudinaryCloudName.isNotEmpty
        ? RemoteConfig.instance.cloudinaryCloudName
        : 'dxi9khzro';
    return 'https://res.cloudinary.com/$cloud/image/upload/$pathWithoutExt';
  }
}
