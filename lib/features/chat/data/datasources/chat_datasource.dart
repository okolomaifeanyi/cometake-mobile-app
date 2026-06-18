import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/supabase/supabase_module.dart';
import '../../domain/entities/chat.dart';
import '../models/chat_model.dart';

class ChatDatasource {
  final Dio _dio;
  final SupabaseClient _client;

  const ChatDatasource(this._dio, this._client);

  // ─── Rooms ──────────────────────────────────────────────────────────────────

  Future<List<ChatRoomModel>> fetchRooms() async {
    try {
      final res = await _dio.get<List<dynamic>>('/api/v1/chat/rooms');
      return (res.data ?? [])
          .map((e) => ChatRoomModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['error']?.toString() ??
          'Failed to load conversations');
    }
  }

  Future<ChatRoomModel> getOrCreateRoom(String participantId) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/chat/rooms',
        data: {'participantId': participantId},
      );
      return ChatRoomModel.fromJson(res.data!);
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data?['error']?.toString() ?? 'Failed to open chat');
    }
  }

  // ─── Messages ────────────────────────────────────────────────────────────────

  Future<List<ChatMessage>> fetchMessages(String roomId,
      {String? before, int limit = 50}) async {
    try {
      // Direct Supabase read — simpler and avoids Bearer token issue on Next.js
      var query = _client
          .from('core_sellermessage')
          .select('id, chat_id, sender_id, content, read, created_at')
          .eq('chat_id', roomId)
          .order('created_at', ascending: false)
          .limit(limit);

      final rows = await query;
      final messages = (rows as List)
          .map((r) => supabaseRowToMessage(r as Map<String, dynamic>))
          .toList();
      return messages.reversed.toList(); // oldest first
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<ChatMessage> sendMessage(String roomId, String content) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/chat/rooms/$roomId/messages',
        data: {'content': content},
      );
      return ChatMessageModel.fromJson(res.data!).toEntity();
    } on DioException catch (e) {
      throw ServerException(
          e.response?.data?['error']?.toString() ?? 'Failed to send message');
    }
  }

  Future<void> markAsRead(String roomId) async {
    try {
      await _dio.post<void>('/api/v1/chat/rooms/$roomId/read');
    } catch (_) {
      // Mark-as-read failure is non-critical
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
            final msg = supabaseRowToMessage(
                payload.newRecord as Map<String, dynamic>);
            onMessage(msg);
          },
        )
        .subscribe();
    return channel;
  }

  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }
}

final chatDatasourceProvider = Provider<ChatDatasource>((ref) {
  return ChatDatasource(
    ref.watch(dioProvider),
    ref.watch(supabaseClientProvider),
  );
});
