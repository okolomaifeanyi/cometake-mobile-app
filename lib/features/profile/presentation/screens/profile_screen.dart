import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../../shared/widgets/app_loading.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: AppLoadingSpinner()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text(e.toString())),
      ),
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return _ProfileContent(user: user);
      },
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  final AuthUser user;
  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Hero header ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppDimensions.spacingMd),

                      // Avatar
                      Stack(
                        children: [
                          _Avatar(
                            avatarUrl: user.avatarUrl,
                            size: AppDimensions.avatarXl,
                          ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.spacingSm),

                      // Name
                      Text(
                        user.fullName.isEmpty ? 'No name set' : user.fullName,
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs / 2),

                      // Email
                      Text(
                        user.email,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),

                      // Role badge
                      _RoleBadge(role: user.role),

                      const SizedBox(height: AppDimensions.spacingSm),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                tooltip: 'Edit profile',
                onPressed: () => context.push(AppRoutes.profileEdit),
              ),
            ],
          ),

          // ─── Menu ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.spacingSm),

                _SectionLabel('Shopping'),
                _MenuItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'My Orders',
                  onTap: () => context.push(AppRoutes.orders),
                ),
                _MenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Wallet',
                  onTap: () => context.push(AppRoutes.wallet),
                ),

                _SectionLabel('Services'),
                _MenuItem(
                  icon: Icons.phone_android_outlined,
                  label: 'VTU Services',
                  subtitle: 'Airtime, data, bills',
                  onTap: () => context.push(AppRoutes.vtu),
                ),
                _MenuItem(
                  icon: Icons.chat_bubble_outline,
                  label: 'Messages',
                  onTap: () => context.push(AppRoutes.chat),
                ),

                if (user.role.canSell) ...[
                  _SectionLabel('Selling'),
                  _MenuItem(
                    icon: Icons.store_outlined,
                    label: 'Vendor Dashboard',
                    onTap: () => context.push(AppRoutes.vendor),
                  ),
                ],

                _SectionLabel('Account'),
                _MenuItem(
                  icon: Icons.person_outline,
                  label: 'Edit Profile',
                  onTap: () => context.push(AppRoutes.profileEdit),
                ),

                const Divider(height: AppDimensions.spacingLg),

                _MenuItem(
                  icon: Icons.logout,
                  label: 'Sign Out',
                  labelColor: colorScheme.error,
                  iconColor: colorScheme.error,
                  onTap: () => _confirmSignOut(context, ref),
                ),

                const SizedBox(height: AppDimensions.spacingXxl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will be returned to the login screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            child: Text(
              'Sign out',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? avatarUrl;
  final double size;
  const _Avatar({this.avatarUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    final url =
        avatarUrl != null && avatarUrl!.isNotEmpty
            ? CloudinaryService.thumbnail(avatarUrl!, size: size.toInt())
            : null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.2),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: ClipOval(
        child: url != null
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => const _AvatarPlaceholder(),
                errorWidget: (_, __, ___) => const _AvatarPlaceholder(),
              )
            : const _AvatarPlaceholder(),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.15),
      child: const Icon(Icons.person_outline, size: 40, color: Colors.white),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final label = switch (role) {
      UserRole.admin => 'Admin',
      UserRole.vendor => 'Vendor',
      UserRole.customer => 'Customer',
    };
    final color = switch (role) {
      UserRole.admin => Colors.red.shade400,
      UserRole.vendor => Colors.orange.shade400,
      UserRole.customer => Colors.white.withOpacity(0.4),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        AppDimensions.spacingMd,
        0,
        AppDimensions.spacingXs,
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? labelColor;
  final Color? iconColor;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.labelColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: labelColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle:
          subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12)) : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
      ),
    );
  }
}
