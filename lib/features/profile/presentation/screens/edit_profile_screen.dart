import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  XFile? _pendingImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _populateFields() {
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;
    _nameCtrl.text = user.fullName;
    _phoneCtrl.text = user.phone != null ? Formatters.phoneForDisplay(user.phone!) : '';
  }

  Future<void> _pickImage() async {
    final source = await _showImageSourceSheet();
    if (source == null) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (image != null && mounted) {
      setState(() => _pendingImage = image);
    }
  }

  Future<ImageSource?> _showImageSourceSheet() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppDimensions.spacingSm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      // Upload new avatar if one was selected
      if (_pendingImage != null) {
        await uploadAndUpdateAvatar(
          ref,
          userId: user.id,
          imageFile: File(_pendingImage!.path),
        );
      }

      // Update name/phone
      final newName = _nameCtrl.text.trim();
      final rawPhone = _phoneCtrl.text.trim();
      final newPhone = rawPhone.isEmpty ? '' : Formatters.toE164(rawPhone);
      final nameChanged = newName != user.fullName;
      final phoneChanged = newPhone != (user.phone ?? '');

      if (nameChanged || phoneChanged) {
        await updateProfile(
          ref,
          userId: user.id,
          fullName: nameChanged ? newName : null,
          phone: phoneChanged ? (newPhone.isEmpty ? null : newPhone) : null,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } on AppException catch (e) {
      if (mounted) {
        _showError(e.message);
      }
    } catch (_) {
      if (mounted) {
        _showError('Failed to save changes. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingH,
          vertical: AppDimensions.spacingLg,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Avatar picker ─────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      _AvatarPreview(
                        pendingImage: _pendingImage,
                        existingUrl: user?.avatarUrl,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // ─── Full name ────────────────────────────────────────────
              AuthTextField(
                label: 'Full name',
                hint: 'Your name',
                controller: _nameCtrl,
                validator: (v) => Validators.required(v, label: 'Full name'),
                keyboardType: TextInputType.name,
                prefixIcon: const Icon(Icons.person_outline),
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // ─── Phone ────────────────────────────────────────────────
              AuthPhoneField(
                controller: _phoneCtrl,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  return Validators.phone(v);
                },
                textInputAction: TextInputAction.done,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // Email (read-only info)
              if (user != null)
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: colorScheme.onSurfaceVariant,
                        size: AppDimensions.iconMd,
                      ),
                      const SizedBox(width: AppDimensions.spacingSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email address',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            Text(
                              user.email,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppDimensions.spacingXl),

              // ─── Save button ──────────────────────────────────────────
              AppButton(
                label: 'Save Changes',
                onPressed: _isSaving ? null : _save,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Avatar preview widget ────────────────────────────────────────────────────

class _AvatarPreview extends StatelessWidget {
  final XFile? pendingImage;
  final String? existingUrl;

  const _AvatarPreview({this.pendingImage, this.existingUrl});

  @override
  Widget build(BuildContext context) {
    const size = AppDimensions.avatarXl;

    Widget imageWidget;

    if (pendingImage != null) {
      // Show locally selected image before upload
      imageWidget = Image.file(
        File(pendingImage!.path),
        fit: BoxFit.cover,
      );
    } else if (existingUrl != null && existingUrl!.isNotEmpty) {
      final url = CloudinaryService.thumbnail(existingUrl!, size: size.toInt());
      imageWidget = CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => const _PlaceholderIcon(),
        errorWidget: (_, __, ___) => const _PlaceholderIcon(),
      );
    } else {
      imageWidget = const _PlaceholderIcon();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.1),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 2,
        ),
      ),
      child: ClipOval(child: imageWidget),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon();
  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.primary.withOpacity(0.08),
        child: Icon(
          Icons.person_outline,
          size: 48,
          color: AppColors.primary.withOpacity(0.6),
        ),
      );
}
