import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../domain/entities/chat.dart';
import '../providers/chat_provider.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(conversationsProvider);
    final myId = ref.watch(currentUserIdProvider);

    return Scaffold(
      backgroundColor: context.bg,
      body: Column(
        children: [
          _ChatAppBar(),
          _TabRow(
              activeTab: _activeTab,
              onTabTap: (i) => setState(() => _activeTab = i)),
          _SecureBanner(),
          Expanded(
            child: roomsAsync.when(
                    loading: () => const AppLoadingOverlay(),
                    error: (e, _) => AppErrorWidget(
                      message: e.toString(),
                      onRetry: () =>
                          ref.read(conversationsProvider.notifier).refresh(),
                    ),
                    data: (rooms) {
                      final displayRooms = _activeTab == 1
                          ? rooms.where((r) => r.unreadCount > 0).toList()
                          : ([...rooms]..sort(
                              (a, b) => b.unreadCount.compareTo(a.unreadCount),
                            ));
                      if (displayRooms.isEmpty) {
                        return _EmptyState(
                          message: _activeTab == 1
                              ? 'No unread messages'
                              : null,
                        );
                      }
                      return RefreshIndicator(
                        color: AppColors.figmaGreen,
                        onRefresh: () =>
                            ref.read(conversationsProvider.notifier).refresh(),
                        child: ListView.separated(
                          itemCount: displayRooms.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: context.border,
                            indent: 76,
                          ),
                          itemBuilder: (_, i) => _RoomTile(
                            room: displayRooms[i],
                            myId: myId ?? '',
                            onTap: () => context.go(
                              AppRoutes.conversationPath(displayRooms[i].id),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.bg,
      padding: EdgeInsets.fromLTRB(16, MediaQuery.viewPaddingOf(context).top + 8, 16, 12),
      child: Row(
        children: [
          Text(
            'Chat',
            style: TextStyle(
              color: context.t1,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Icon(Icons.edit_outlined, color: context.t4, size: 22),
          const SizedBox(width: 14),
          Icon(Icons.more_vert, color: context.t4, size: 22),
        ],
      ),
    );
  }
}

// ─── Pill Tab Row ─────────────────────────────────────────────────────────────

class _TabRow extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTabTap;

  const _TabRow({required this.activeTab, required this.onTabTap});

  static const _labels = ['All Chats', 'Unread'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final active = i == activeTab;
          return GestureDetector(
            onTap: () => onTabTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppColors.figmaGreen : context.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? AppColors.figmaGreen : context.border,
                ),
              ),
              child: Text(
                _labels[i],
                style: TextStyle(
                  color: active ? Colors.white : context.t4,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Secure Banner ────────────────────────────────────────────────────────────

class _SecureBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.figmaGreen, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Messages are end-to-end encrypted.',
              style: TextStyle(color: context.t2, fontSize: 12),
            ),
          ),
          GestureDetector(
            onTap: () => launchUrl(
              Uri.parse('https://cometake.net/help'),
              mode: LaunchMode.externalApplication,
            ),
            child: const Text(
              'Learn more',
              style: TextStyle(
                color: AppColors.figmaGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Room Tile ────────────────────────────────────────────────────────────────

class _RoomTile extends StatelessWidget {
  final ChatRoom room;
  final String myId;
  final VoidCallback onTap;

  const _RoomTile({
    required this.room,
    required this.myId,
    required this.onTap,
  });

  static const _avatarColors = [
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF22C55E),
    Color(0xFFF97316),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
  ];

  Color _colorFor(String name) =>
      _avatarColors[name.hashCode.abs() % _avatarColors.length];

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final other = room.other(myId);
    final name = other?.fullName ?? 'Unknown';
    final last = room.lastMessage;
    final hasUnread = room.unreadCount > 0;
    final avatarColor = _colorFor(name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar with online dot
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: avatarColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: avatarColor.withOpacity(0.4)),
                  ),
                  child: Center(
                    child: Text(
                      _initials(name),
                      style: TextStyle(
                        color: avatarColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                // Online dot (static false for now)
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B7280),
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: context.bg, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Name + message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: context.t1,
                          fontSize: 14,
                          fontWeight:
                              hasUnread ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Verified tick when talking to admin/vendor
                      if (other?.role.toUpperCase() != 'CUSTOMER')
                        const Icon(Icons.verified,
                            color: AppColors.figmaGreen, size: 14),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    last?.content ?? 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasUnread ? context.t3 : context.t4,
                      fontSize: 13,
                      fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Time + unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (last != null)
                  Text(
                    Formatters.time(last.createdAt),
                    style: TextStyle(
                      color: hasUnread ? AppColors.figmaGreen : context.t4,
                      fontSize: 11,
                    ),
                  ),
                if (hasUnread) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.figmaGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      room.unreadCount > 99 ? '99+' : '${room.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String? message;
  const _EmptyState({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 60, color: context.t4),
          const SizedBox(height: 16),
          Text(
            message ?? 'No conversations yet',
            style: TextStyle(
              color: context.t1,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (message == null) ...[
            const SizedBox(height: 6),
            Text(
              'Start a chat from a product page',
              style: TextStyle(color: context.t2, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
