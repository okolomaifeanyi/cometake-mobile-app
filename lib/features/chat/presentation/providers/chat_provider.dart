import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_module.dart';
import '../../data/datasources/chat_datasource.dart';
import '../../data/models/chat_model.dart';
import '../../domain/entities/chat.dart';

// ─── Current user ID helper ───────────────────────────────────────────────────

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(supabaseClientProvider).auth.currentUser?.id;
});

// ─── Rooms notifier ───────────────────────────────────────────────────────────

class ConversationsNotifier extends AsyncNotifier<List<ChatRoom>> {
  @override
  Future<List<ChatRoom>> build() async {
    final ds = ref.watch(chatDatasourceProvider);
    final models = await ds.fetchRooms();
    return models.map((m) => m.toEntity()).toList();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<ChatRoom?> getOrCreate(String participantId) async {
    try {
      final ds = ref.read(chatDatasourceProvider);
      final model = await ds.getOrCreateRoom(participantId);
      return model.toEntity();
    } catch (_) {
      return null;
    }
  }
}

final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<ChatRoom>>(
        () => ConversationsNotifier(),);

// ─── Messages notifier (per conversation, with realtime) ──────────────────────

class MessagesNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<ChatMessage>, String> {
  RealtimeChannel? _channel;

  @override
  Future<List<ChatMessage>> build(String roomId) async {
    final ds = ref.watch(chatDatasourceProvider);
    final messages = await ds.fetchMessages(roomId);

    // Subscribe to realtime inserts for this room
    _channel = ds.subscribeToMessages(roomId, (newMsg) {
      final current = state.valueOrNull ?? [];
      // Deduplicate by id
      if (!current.any((m) => m.id == newMsg.id)) {
        state = AsyncData([...current, newMsg]);
      }
    });

    ref.onDispose(() async {
      if (_channel != null) {
        await ds.unsubscribe(_channel!);
      }
    });

    return messages;
  }

  Future<void> sendMessage(String content) async {
    final ds = ref.read(chatDatasourceProvider);
    try {
      // Optimistically add a pending message
      final userId =
          ref.read(supabaseClientProvider).auth.currentUser?.id ?? '';
      final optimistic = ChatMessage(
        id: 'pending-${DateTime.now().millisecondsSinceEpoch}',
        roomId: arg,
        senderId: userId,
        content: content,
        createdAt: DateTime.now(),
      );
      state = AsyncData([...(state.valueOrNull ?? []), optimistic]);

      final sent = await ds.sendMessage(arg, content);

      // Replace optimistic with real
      final current = state.valueOrNull ?? [];
      state = AsyncData([
        ...current.where((m) => m.id != optimistic.id),
        sent,
      ]);
    } catch (e) {
      // Remove optimistic on error
      final pending = state.valueOrNull
          ?.where((m) => !m.id.startsWith('pending-'))
          .toList();
      if (pending != null) state = AsyncData(pending);
      rethrow;
    }
  }

  Future<void> markRead() async {
    await ref.read(chatDatasourceProvider).markAsRead(arg);
  }
}

final messagesProvider = AsyncNotifierProvider.autoDispose
    .family<MessagesNotifier, List<ChatMessage>, String>(
        () => MessagesNotifier(),);
