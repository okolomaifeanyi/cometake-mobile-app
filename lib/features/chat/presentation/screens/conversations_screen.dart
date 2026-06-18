import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../domain/entities/chat.dart';
import '../providers/chat_provider.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(conversationsProvider);
    final myId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: roomsAsync.when(
        loading: () => const AppLoadingOverlay(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.read(conversationsProvider.notifier).refresh(),
        ),
        data: (rooms) {
          if (rooms.isEmpty) {
            return const _EmptyConversations();
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(conversationsProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: rooms.length,
              separatorBuilder: (_, __) => const Divider(
                  height: 1, indent: 72),
              itemBuilder: (_, i) => _RoomTile(
                room: rooms[i],
                myId: myId ?? '',
                onTap: () =>
                    context.push(AppRoutes.conversationPath(rooms[i].id)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  final ChatRoom room;
  final String myId;
  final VoidCallback onTap;

  const _RoomTile({
    required this.room,
    required this.myId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final other = room.other(myId);
    final name = other?.fullName ?? 'Unknown';
    final last = room.lastMessage;
    final hasUnread = room.unreadCount > 0;

    return ListTile(
      onTap: onTap,
      leading: _Avatar(name: name),
      title: Text(
        name,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        last?.content ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: hasUnread
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: hasUnread ? FontWeight.w600 : null,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (last != null)
            Text(
              Formatters.time(last.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: hasUnread
                    ? AppColors.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          if (hasUnread) ...[
            const SizedBox(height: 4),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${room.unreadCount > 99 ? '99+' : room.unreadCount}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) => CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.12),
        child: Text(
          _initials,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      );
}

class _EmptyConversations extends StatelessWidget {
  const _EmptyConversations();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: AppDimensions.spacingMd),
            Text('No conversations yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              'Start a chat from a product page',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
}
