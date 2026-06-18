import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/chat.dart';

part 'chat_model.freezed.dart';
part 'chat_model.g.dart';

@freezed
class ChatParticipantModel with _$ChatParticipantModel {
  const factory ChatParticipantModel({
    required String id,
    @JsonKey(name: 'firstName') required String firstName,
    @JsonKey(name: 'lastName') required String lastName,
    @Default('') String email,
    @Default('CUSTOMER') String role,
  }) = _ChatParticipantModel;

  factory ChatParticipantModel.fromJson(Map<String, dynamic> json) =>
      _$ChatParticipantModelFromJson(json);
}

@freezed
class ChatMessageModel with _$ChatMessageModel {
  const factory ChatMessageModel({
    required String id,
    @JsonKey(name: 'roomId') required String roomId,
    @JsonKey(name: 'senderId') required String senderId,
    required String content,
    @Default(false) bool isRead,
    @JsonKey(name: 'createdAt') required String createdAt,
    ChatParticipantModel? sender,
  }) = _ChatMessageModel;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);
}

@freezed
class ChatRoomModel with _$ChatRoomModel {
  const factory ChatRoomModel({
    required String id,
    @Default([]) List<ChatParticipantModel> participants,
    @JsonKey(name: 'updatedAt') required String updatedAt,
    @Default(0) int unreadCount,
    // lastMessage embedded as first item of messages array (from API)
    @Default([]) List<ChatMessageModel> messages,
  }) = _ChatRoomModel;

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomModelFromJson(json);
}

extension ChatParticipantModelX on ChatParticipantModel {
  ChatParticipant toEntity() => ChatParticipant(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
      );
}

extension ChatMessageModelX on ChatMessageModel {
  ChatMessage toEntity() => ChatMessage(
        id: id,
        roomId: roomId,
        senderId: senderId,
        content: content,
        isRead: isRead,
        createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
        sender: sender?.toEntity(),
      );
}

extension ChatRoomModelX on ChatRoomModel {
  ChatRoom toEntity() => ChatRoom(
        id: id,
        participants: participants.map((p) => p.toEntity()).toList(),
        updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
        unreadCount: unreadCount,
        lastMessage:
            messages.isNotEmpty ? messages.first.toEntity() : null,
      );
}

// ─── Raw Supabase row mapper (for direct DB reads) ────────────────────────────

ChatMessage supabaseRowToMessage(Map<String, dynamic> row) {
  return ChatMessage(
    id: row['id'] as String,
    roomId: row['chat_id'] as String,
    senderId: row['sender_id'] as String,
    content: row['content'] as String,
    isRead: row['read'] as bool? ?? false,
    createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
        DateTime.now(),
  );
}
