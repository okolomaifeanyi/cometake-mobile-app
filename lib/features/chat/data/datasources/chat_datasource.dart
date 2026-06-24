import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/supabase/supabase_module.dart';
import '../../domain/entities/chat.dart';
import '../models/chat_model.dart';

class ChatDatasource {
  final SupabaseClient _client;

  const ChatDatasource(this._client);

  String? get _myId => _client.auth.currentUser?.id;

  // ─── Rooms ──────────────────────────────────────────────────────────────────

  Future<List<ChatRoomModel>> fetchRooms() async {
    final myId = _myId;
    if (myId == null) return [];

    try {
      // 1. Get chat IDs where I'm a member
      final memberRows = await _client
          .from('core_chat_members')
          .select('chat_id')
          .eq('user_id', myId);

      if ((memberRows as List).isEmpty) return [];
      final chatIds =
          memberRows.map((r) => r['chat_id'] as String).toList();

      // 2. Room metadata
      final roomRows = await _client
          .from('core_chat')
          .select('id, created_at, updated_at')
          .inFilter('id', chatIds)
          .order('updated_at', ascending: false, nullsFirst: false);

      // 3. All participants for these rooms
      final participantRows = await _client
          .from('core_chat_members')
          .select(
              'chat_id, user:core_user!user_id(id, first_name, last_name, email, is_superuser, is_seller)',)
          .inFilter('chat_id', chatIds);

      // 4. Last message per room
      final msgRows = await _client
          .from('core_sellermessage')
          .select('id, chat_id, sender_id, content, read, created_at')
          .inFilter('chat_id', chatIds)
          .order('created_at', ascending: false);

      // 5. Unread count
      final unreadRows = await _client
          .from('core_sellermessage')
          .select('chat_id')
          .eq('reciever_id', myId)
          .eq('read', false)
          .inFilter('chat_id', chatIds);

      // ── Build in Dart ────────────────────────────────────────────────────

      // Participants grouped by chat_id
      final participantsByChat = <String, List<ChatParticipantModel>>{};
      for (final row in participantRows as List) {
        final chatId = row['chat_id'] as String;
        final u = row['user'] as Map<String, dynamic>?;
        if (u == null) continue;
        final role = _deriveRole(
          u['is_superuser'] as bool? ?? false,
          u['is_seller'] as bool? ?? false,
        );
        final p = ChatParticipantModel(
          id: u['id'] as String,
          firstName: u['first_name'] as String? ?? '',
          lastName: u['last_name'] as String? ?? '',
          email: u['email'] as String? ?? '',
          role: role,
        );
        participantsByChat.putIfAbsent(chatId, () => []).add(p);
      }

      // Last message per chat (msgRows already ordered newest-first)
      final lastMsgByChat = <String, ChatMessageModel>{};
      for (final row in msgRows as List) {
        final chatId = row['chat_id'] as String;
        if (!lastMsgByChat.containsKey(chatId)) {
          lastMsgByChat[chatId] = ChatMessageModel(
            id: row['id'] as String,
            roomId: chatId,
            senderId: row['sender_id'] as String,
            content: row['content'] as String? ?? '',
            isRead: row['read'] as bool? ?? false,
            createdAt: row['created_at'] as String? ?? '',
          );
        }
      }

      // Unread count per chat
      final unreadByChat = <String, int>{};
      for (final row in unreadRows as List) {
        final chatId = row['chat_id'] as String;
        unreadByChat[chatId] = (unreadByChat[chatId] ?? 0) + 1;
      }

      return (roomRows as List).map((r) {
        final chatId = r['id'] as String;
        final lastMsg = lastMsgByChat[chatId];
        return ChatRoomModel(
          id: chatId,
          participants: participantsByChat[chatId] ?? [],
          updatedAt: r['updated_at'] as String? ?? r['created_at'] as String? ?? '',
          unreadCount: unreadByChat[chatId] ?? 0,
          messages: lastMsg != null ? [lastMsg] : [],
        );
      }).toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Failed to load conversations: ${e.toString()}');
    }
  }

  Future<ChatRoomModel> getOrCreateRoom(String participantId) async {
    final myId = _myId;
    if (myId == null) throw const ServerException('Not authenticated');

    try {
      // Find existing shared room
      final myChats = await _client
          .from('core_chat_members')
          .select('chat_id')
          .eq('user_id', myId);

      final myChatIds =
          (myChats as List).map((r) => r['chat_id'] as String).toList();

      if (myChatIds.isNotEmpty) {
        final shared = await _client
            .from('core_chat_members')
            .select('chat_id')
            .eq('user_id', participantId)
            .inFilter('chat_id', myChatIds)
            .limit(1);

        if ((shared as List).isNotEmpty) {
          final chatId = shared.first['chat_id'] as String;
          final rooms = await _buildRoomsForIds([chatId]);
          if (rooms.isNotEmpty) return rooms.first;
        }
      }

      // Create new room
      final newRoom = await _client
          .from('core_chat')
          .insert({'is_fake': false})
          .select('id, created_at, updated_at')
          .single();

      final chatId = newRoom['id'] as String;

      await _client.from('core_chat_members').insert([
        {'chat_id': chatId, 'user_id': myId},
        {'chat_id': chatId, 'user_id': participantId},
      ]);

      final rooms = await _buildRoomsForIds([chatId]);
      return rooms.isNotEmpty
          ? rooms.first
          : ChatRoomModel(
              id: chatId,
              participants: [],
              updatedAt: newRoom['updated_at'] as String? ?? '',
            );
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Failed to open chat: ${e.toString()}');
    }
  }

  // ─── Messages ────────────────────────────────────────────────────────────────

  Future<List<ChatMessage>> fetchMessages(
    String roomId, {
    String? before,
    int limit = 50,
  }) async {
    try {
      final query = _client
          .from('core_sellermessage')
          .select('id, chat_id, sender_id, content, read, created_at')
          .eq('chat_id', roomId)
          .order('created_at', ascending: false)
          .limit(limit);

      final rows = await query;
      final messages = (rows as List)
          .map((r) => supabaseRowToMessage(r as Map<String, dynamic>))
          .toList();
      return messages.reversed.toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<ChatMessage> sendMessage(String roomId, String content) async {
    final myId = _myId;
    if (myId == null) throw const ServerException('Not authenticated');

    try {
      // Find the other participant to set reciever_id
      final others = await _client
          .from('core_chat_members')
          .select('user_id')
          .eq('chat_id', roomId)
          .neq('user_id', myId)
          .limit(1);

      final receiverId = (others as List).isNotEmpty
          ? others.first['user_id'] as String
          : myId;

      final inserted = await _client
          .from('core_sellermessage')
          .insert({
            'chat_id': roomId,
            'sender_id': myId,
            'reciever_id': receiverId,
            'content': content,
            'read': false,
          })
          .select('id, chat_id, sender_id, content, read, created_at')
          .single();

      // Bump room updated_at
      await _client
          .from('core_chat')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', roomId);

      return supabaseRowToMessage(inserted);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Failed to send message: ${e.toString()}');
    }
  }

  Future<void> markAsRead(String roomId) async {
    final myId = _myId;
    if (myId == null) return;
    try {
      await _client
          .from('core_sellermessage')
          .update({'read': true})
          .eq('chat_id', roomId)
          .eq('reciever_id', myId)
          .eq('read', false);
    } catch (_) {
      // Non-critical
    }
  }

  // ─── Realtime ────────────────────────────────────────────────────────────────

  RealtimeChannel subscribeToMessages(
    String roomId,
    void Function(ChatMessage) onMessage,
  ) {
    final channel = _client
        .channel('chat:$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'core_sellermessage',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_id',
            value: roomId,
          ),
          callback: (payload) {
            final msg = supabaseRowToMessage(payload.newRecord);
            onMessage(msg);
          },
        )
        .subscribe();
    return channel;
  }

  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  String _deriveRole(bool isSuperuser, bool isSeller) {
    if (isSuperuser) return 'ADMIN';
    if (isSeller) return 'VENDOR';
    return 'CUSTOMER';
  }

  Future<List<ChatRoomModel>> _buildRoomsForIds(List<String> chatIds) async {
    if (chatIds.isEmpty) return [];
    final myId = _myId;

    final roomRows = await _client
        .from('core_chat')
        .select('id, created_at, updated_at')
        .inFilter('id', chatIds);

    final participantRows = await _client
        .from('core_chat_members')
        .select(
            'chat_id, user:core_user!user_id(id, first_name, last_name, email, is_superuser, is_seller)',)
        .inFilter('chat_id', chatIds);

    final participantsByChat = <String, List<ChatParticipantModel>>{};
    for (final row in participantRows as List) {
      final chatId = row['chat_id'] as String;
      final u = row['user'] as Map<String, dynamic>?;
      if (u == null) continue;
      final role = _deriveRole(
        u['is_superuser'] as bool? ?? false,
        u['is_seller'] as bool? ?? false,
      );
      participantsByChat.putIfAbsent(chatId, () => []).add(
            ChatParticipantModel(
              id: u['id'] as String,
              firstName: u['first_name'] as String? ?? '',
              lastName: u['last_name'] as String? ?? '',
              email: u['email'] as String? ?? '',
              role: role,
            ),
          );
    }

    final List<dynamic> unreadRows = myId != null
        ? await _client
            .from('core_sellermessage')
            .select('chat_id')
            .eq('reciever_id', myId)
            .eq('read', false)
            .inFilter('chat_id', chatIds)
        : <dynamic>[];

    final unreadByChat = <String, int>{};
    for (final row in unreadRows) {
      final chatId = row['chat_id'] as String;
      unreadByChat[chatId] = (unreadByChat[chatId] ?? 0) + 1;
    }

    return (roomRows as List).map((r) {
      final chatId = r['id'] as String;
      return ChatRoomModel(
        id: chatId,
        participants: participantsByChat[chatId] ?? [],
        updatedAt: r['updated_at'] as String? ??
            r['created_at'] as String? ?? '',
        unreadCount: unreadByChat[chatId] ?? 0,
      );
    }).toList();
  }
}

final chatDatasourceProvider = Provider<ChatDatasource>((ref) {
  return ChatDatasource(ref.watch(supabaseClientProvider));
});
