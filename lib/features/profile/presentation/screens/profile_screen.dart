import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../orders/presentation/providers/orders_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      loading: () => Scaffold(
        backgroundColor: context.bg,
        body: const Center(child: AppLoadingSpinner()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: context.bg,
        body: Center(
          child: Text(e.toString(), style: TextStyle(color: context.t1)),
        ),
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
    final ordersAsync = ref.watch(ordersNotifierProvider);
    final orderCount = ordersAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: context.bg,
      body: CustomScrollView(
        slivers: [
          // ─── Teal gradient header ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ProfileHeader(user: user, orderCount: orderCount),
          ),

          // ─── Account section ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _MenuSection(
              title: 'Account',
              items: [
                _MenuEntry(
                  icon: Icons.person_outline,
                  label: 'Personal Info',
                  onTap: () => context.go(AppRoutes.profileEdit),
                ),
                _MenuEntry(
                  icon: Icons.receipt_long_outlined,
                  label: 'My Orders',
                  badge: orderCount > 0 ? '$orderCount' : null,
                  onTap: () => context.go(AppRoutes.orders),
                ),
                _MenuEntry(
                  icon: Icons.favorite_border_rounded,
                  label: 'Wishlist',
                  onTap: () => context.push(AppRoutes.wishlist),
                ),
                _MenuEntry(
                  icon: Icons.location_on_outlined,
                  label: 'Saved Addresses',
                  onTap: () => context.push(AppRoutes.addresses),
                ),
              ],
            ),
          ),

          // ─── Settings section ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _MenuSection(
              title: 'Settings',
              items: [
                _MenuEntry(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () => context.push(AppRoutes.notifications),
                ),
                _MenuEntry(
                  icon: Icons.security_outlined,
                  label: 'Privacy & Security',
                  onTap: () => launchUrl(
                    Uri.parse('https://cometake.net/privacy'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                _MenuEntry(
                  icon: Icons.palette_outlined,
                  label: 'App Settings',
                  subtitle: 'Theme, display',
                  onTap: () => _showThemeSheet(context, ref),
                ),
                _MenuEntry(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  onTap: () => launchUrl(
                    Uri.parse('https://cometake.net/help'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                _MenuEntry(
                  icon: Icons.description_outlined,
                  label: 'Terms & Policies',
                  onTap: () => launchUrl(
                    Uri.parse('https://cometake.net/terms'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ],
            ),
          ),

          // ─── Vendor section ───────────────────────────────────────────────
          if (user.role.canSell)
            SliverToBoxAdapter(
              child: _MenuSection(
                title: 'Selling',
                items: [
                  _MenuEntry(
                    icon: Icons.store_outlined,
                    label: 'Vendor Dashboard',
                    onTap: () => context.go(AppRoutes.vendor),
                  ),
                ],
              ),
            ),

          // ─── Sign out + version ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: GestureDetector(
                onTap: () => _confirmSignOut(context, ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32, top: 8),
              child: Center(
                child: Text(
                  'Cometake v1.0.0',
                  style: TextStyle(
                    color: context.t4,
                    fontSize: 11,
                  ),
                ),
              ),
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
        backgroundColor: ctx.card,
        title: Text('Sign out?', style: TextStyle(color: ctx.t1)),
        content: Text(
          'You will be returned to the login screen.',
          style: TextStyle(color: ctx.t2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: ctx.t2)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            child: const Text('Sign out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showThemeSheet(BuildContext context, WidgetRef ref) {
    final current = ref.read(themeModeProvider);

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            ThemeMode selected = current;
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Theme',
                    style: TextStyle(
                      color: ctx.t1,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ThemeOption(
                    label: 'Dark',
                    subtitle: 'Dark background (default)',
                    icon: Icons.dark_mode_rounded,
                    selected: selected == ThemeMode.dark,
                    onTap: () {
                      setSheetState(() => selected = ThemeMode.dark);
                      ref
                          .read(themeModeProvider.notifier)
                          .setMode(ThemeMode.dark);
                    },
                  ),
                  const SizedBox(height: 10),
                  _ThemeOption(
                    label: 'Light',
                    subtitle: 'Light background',
                    icon: Icons.light_mode_rounded,
                    selected: selected == ThemeMode.light,
                    onTap: () {
                      setSheetState(() => selected = ThemeMode.light);
                      ref
                          .read(themeModeProvider.notifier)
                          .setMode(ThemeMode.light);
                    },
                  ),
                  const SizedBox(height: 10),
                  _ThemeOption(
                    label: 'System',
                    subtitle: 'Follow device settings',
                    icon: Icons.auto_awesome_rounded,
                    selected: selected == ThemeMode.system,
                    onTap: () {
                      setSheetState(() => selected = ThemeMode.system);
                      ref
                          .read(themeModeProvider.notifier)
                          .setMode(ThemeMode.system);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final AuthUser user;
  final int orderCount;

  const _ProfileHeader({required this.user, required this.orderCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.figmaTeal, AppColors.figmaTealEnd],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top row: "My Account" + settings
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  const Text(
                    'My Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.profileEdit),
                    child: const Icon(Icons.edit_outlined,
                        color: Colors.white70, size: 22,),
                  ),
                ],
              ),
            ),

            // Avatar
            _ProfileAvatar(user: user),
            const SizedBox(height: 12),

            // Name
            Text(
              user.fullName.isEmpty ? 'No name set' : user.fullName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),

            // Email
            Text(
              user.email,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 13,
              ),
            ),

            // Phone (if set)
            if (user.phone != null && user.phone!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_outlined,
                      color: Colors.white.withOpacity(0.6), size: 13,),
                  const SizedBox(width: 4),
                  Text(
                    user.phone!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),

            // Role badge
            _RoleBadge(role: user.role),
            const SizedBox(height: 20),

            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _StatBox(label: 'Orders', value: '$orderCount'),
                  const SizedBox(width: 10),
                  const _StatBox(label: 'Wishlist', value: '0'),
                  const SizedBox(width: 10),
                  const _StatBox(label: 'Reviews', value: '0'),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final AuthUser user;
  const _ProfileAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final url = user.avatarUrl != null && user.avatarUrl!.isNotEmpty
        ? CloudinaryService.thumbnail(user.avatarUrl!, size: 160)
        : null;

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.figmaGreen, Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: ClipOval(
        child: url != null
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _Initials(name: user.fullName),
              )
            : _Initials(name: user.fullName),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String name;
  const _Initials({required this.name});

  String get _text {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          _text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
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
      UserRole.customer => Colors.white.withOpacity(0.25),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
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

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Menu Section ─────────────────────────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuEntry> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color: context.t2,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.border),
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    _MenuTile(entry: item),
                    if (i < items.length - 1)
                      Divider(
                        height: 1,
                        color: context.border,
                        indent: 52,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuEntry {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback? onTap;

  const _MenuEntry({
    required this.icon,
    required this.label,
    this.subtitle,
    this.badge,
    this.badgeColor,
    this.onTap,
  });
}

class _MenuTile extends StatelessWidget {
  final _MenuEntry entry;
  const _MenuTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: entry.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(entry.icon, color: context.t4, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.label,
                    style: TextStyle(
                      color: context.t1,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (entry.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.subtitle!,
                      style: TextStyle(color: context.t2, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            if (entry.badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: entry.badgeColor ?? AppColors.figmaGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Icon(Icons.chevron_right, color: context.t2, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Theme Option ─────────────────────────────────────────────────────────────

class _ThemeOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.figmaGreen.withOpacity(0.12)
              : context.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.figmaGreen : context.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.figmaGreen : context.t4,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? AppColors.figmaGreen : context.t1,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: context.t2, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  color: AppColors.figmaGreen, size: 20,),
          ],
        ),
      ),
    );
  }
}
