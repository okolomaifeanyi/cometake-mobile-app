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
      final rows = res.data ?? [];
      return rows
          .map((r) => ChatRoomModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['error']?.toString() ?? 'Failed to load conversations',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ChatRoomModel> getOrCreateRoom(String participantId) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/chat/rooms',
        data: {'participantId': participantId},
      );
      return ChatRoomModel.fromJson(res.data ?? {});
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['error']?.toString() ?? 'Failed to open chat',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Opens (or reuses) a buyer<->vendor chat tagged to a specific product, so
  /// the server-side AI first-responder can answer with that product's live
  /// price/stock instead of generic support copy.
  Future<ChatRoomModel> getOrCreateVendorRoom(
    String vendorId,
    String productId,
  ) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/chat/rooms',
        data: {'participantId': vendorId, 'productId': productId},
      );
      return ChatRoomModel.fromJson(res.data ?? {});
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['error']?.toString() ?? 'Failed to start chat with seller',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Opens (or reuses) a support chat with an available admin.
  Future<ChatRoomModel> getSupportRoom() async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/chat/support-room',
      );
      return ChatRoomModel.fromJson(res.data ?? {});
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['error']?.toString() ?? 'Failed to open support chat',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ─── Messages ────────────────────────────────────────────────────────────────

  Future<List<ChatMessage>> fetchMessages(
    String roomId, {
    String? before,
    int limit = 50,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/chat/rooms/$roomId/messages',
        queryParameters: {
          if (before != null) 'before': before,
          'limit': limit,
        },
      );
      final data = (res.data?['data'] as List<dynamic>?) ?? [];
      return data
          .map((r) => ChatMessageModel.fromJson(r as Map<String, dynamic>).toEntity())
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['error']?.toString() ?? 'Failed to load messages',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ChatMessage> sendMessage(String roomId, String content) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/chat/rooms/$roomId/messages',
        data: {'content': content},
      );
      return ChatMessageModel.fromJson(res.data ?? {}).toEntity();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['error']?.toString() ?? 'Failed to send message',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> markAsRead(String roomId) async {
    try {
      await _dio.post<void>('/api/v1/chat/rooms/$roomId/read');
    } on DioException {
      // Non-critical — matches the previous direct-Supabase behavior of
      // silently ignoring read-receipt failures.
    }
  }

  // ─── Realtime ────────────────────────────────────────────────────────────────
  // Unchanged: writes go through the API above, but realtime delivery stays on
  // direct Supabase postgres_changes — this is exactly what the web client
  // does too (write via API, subscribe to Postgres changes for live updates).

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
}

final chatDatasourceProvider = Provider<ChatDatasource>((ref) {
  return ChatDatasource(ref.watch(dioProvider), ref.watch(supabaseClientProvider));
});
