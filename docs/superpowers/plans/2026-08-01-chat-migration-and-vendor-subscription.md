# Flutter Chat API Migration + Vendor Subscription Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate Flutter chat from direct-Supabase reads/writes to the real Next.js API (so mobile gets AI replies, product-tagged chat, and support routing), add the two entry points needed to actually use it, and replace the now-broken vendor subscription flow with a real Paystack-backed checkout.

**Architecture:** Both `ChatDatasource` and `VendorDatasource` move their write/read operations from direct `SupabaseClient` table queries to `Dio` HTTP calls against the existing Next.js API (mirroring the `Dio` pattern `VendorDatasource` already uses for products). Realtime message delivery in chat stays on direct Supabase `postgres_changes` — unchanged, and correct, since that's what the web app does too. Vendor subscription checkout reuses the existing `OrderPaymentScreen`'s in-app WebView + verify-polling pattern via a new near-identical screen.

**Tech Stack:** Flutter, Riverpod (`AsyncNotifier`/`FutureProvider`), Dio, `freezed`/`json_serializable` for models, `flutter_inappwebview` for the payment WebView, `go_router` for navigation, `flutter_test` for unit tests (this repo's convention is real executable tests against model/logic code — see `test/checkout_payment_test.dart` — not source-regex matching).

## Global Constraints

- Repo scope: only files under `flutter/` are in scope. Never touch `web/`, `backend/`, `mobile/`, or the parent repo.
- This project commits directly to `main` (no feature-branch convention for Flutter, unlike the web repo) — every task commits straight to `main`.
- No changes to `flutter/lib/features/auth/**` — sign-up already works, confirmed no changes needed.
- Every `@freezed` class edit must be followed by regenerating generated files: `dart run build_runner build --delete-conflicting-outputs` (run from `flutter/`).
- Design doc: `flutter/docs/superpowers/specs/2026-08-01-chat-migration-and-vendor-subscription-design.md` — read it if anything below is ambiguous.

---

### Task 1: Chat models — `isBot`, product tagging, `needsHuman`

**Files:**
- Modify: `flutter/lib/features/chat/domain/entities/chat.dart`
- Modify: `flutter/lib/features/chat/data/models/chat_model.dart`
- Test: `flutter/test/chat_model_test.dart` (new)

**Interfaces:**
- Produces: `ChatMessage.isBot: bool`, `ChatRoom.productId: String?`, `ChatRoom.productName: String?`, `ChatRoom.needsHuman: bool` — consumed by Task 4 (bubble styling) and Task 5 (entry points display product context if desired).

- [ ] **Step 1: Write the failing tests**

Create `flutter/test/chat_model_test.dart`:

```dart
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
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/chat_model_test.dart`
Expected: FAIL — `isBot`, `productId`, `productName`, `needsHuman` don't exist yet on these classes.

- [ ] **Step 3: Add the fields to the domain entities**

In `flutter/lib/features/chat/domain/entities/chat.dart`, replace the `ChatRoom` factory (currently lines 20-30):

```dart
@freezed
class ChatRoom with _$ChatRoom {
  const ChatRoom._();

  const factory ChatRoom({
    required String id,
    required List<ChatParticipant> participants,
    required DateTime updatedAt,
    @Default(0) int unreadCount,
    ChatMessage? lastMessage,
    String? productId,
    String? productName,
    @Default(false) bool needsHuman,
  }) = _ChatRoom;

  ChatParticipant? other(String myId) =>
      participants.where((p) => p.id != myId).firstOrNull;
}
```

Replace the `ChatMessage` factory (currently lines 36-48):

```dart
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
    @Default(false) bool isBot,
    ChatParticipant? sender,
  }) = _ChatMessage;

  bool isFromMe(String myId) => senderId == myId;
}
```

- [ ] **Step 4: Add the fields to the data models**

In `flutter/lib/features/chat/data/models/chat_model.dart`, replace `ChatMessageModel` (currently lines 22-36):

```dart
@freezed
class ChatMessageModel with _$ChatMessageModel {
  const factory ChatMessageModel({
    required String id,
    @JsonKey(name: 'roomId') required String roomId,
    @JsonKey(name: 'senderId') required String senderId,
    required String content,
    @Default(false) bool isRead,
    @Default(false) bool isBot,
    @JsonKey(name: 'createdAt') required String createdAt,
    ChatParticipantModel? sender,
  }) = _ChatMessageModel;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);
}
```

Replace `ChatRoomModel` (currently lines 38-51):

```dart
@freezed
class ChatRoomModel with _$ChatRoomModel {
  const factory ChatRoomModel({
    required String id,
    @Default([]) List<ChatParticipantModel> participants,
    @JsonKey(name: 'updatedAt') required String updatedAt,
    @Default(0) int unreadCount,
    // lastMessage embedded as first item of messages array (from API)
    @Default([]) List<ChatMessageModel> messages,
    String? productId,
    String? productName,
    @Default(false) bool needsHuman,
  }) = _ChatRoomModel;

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomModelFromJson(json);
}
```

Replace the `ChatMessageModelX` extension (currently lines 63-73):

```dart
extension ChatMessageModelX on ChatMessageModel {
  ChatMessage toEntity() => ChatMessage(
        id: id,
        roomId: roomId,
        senderId: senderId,
        content: content,
        isRead: isRead,
        isBot: isBot,
        createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
        sender: sender?.toEntity(),
      );
}
```

Replace the `ChatRoomModelX` extension (currently lines 75-84):

```dart
extension ChatRoomModelX on ChatRoomModel {
  ChatRoom toEntity() => ChatRoom(
        id: id,
        participants: participants.map((p) => p.toEntity()).toList(),
        updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
        unreadCount: unreadCount,
        lastMessage:
            messages.isNotEmpty ? messages.first.toEntity() : null,
        productId: productId,
        productName: productName,
        needsHuman: needsHuman,
      );
}
```

Replace `supabaseRowToMessage` (currently lines 88-98):

```dart
ChatMessage supabaseRowToMessage(Map<String, dynamic> row) {
  return ChatMessage(
    id: row['id'] as String,
    roomId: row['chat_id'] as String,
    senderId: row['sender_id'] as String,
    content: row['content'] as String,
    isRead: row['read'] as bool? ?? false,
    isBot: row['is_bot'] as bool? ?? false,
    createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
        DateTime.now(),
  );
}
```

- [ ] **Step 5: Regenerate generated files**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: completes with no errors; `chat_model.freezed.dart`, `chat_model.g.dart`, `chat.freezed.dart` are regenerated.

- [ ] **Step 6: Run the tests to verify they pass**

Run: `flutter test test/chat_model_test.dart`
Expected: all 6 tests PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/features/chat/domain/entities/chat.dart lib/features/chat/domain/entities/chat.freezed.dart lib/features/chat/data/models/chat_model.dart lib/features/chat/data/models/chat_model.freezed.dart lib/features/chat/data/models/chat_model.g.dart test/chat_model_test.dart
git commit -m "feat: add isBot, productId, productName, needsHuman to chat models"
```

---

### Task 2: Chat datasource — migrate to the real API

**Files:**
- Modify: `flutter/lib/features/chat/data/datasources/chat_datasource.dart`

**Interfaces:**
- Consumes: `ChatMessageModel`/`ChatRoomModel` (Task 1), `dioProvider` from `flutter/lib/core/network/dio_client.dart` (existing), `ServerException`/`AppException` from `flutter/lib/core/errors/app_exception.dart` (existing).
- Produces: `ChatDatasource(Dio, SupabaseClient)` with `fetchRooms()`, `getOrCreateRoom(String participantId)`, `getOrCreateVendorRoom(String vendorId, String productId)` (new), `getSupportRoom()` (new), `fetchMessages(String roomId, {String? before, int limit})`, `sendMessage(String roomId, String content)`, `markAsRead(String roomId)` — all `Future`-returning as today. `subscribeToMessages`/`unsubscribe` unchanged. Consumed by Task 3 (provider layer) and Task 5 (entry points).

- [ ] **Step 1: Rewrite the datasource**

Replace the entire contents of `flutter/lib/features/chat/data/datasources/chat_datasource.dart`:

```dart
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
```

- [ ] **Step 2: Verify it compiles and analyzes clean**

Run: `flutter analyze lib/features/chat/data/datasources/chat_datasource.dart`
Expected: no errors (there will be errors elsewhere in the codebase until Task 3 updates the provider layer's call sites if any signatures changed — `fetchMessages` and the others keep their existing signatures, so `chat_provider.dart` should not need changes yet; if `flutter analyze` on this file alone shows unrelated errors from callers, that's expected and resolved by Task 3).

- [ ] **Step 3: Commit**

```bash
git add lib/features/chat/data/datasources/chat_datasource.dart
git commit -m "feat: migrate ChatDatasource from direct Supabase reads/writes to the API"
```

---

### Task 3: Chat provider — add vendor-room and support-room actions

**Files:**
- Modify: `flutter/lib/features/chat/presentation/providers/chat_provider.dart`

**Interfaces:**
- Consumes: `ChatDatasource.getOrCreateVendorRoom`, `ChatDatasource.getSupportRoom` (Task 2).
- Produces: `ConversationsNotifier.getOrCreateVendorRoom(String vendorId, String productId): Future<ChatRoom?>`, `ConversationsNotifier.getSupportRoom(): Future<ChatRoom?>` — consumed by Task 5 (entry points).

- [ ] **Step 1: Add the two new notifier methods**

In `flutter/lib/features/chat/presentation/providers/chat_provider.dart`, add these two methods to `ConversationsNotifier`, right after the existing `getOrCreate` method (currently lines 30-38):

```dart
  Future<ChatRoom?> getOrCreateVendorRoom(String vendorId, String productId) async {
    try {
      final ds = ref.read(chatDatasourceProvider);
      final model = await ds.getOrCreateVendorRoom(vendorId, productId);
      return model.toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<ChatRoom?> getSupportRoom() async {
    try {
      final ds = ref.read(chatDatasourceProvider);
      final model = await ds.getSupportRoom();
      return model.toEntity();
    } catch (_) {
      return null;
    }
  }
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/features/chat/presentation/providers/chat_provider.dart`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/chat/presentation/providers/chat_provider.dart
git commit -m "feat: add getOrCreateVendorRoom and getSupportRoom to ConversationsNotifier"
```

---

### Task 4: Message bubble — visual distinction for AI replies

**Files:**
- Modify: `flutter/lib/features/chat/presentation/widgets/message_bubble.dart`

**Interfaces:**
- Consumes: `ChatMessage.isBot` (Task 1).

- [ ] **Step 1: Add a small "Cometake Assistant" label above bot messages**

In `flutter/lib/features/chat/presentation/widgets/message_bubble.dart`, replace the `Column` inside the `ConstrainedBox` (currently lines 32-93) — the whole `child: Column(...)` block:

```dart
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe && message.isBot)
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 2, left: AppDimensions.spacingXs,),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.smart_toy_outlined,
                          size: 12, color: theme.colorScheme.onSurfaceVariant,),
                      const SizedBox(width: 4),
                      Text(
                        'Cometake Assistant',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: isMe
                      ? AppColors.primary
                      : (!isMe && message.isBot)
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppDimensions.radiusMd),
                    topRight: const Radius.circular(AppDimensions.radiusMd),
                    bottomLeft: Radius.circular(
                        isMe ? AppDimensions.radiusMd : AppDimensions.radiusXs,),
                    bottomRight: Radius.circular(
                        isMe ? AppDimensions.radiusXs : AppDimensions.radiusMd,),
                  ),
                ),
                child: Text(
                  message.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isMe
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (showTime)
                Padding(
                  padding: const EdgeInsets.only(
                      top: 2,
                      left: AppDimensions.spacingXs,
                      right: AppDimensions.spacingXs,),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Formatters.time(message.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 2),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 12,
                          color: message.isRead
                              ? AppColors.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/features/chat/presentation/widgets/message_bubble.dart`
Expected: no errors.

- [ ] **Step 3: Manual verification note**

No automated widget test for this — this repo has no existing widget-test convention for chat UI. Note in your report that a human should manually confirm bot messages show the "Cometake Assistant" label and tinted background once the app is run.

- [ ] **Step 4: Commit**

```bash
git add lib/features/chat/presentation/widgets/message_bubble.dart
git commit -m "feat: visually distinguish AI bot replies in chat"
```

---

### Task 5: Chat entry points — Message Seller + Help & Support

**Files:**
- Modify: `flutter/lib/features/products/presentation/screens/product_detail_screen.dart`
- Modify: `flutter/lib/features/profile/presentation/screens/profile_screen.dart`

**Interfaces:**
- Consumes: `conversationsProvider.notifier.getOrCreateVendorRoom`/`getSupportRoom` (Task 3), `AppRoutes.conversationPath` (existing, `flutter/lib/core/router/app_routes.dart:36`).

- [ ] **Step 1: Add "Message Seller" to the product detail app bar**

In `flutter/lib/features/products/presentation/screens/product_detail_screen.dart`, add this import at the top (alongside the existing ones):

```dart
import '../../../chat/presentation/providers/chat_provider.dart';
```

Replace the `AppBar`'s `actions` (currently line 82, `actions: [_WishlistButton(productId: product.id)],`):

```dart
        actions: [
          if (product.vendor != null) _MessageSellerButton(product: product),
          _WishlistButton(productId: product.id),
        ],
```

Add this new widget right after the `_WishlistButton` class definition (currently ends around line 584, right before `_DetailRow`):

```dart
class _MessageSellerButton extends ConsumerWidget {
  final Product product;
  const _MessageSellerButton({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.spacingSm),
      decoration: const BoxDecoration(
        color: Colors.black38,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.chat_bubble_outline_rounded,
            color: Colors.white, size: 20,),
        tooltip: 'Message Seller',
        onPressed: () async {
          final room = await ref
              .read(conversationsProvider.notifier)
              .getOrCreateVendorRoom(product.vendor!.id, product.id);
          if (!context.mounted) return;
          if (room == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not start chat. Please try again.'),
              ),
            );
            return;
          }
          context.push(AppRoutes.conversationPath(room.id));
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Rewire "Help & Support" to open in-app support chat**

In `flutter/lib/features/profile/presentation/screens/profile_screen.dart`, add this import at the top:

```dart
import '../../../chat/presentation/providers/chat_provider.dart';
```

Replace the "Help & Support" `_MenuEntry` (currently lines 115-122):

```dart
                _MenuEntry(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  onTap: () => _openSupportChat(context, ref),
                ),
```

Add this top-level private function at the bottom of the file (after the last class definition):

```dart
Future<void> _openSupportChat(BuildContext context, WidgetRef ref) async {
  final room = await ref.read(conversationsProvider.notifier).getSupportRoom();
  if (!context.mounted) return;
  if (room == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open support chat. Please try again.'),
      ),
    );
    return;
  }
  context.push(AppRoutes.conversationPath(room.id));
}
```

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze lib/features/products/presentation/screens/product_detail_screen.dart lib/features/profile/presentation/screens/profile_screen.dart`
Expected: no errors.

- [ ] **Step 4: Manual verification note**

No automated test — note in your report that a human should manually confirm: (a) tapping the chat icon on a product page opens a chat with that product's seller, tagged so the AI can answer product questions; (b) tapping "Help & Support" in profile opens an in-app support chat instead of an external browser link.

- [ ] **Step 5: Commit**

```bash
git add lib/features/products/presentation/screens/product_detail_screen.dart lib/features/profile/presentation/screens/profile_screen.dart
git commit -m "feat: add Message Seller and in-app Help & Support chat entry points"
```

---

### Task 6: Vendor subscription models

**Files:**
- Create: `flutter/lib/features/vendor/data/models/subscription_checkout_result_model.dart`
- Modify: `flutter/lib/features/vendor/data/models/subscription_models.dart`
- Test: `flutter/test/subscription_models_test.dart` (new)

**Interfaces:**
- Produces: `SubscriptionCheckoutResultModel { authorizationUrl: String?, reference: String? }` with `fromJson` reading snake_case `authorization_url`/`reference`; `SubscriptionPlan` gains `billingPeriod: String`, `durationDays: int?`, and its `fromJson` now parses the API's camelCase shape instead of a raw DB row; `VendorSubscription` gains `plan: SubscriptionPlan?` and its `fromJson` parses the API's camelCase shape. Consumed by Task 7 (datasource) and Task 8 (subscribe flow/UI).

- [ ] **Step 1: Write the failing tests**

Create `flutter/test/subscription_models_test.dart`:

```dart
import 'package:cometake/features/vendor/data/models/subscription_checkout_result_model.dart';
import 'package:cometake/features/vendor/data/models/subscription_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionCheckoutResultModel.fromJson', () {
    test('reads snake_case authorization_url and reference', () {
      final json = {
        'authorization_url': 'https://checkout.paystack.com/xyz',
        'reference': 'SUB-123-abc',
      };
      final model = SubscriptionCheckoutResultModel.fromJson(json);
      expect(model.authorizationUrl, 'https://checkout.paystack.com/xyz');
      expect(model.reference, 'SUB-123-abc');
    });

    test('fields are null when absent', () {
      final model = SubscriptionCheckoutResultModel.fromJson(<String, dynamic>{});
      expect(model.authorizationUrl, isNull);
      expect(model.reference, isNull);
    });
  });

  group('SubscriptionPlan.fromJson (API shape)', () {
    test('maps monthly plan with features array directly (not plan_description)', () {
      final json = {
        'id': 'plan-1',
        'name': 'Starter',
        'slug': 'starter',
        'description': 'For new sellers',
        'price': 2000,
        'features': ['Feature A', 'Feature B'],
        'productLimit': 50,
        'isActive': true,
        'billingPeriod': 'monthly',
      };
      final plan = SubscriptionPlan.fromJson(json);
      expect(plan.name, 'Starter');
      expect(plan.price, 2000.0);
      expect(plan.features, ['Feature A', 'Feature B']);
      expect(plan.productLimit, 50);
      expect(plan.billingPeriod, 'monthly');
      expect(plan.durationDays, isNull);
    });

    test('maps anytime plan with durationDays', () {
      final json = {
        'id': 'plan-2',
        'name': 'Trial',
        'slug': 'trial',
        'price': 500,
        'features': <String>[],
        'productLimit': 10,
        'isActive': true,
        'billingPeriod': 'anytime',
        'durationDays': 45,
      };
      final plan = SubscriptionPlan.fromJson(json);
      expect(plan.billingPeriod, 'anytime');
      expect(plan.durationDays, 45);
    });
  });

  group('VendorSubscription.fromJson (API shape)', () {
    test('maps camelCase fields and nested plan', () {
      final json = {
        'id': 'sub-1',
        'userId': 'user-1',
        'planId': 'plan-1',
        'status': 'ACTIVE',
        'startDate': '2026-08-01T00:00:00.000Z',
        'endDate': '2026-09-01T00:00:00.000Z',
        'plan': {
          'id': 'plan-1',
          'name': 'Starter',
          'slug': 'starter',
          'price': 2000,
          'features': <String>[],
          'productLimit': 50,
          'isActive': true,
          'billingPeriod': 'monthly',
        },
      };
      final sub = VendorSubscription.fromJson(json);
      expect(sub.userId, 'user-1');
      expect(sub.planId, 'plan-1');
      expect(sub.plan?.name, 'Starter');
      expect(sub.plan?.billingPeriod, 'monthly');
    });

    test('plan is null when absent', () {
      final json = {
        'id': 'sub-2',
        'userId': 'user-2',
        'planId': 'plan-2',
        'status': 'ACTIVE',
        'startDate': '2026-08-01T00:00:00.000Z',
        'endDate': '2026-09-01T00:00:00.000Z',
      };
      final sub = VendorSubscription.fromJson(json);
      expect(sub.plan, isNull);
    });

    test('isActive is true only when status is ACTIVE and endDate is in the future', () {
      final future = DateTime.now().add(const Duration(days: 10));
      final json = {
        'id': 'sub-3',
        'userId': 'user-3',
        'planId': 'plan-3',
        'status': 'ACTIVE',
        'startDate': '2026-08-01T00:00:00.000Z',
        'endDate': future.toIso8601String(),
      };
      expect(VendorSubscription.fromJson(json).isActive, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/subscription_models_test.dart`
Expected: FAIL — `SubscriptionCheckoutResultModel` doesn't exist yet; `SubscriptionPlan.fromJson`/`VendorSubscription.fromJson` still expect the old raw-DB-row shape.

- [ ] **Step 3: Create `SubscriptionCheckoutResultModel`**

Create `flutter/lib/features/vendor/data/models/subscription_checkout_result_model.dart`:

```dart
class SubscriptionCheckoutResultModel {
  final String? authorizationUrl;
  final String? reference;

  const SubscriptionCheckoutResultModel({
    this.authorizationUrl,
    this.reference,
  });

  factory SubscriptionCheckoutResultModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionCheckoutResultModel(
      authorizationUrl: json['authorization_url'] as String?,
      reference: json['reference'] as String?,
    );
  }
}
```

- [ ] **Step 4: Rewrite `SubscriptionPlan` and `VendorSubscription` for the API shape**

Replace the entire contents of `flutter/lib/features/vendor/data/models/subscription_models.dart`:

```dart
class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final String? description;
  final List<String> features;
  final int productLimit;
  final bool isActive;
  final String billingPeriod;
  final int? durationDays;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.features,
    required this.productLimit,
    required this.isActive,
    required this.billingPeriod,
    this.durationDays,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'];
    final features = rawFeatures is List
        ? rawFeatures.map((e) => e.toString()).toList()
        : <String>[];
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      features: features,
      productLimit: (json['productLimit'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      billingPeriod: json['billingPeriod'] as String? ?? 'yearly',
      durationDays: (json['durationDays'] as num?)?.toInt(),
    );
  }
}

class VendorSubscription {
  final String id;
  final String userId;
  final String planId;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final SubscriptionPlan? plan;

  const VendorSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.plan,
  });

  bool get isActive => status == 'ACTIVE' && endDate.isAfter(DateTime.now());

  factory VendorSubscription.fromJson(Map<String, dynamic> json) {
    final rawPlan = json['plan'];
    return VendorSubscription(
      id: json['id'] as String,
      userId: json['userId'] as String,
      planId: json['planId'] as String,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      plan: rawPlan is Map<String, dynamic>
          ? SubscriptionPlan.fromJson(rawPlan)
          : null,
    );
  }
}
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `flutter test test/subscription_models_test.dart`
Expected: all 7 tests PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/vendor/data/models/subscription_checkout_result_model.dart lib/features/vendor/data/models/subscription_models.dart test/subscription_models_test.dart
git commit -m "feat: rewrite subscription models for the real API's camelCase shape"
```

---

### Task 7: Vendor datasource — migrate to the real API

**Files:**
- Modify: `flutter/lib/features/vendor/data/datasources/vendor_datasource.dart`

**Interfaces:**
- Consumes: `SubscriptionPlan`, `VendorSubscription`, `SubscriptionCheckoutResultModel` (Task 6).
- Produces: `VendorDatasource.getPlans(): Future<List<SubscriptionPlan>>`, `getMySubscription(): Future<VendorSubscription?>` (both now API-backed), `checkoutPlan(String planId): Future<SubscriptionCheckoutResultModel>` (replaces `subscribeToPlan`) — consumed by Task 8.

- [ ] **Step 1: Replace the subscription methods**

In `flutter/lib/features/vendor/data/datasources/vendor_datasource.dart`, add this import at the top:

```dart
import '../models/subscription_checkout_result_model.dart';
```

Replace `getPlans` (currently lines 89-102):

```dart
  Future<List<SubscriptionPlan>> getPlans() async {
    try {
      final res = await _dio.get<List<dynamic>>('/api/v1/subscriptions/plans');
      final rows = res.data ?? [];
      return rows
          .map((r) => SubscriptionPlan.fromJson(r as Map<String, dynamic>))
          .where((p) => p.isActive)
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['error']?.toString() ?? 'Failed to load plans',
        statusCode: e.response?.statusCode,
      );
    }
  }
```

Replace `getMySubscription` (currently lines 104-118):

```dart
  Future<VendorSubscription?> getMySubscription() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/subscriptions/vendor/$userId',
      );
      return VendorSubscription.fromJson(res.data ?? {});
    } on DioException catch (e) {
      // 404 means "no subscription yet" — a valid, expected state, not an error.
      if (e.response?.statusCode == 404) return null;
      throw ServerException(
        e.response?.data?['error']?.toString() ?? 'Failed to load subscription',
        statusCode: e.response?.statusCode,
      );
    }
  }
```

Replace `subscribeToPlan` (currently lines 120-133):

```dart
  Future<SubscriptionCheckoutResultModel> checkoutPlan(String planId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw const AuthException('Not authenticated');
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/subscriptions/vendor/$userId/checkout/$planId',
      );
      return SubscriptionCheckoutResultModel.fromJson(res.data ?? {});
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['error']?.toString() ?? 'Checkout failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/features/vendor/data/datasources/vendor_datasource.dart`
Expected: errors will appear at this point from `vendor_provider.dart` still calling the removed `subscribeToPlan` — that's expected and resolved in Task 8. No errors should appear inside this file itself.

- [ ] **Step 3: Commit**

```bash
git add lib/features/vendor/data/datasources/vendor_datasource.dart
git commit -m "feat: migrate VendorDatasource subscription methods to the real API"
```

---

### Task 8: Subscribe flow — checkout, payment screen, plan display

**Files:**
- Create: `flutter/lib/features/vendor/presentation/screens/subscription_payment_screen.dart`
- Modify: `flutter/lib/features/vendor/presentation/providers/vendor_provider.dart`
- Modify: `flutter/lib/features/vendor/presentation/screens/become_seller_screen.dart`
- Modify: `flutter/lib/core/router/app_routes.dart`
- Modify: `flutter/lib/core/router/app_router.dart`

**Interfaces:**
- Consumes: `VendorDatasource.checkoutPlan` (Task 7), `SubscriptionCheckoutResultModel` (Task 6), the existing `dioProvider` and `/api/v1/payments/verify` contract already used by `OrderPaymentScreen`.
- Produces: `AppRoutes.subscriptionPayment` / `AppRoutes.subscriptionPaymentPath(String)`, `SubscriptionPaymentScreen(result: SubscriptionCheckoutResultModel)`.

- [ ] **Step 1: Add the route constant**

In `flutter/lib/core/router/app_routes.dart`, add after the `orderPayment` lines (currently lines 48-51, at the end of the file before the closing `}`):

```dart

  // Subscription payment WebView — receives SubscriptionCheckoutResultModel via GoRouter extra.
  static const subscriptionPayment = '/vendor/subscription-payment';
```

- [ ] **Step 2: Update `SubscribeNotifier` to return the checkout result**

In `flutter/lib/features/vendor/presentation/providers/vendor_provider.dart`, replace `SubscribeState` and `SubscribeNotifier` (currently lines 188-219):

```dart
class SubscribeState {
  final bool isLoading;
  final String? error;

  const SubscribeState({this.isLoading = false, this.error});

  SubscribeState copyWith({bool? isLoading, String? error}) =>
      SubscribeState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class SubscribeNotifier extends AutoDisposeNotifier<SubscribeState> {
  @override
  SubscribeState build() => const SubscribeState();

  Future<SubscriptionCheckoutResultModel?> subscribe(String planId) async {
    state = const SubscribeState(isLoading: true);
    try {
      final result = await ref.read(vendorDatasourceProvider).checkoutPlan(planId);
      state = const SubscribeState();
      return result;
    } catch (e) {
      state = SubscribeState(error: e.toString());
      return null;
    }
  }
}

final subscribeNotifierProvider =
    AutoDisposeNotifierProvider<SubscribeNotifier, SubscribeState>(
        () => SubscribeNotifier(),);
```

Add this import at the top of `vendor_provider.dart` (alongside the existing ones):

```dart
import '../../data/models/subscription_checkout_result_model.dart';
```

- [ ] **Step 3: Update `BecomeSellerScreen`: async subscribe + navigate, and show the billing period**

In `flutter/lib/features/vendor/presentation/screens/become_seller_screen.dart`, add these imports at the top:

```dart
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../data/models/subscription_checkout_result_model.dart';
```

Replace the `build` method's `ref.listen` block and the `_PlanCard` construction (currently lines 17-26 and 146-153) — replace the whole `Widget build(BuildContext context, WidgetRef ref)` method body from its start through the `plansAsync.when(...)` call's `data:` case's `_PlanCard` construction:

Remove the `ref.listen(subscribeNotifierProvider, ...)` block entirely (lines 17-26) — success is no longer a single boolean flip, it's "checkout succeeded, now go pay."

Replace the `onSubscribe` callback passed to `_PlanCard` (currently lines 150-152):

```dart
                    onSubscribe: () async {
                      final result = await ref
                          .read(subscribeNotifierProvider.notifier)
                          .subscribe(plans[i].id);
                      if (!context.mounted || result == null) return;
                      if (result.authorizationUrl == null || result.reference == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not start checkout. Please try again.'),
                          ),
                        );
                        return;
                      }
                      context.push(AppRoutes.subscriptionPayment, extra: result);
                    },
```

Add a `periodSuffix` helper function right after the imports, before `class BecomeSellerScreen`:

```dart
String periodSuffix(SubscriptionPlan plan) {
  if (plan.billingPeriod == 'monthly') return '/month';
  if (plan.billingPeriod == 'anytime') return '/${plan.durationDays ?? '?'} days';
  return '/year';
}
```

Replace the hardcoded `'/month'` text in `_PlanCard` (currently lines 299-305):

```dart
                    Text(
                      periodSuffix(plan),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                      ),
                    ),
```

- [ ] **Step 4: Create `SubscriptionPaymentScreen`**

Create `flutter/lib/features/vendor/presentation/screens/subscription_payment_screen.dart`, closely mirroring `flutter/lib/features/orders/presentation/screens/order_payment_screen.dart`'s structure but for subscription checkout:

```dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/subscription_checkout_result_model.dart';
import '../providers/vendor_provider.dart';

// ── Allowed Paystack domains ──────────────────────────────────────────────────
const _kAllowedHosts = {
  'checkout.paystack.com',
  'paystack.com',
  'standard.paystack.com',
  'api.paystack.co',
  'hostedpay.gtbank.com',
  'pay.opay.ng',
  'netpay.firstbanknigeria.com',
};

// Subscription checkout's callback_url defaults to this path (Flutter omits
// the optional returnPath param, so the web endpoint uses its default). The
// WebView intercepts navigation to this path before the page ever loads —
// the underlying Next.js page's own content is irrelevant to this flow.
const _kCallbackHost = 'cometake.net';
const _kCallbackPaths = ['/seller-onboarding/subscription/verify'];

const _kMaxVerifyRetries = 8;

class SubscriptionPaymentScreen extends ConsumerStatefulWidget {
  final SubscriptionCheckoutResultModel result;

  const SubscriptionPaymentScreen({super.key, required this.result});

  @override
  ConsumerState<SubscriptionPaymentScreen> createState() =>
      _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState
    extends ConsumerState<SubscriptionPaymentScreen> {
  late final SubscriptionCheckoutResultModel _result = widget.result;

  bool _webLoading = true;
  bool _externalLaunched = false;
  _PaymentPhase _phase = _PaymentPhase.webview;
  String? _errorMessage;
  bool _navigated = false;

  static final _webSettings = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
  );

  bool _isCallbackUrl(WebUri? uri) {
    if (uri == null) return false;
    if (uri.host != _kCallbackHost) return false;
    return _kCallbackPaths.any((p) => uri.path.startsWith(p));
  }

  bool _isAllowedHost(WebUri? uri) {
    if (uri == null) return true;
    final scheme = uri.scheme;
    if (scheme != 'http' && scheme != 'https') return false;
    return _kAllowedHosts.contains(uri.host) || uri.host == _kCallbackHost;
  }

  void _onPaymentAttemptComplete() {
    if (_navigated) return;
    setState(() => _phase = _PaymentPhase.verifying);
    _verifyPayment();
  }

  Future<void> _verifyPayment() async {
    final reference = _result.reference;
    if (reference == null) {
      _onVerifyFailed('Payment reference missing — please contact support.');
      return;
    }

    final dio = ref.read(dioProvider);
    int attempt = 0;
    int delayMs = 2000;

    while (attempt < _kMaxVerifyRetries) {
      try {
        final response = await dio.post<Map<String, dynamic>>(
          '/api/v1/payments/verify',
          data: {'reference': reference, 'source': 'FLUTTER'},
        );

        final body   = response.data ?? {};
        final status = body['status'] as String? ?? '';

        if (status == 'success') {
          _onVerifySuccess();
          return;
        }

        if (status == 'pending') {
          await Future<void>.delayed(Duration(milliseconds: delayMs));
          delayMs = (delayMs * 1.5).round().clamp(0, 8000);
          attempt++;
          continue;
        }

        _onVerifyFailed(body['message'] as String? ?? 'Payment was not successful.');
        return;
      } on DioException catch (e) {
        final status = e.response?.statusCode ?? 0;
        if (status == 503 && attempt < _kMaxVerifyRetries - 1) {
          await Future<void>.delayed(Duration(milliseconds: delayMs));
          delayMs = (delayMs * 1.5).round().clamp(0, 8000);
          attempt++;
          continue;
        }
        _onVerifyFailed('Could not confirm payment. Please check My Store shortly.');
        return;
      } catch (_) {
        _onVerifyFailed('Could not confirm payment. Please check My Store shortly.');
        return;
      }
    }

    _onVerifyFailed('Payment is still processing. Please check back shortly.');
  }

  void _onVerifySuccess() {
    if (_navigated || !mounted) return;
    _navigated = true;
    setState(() => _phase = _PaymentPhase.success);

    ref.invalidate(myVendorSubscriptionProvider);
    ref.invalidate(subscriptionPlansProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Welcome! Your store is now active.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );

    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        context.go(AppRoutes.vendor);
      }),
    );
  }

  void _onVerifyFailed(String message) {
    if (!mounted) return;
    setState(() {
      _phase        = _PaymentPhase.failed;
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: _phase == _PaymentPhase.webview
            ? IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Cancel payment',
                onPressed: () => context.go(AppRoutes.vendor),
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: switch (_phase) {
        _PaymentPhase.webview  => _buildWebView(),
        _PaymentPhase.verifying => _buildVerifying(),
        _PaymentPhase.success  => _buildSuccess(),
        _PaymentPhase.failed   => _buildFailed(),
      },
    );
  }

  Widget _buildWebView() {
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(_result.authorizationUrl!),
          ),
          initialSettings: _webSettings,
          onLoadStart: (_, __) {
            if (mounted) setState(() => _webLoading = true);
          },
          onLoadStop: (_, __) {
            if (mounted) setState(() => _webLoading = false);
          },
          onProgressChanged: (_, progress) {
            if (progress == 100 && mounted) setState(() => _webLoading = false);
          },
          shouldOverrideUrlLoading: (controller, action) async {
            final uri    = action.request.url;
            final scheme = uri?.scheme ?? '';

            if (_isCallbackUrl(uri)) {
              _onPaymentAttemptComplete();
              return NavigationActionPolicy.CANCEL;
            }

            if (scheme != 'http' && scheme != 'https') {
              unawaited(
                launchUrl(
                  Uri.parse(uri.toString()),
                  mode: LaunchMode.externalApplication,
                ).catchError((_) => false),
              );
              if (mounted) setState(() => _externalLaunched = true);
              return NavigationActionPolicy.CANCEL;
            }

            if (!_isAllowedHost(uri)) {
              return NavigationActionPolicy.CANCEL;
            }

            return NavigationActionPolicy.ALLOW;
          },
        ),
        if (_webLoading && !_externalLaunched)
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        if (_externalLaunched) _buildExternalOverlay(),
      ],
    );
  }

  Widget _buildExternalOverlay() {
    return Positioned(
      left: 0, right: 0, bottom: 0,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smartphone_outlined, size: 40, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              'Complete your payment in the app that opened,\n'
              'then tap below to confirm.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _onPaymentAttemptComplete,
                icon: const Icon(Icons.verified_outlined),
                label: const Text("I've Paid — Confirm"),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(AppRoutes.vendor),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifying() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(strokeWidth: 2),
          SizedBox(height: 20),
          Text('Confirming your payment…', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text('Please do not close this screen.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, color: AppColors.success, size: 64),
          SizedBox(height: 16),
          Text('Payment confirmed!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFailed() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 56),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Payment could not be confirmed.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                setState(() {
                  _phase        = _PaymentPhase.verifying;
                  _errorMessage = null;
                });
                _verifyPayment();
              },
              child: const Text('Retry Verification'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(AppRoutes.vendor),
              child: const Text('Back to My Store'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PaymentPhase { webview, verifying, success, failed }
```

- [ ] **Step 5: Register the route**

In `flutter/lib/core/router/app_router.dart`, add this import alongside the existing feature imports:

```dart
import '../../features/vendor/data/models/subscription_checkout_result_model.dart';
import '../../features/vendor/presentation/screens/subscription_payment_screen.dart';
```

Add this `GoRoute` right after the order-payment `GoRoute` (currently ends at line 224, the closing `),` before the ShellRoute-closing `],`) — i.e. inside the same top-level `routes:` list, alongside (not inside) the order-payment route:

```dart
        GoRoute(
          path: AppRoutes.subscriptionPayment,
          redirect: (_, state) => state.extra is SubscriptionCheckoutResultModel
              ? null
              : AppRoutes.vendor,
          builder: (_, state) => SubscriptionPaymentScreen(
            result: state.extra! as SubscriptionCheckoutResultModel,
          ),
        ),
```

- [ ] **Step 6: Regenerate generated files and verify compilation**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter analyze lib/features/vendor lib/core/router`
Expected: no errors.

- [ ] **Step 7: Manual verification note**

No automated test for this screen (matches `OrderPaymentScreen`, which also has none — this repo's convention is manual verification for Paystack WebView flows). Note in your report that a human should manually run the full become-a-seller flow against Paystack test mode: pick a plan, complete payment, confirm the app returns to the vendor tab showing the real dashboard (not `BecomeSellerScreen`) with the correct expiry.

- [ ] **Step 8: Commit**

```bash
git add lib/features/vendor/presentation/screens/subscription_payment_screen.dart lib/features/vendor/presentation/providers/vendor_provider.dart lib/features/vendor/presentation/screens/become_seller_screen.dart lib/core/router/app_routes.dart lib/core/router/app_router.dart
git commit -m "feat: real Paystack checkout for vendor subscriptions"
```

---

### Task 9: Full regression pass

**Files:** none (verification only)

- [ ] **Step 1: Run the full test suite**

Run: `flutter test`
Expected: all tests pass, including the 6 new tests in `chat_model_test.dart` and 7 new tests in `subscription_models_test.dart`, alongside the existing suite (`auth_model_and_entities_test.dart`, `cart_and_product_test.dart`, `checkout_payment_test.dart`, `failure_and_error_handler_test.dart`, `formatters_test.dart`, `validators_test.dart`, `widget_test.dart`).

- [ ] **Step 2: Run static analysis on the whole project**

Run: `flutter analyze`
Expected: no errors (warnings pre-existing before this plan are not this plan's responsibility to fix — only introduce none new).

- [ ] **Step 3: Manual E2E checklist (for the human to run — not the agent)**

1. As a buyer: send a message via "Message Seller" on a product page, confirm an AI reply arrives (or `[NEEDS_HUMAN]` escalates correctly for a support question).
2. As a buyer: tap "Help & Support" in profile, confirm it opens an in-app chat, not an external browser.
3. As a new vendor: go through "Become a Seller," pick a plan, pay via Paystack test mode, confirm the app returns to a real vendor dashboard (not the plan-picker) with the correct plan/expiry.
4. Confirm the plan cards show the correct billing-period suffix ("/month", "/year", or "/N days") matching what admin configured on the web side.

- [ ] **Step 4: Fix anything found (only if needed)**

If Steps 1-2 reveal a regression, fix it and commit with a `fix:` message before moving to Task 10. Skip this step if nothing was found.

---

### Task 10: Version bump and push

**Files:**
- Modify: `flutter/pubspec.yaml`

- [ ] **Step 1: Bump the build number**

In `flutter/pubspec.yaml`, replace line 4:

```yaml
version: 1.0.0+4
```

(Current value is `1.0.0+3` — this is a build-number-only bump, not a version change, matching this repo's existing pattern of incrementing just the number after `+` for routine releases.)

- [ ] **Step 2: Commit**

```bash
git add pubspec.yaml
git commit -m "chore: bump build number to 1.0.0+4"
```

- [ ] **Step 3: Push to origin/main**

```bash
git push origin main
```

Report the final commit range and confirm the push succeeded.
