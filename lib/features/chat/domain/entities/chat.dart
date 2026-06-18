import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';

@freezed
class ChatParticipant with _$ChatParticipant {
  const ChatParticipant._();

  const factory ChatParticipant({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    @Default('CUSTOMER') String role,
  }) = _ChatParticipant;

  String get fullName => '$firstName $lastName'.trim();
}

@freezed
class ChatRoom with _$ChatRoom {
  const ChatRoom._();

  const factory ChatRoom({
    required String id,
    required List<ChatParticipant> participants,
    required DateTime updatedAt,
    @Default(0) int unreadCount,
    ChatMessage? lastMessage,
  }) = _ChatRoom;

  ChatParticipant? other(String myId) =>
      participants.where((p) => p.id != myId).firstOrNull;
}

@freezed
class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  const factory ChatMessage({
    required String id,
    required String roomId,
    required String senderId,
    required String content,
    required DateTime createdAt,
    @Default(false) bool isRead,
    ChatParticipant? sender,
  }) = _ChatMessage;

  bool isFromMe(String myId) => senderId == myId;
}
