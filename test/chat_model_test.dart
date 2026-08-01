import 'package:cometake/features/chat/data/models/chat_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessageModel.fromJson', () {
    test('maps isBot true from API response', () {
      final json = {
        'id': 'msg-1',
        'roomId': 'room-1',
        'senderId': 'admin-1',
        'content': 'How can I help?',
        'isRead': false,
        'isBot': true,
        'createdAt': '2026-08-01T10:00:00.000Z',
      };
      final model = ChatMessageModel.fromJson(json);
      expect(model.isBot, isTrue);
    });

    test('isBot defaults to false when absent', () {
      final json = {
        'id': 'msg-2',
        'roomId': 'room-1',
        'senderId': 'user-1',
        'content': 'Hi',
        'createdAt': '2026-08-01T10:00:00.000Z',
      };
      final model = ChatMessageModel.fromJson(json);
      expect(model.isBot, isFalse);
    });
  });

  group('ChatRoomModel.fromJson', () {
    test('maps productId, productName, needsHuman from API response', () {
      final json = {
        'id': 'room-1',
        'updatedAt': '2026-08-01T10:00:00.000Z',
        'unreadCount': 2,
        'productId': 'prod-1',
        'productName': 'Blue Sneakers',
        'needsHuman': true,
        'participants': <Map<String, dynamic>>[],
        'messages': <Map<String, dynamic>>[],
      };
      final model = ChatRoomModel.fromJson(json);
      expect(model.productId, 'prod-1');
      expect(model.productName, 'Blue Sneakers');
      expect(model.needsHuman, isTrue);
    });

    test('productId, productName, needsHuman are null/false when absent', () {
      final json = {
        'id': 'room-2',
        'updatedAt': '2026-08-01T10:00:00.000Z',
        'participants': <Map<String, dynamic>>[],
        'messages': <Map<String, dynamic>>[],
      };
      final model = ChatRoomModel.fromJson(json);
      expect(model.productId, isNull);
      expect(model.productName, isNull);
      expect(model.needsHuman, isFalse);
    });

    test('toEntity carries isBot, productId, productName, needsHuman through', () {
      final json = {
        'id': 'room-3',
        'updatedAt': '2026-08-01T10:00:00.000Z',
        'productId': 'prod-2',
        'productName': 'Red Hat',
        'needsHuman': true,
        'participants': <Map<String, dynamic>>[],
        'messages': <Map<String, dynamic>>[
          {
            'id': 'msg-3',
            'roomId': 'room-3',
            'senderId': 'admin-1',
            'content': "I've alerted our support team",
            'isBot': true,
            'createdAt': '2026-08-01T10:00:00.000Z',
          },
        ],
      };
      final model = ChatRoomModel.fromJson(json);
      final entity = model.toEntity();
      expect(entity.productId, 'prod-2');
      expect(entity.productName, 'Red Hat');
      expect(entity.needsHuman, isTrue);
      expect(entity.lastMessage?.isBot, isTrue);
    });
  });

  group('supabaseRowToMessage', () {
    test('reads is_bot from a raw realtime payload row', () {
      final row = {
        'id': 'msg-4',
        'chat_id': 'room-4',
        'sender_id': 'admin-1',
        'content': 'Bot reply via realtime',
        'read': false,
        'is_bot': true,
        'created_at': '2026-08-01T10:00:00.000Z',
      };
      final message = supabaseRowToMessage(row);
      expect(message.isBot, isTrue);
    });

    test('is_bot defaults to false when absent from raw row', () {
      final row = {
        'id': 'msg-5',
        'chat_id': 'room-4',
        'sender_id': 'user-1',
        'content': 'Hello',
        'created_at': '2026-08-01T10:00:00.000Z',
      };
      final message = supabaseRowToMessage(row);
      expect(message.isBot, isFalse);
    });
  });
}
