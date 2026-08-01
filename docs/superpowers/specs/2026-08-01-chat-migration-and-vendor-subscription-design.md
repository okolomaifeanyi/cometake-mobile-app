# Flutter Chat API Migration + Vendor Subscription Fix — Design

## Purpose

Two independent fixes to the Flutter mobile client, bundled in one pass because both were requested together:

1. **Chat** currently talks directly to Supabase tables (`core_chat`, `core_chat_members`, `core_sellermessage`) instead of the Next.js API the web client uses. This means every mobile-originated chat misses the AI first-responder, product-tagged context, and support-room routing that the web app now has. There is also no way to actually start a chat from the app today — no "Message Seller" button anywhere, and "Help & Support" in the profile screen just opens an external web link instead of in-app chat.
2. **Vendor subscription** is fully broken: `VendorDatasource.subscribeToPlan()` calls the old `POST .../subscribe/{planId}` endpoint, which a recent web change restricted to superusers only (returns `403` unconditionally for a real vendor). There is no Paystack payment step in the Flutter flow at all — subscribing was previously "free," which is no longer true.

Both fixes are scoped to `flutter/` only — no web changes, per this repo's standing rule.

## Requirements

**Chat:**
- Room creation/lookup and message sending move to the real API (`POST /rooms`, `POST /rooms/{roomId}/messages`, `POST /rooms/{roomId}/read`, `POST /chat/support-room`) so the server-side AI responder, product-tagging, and support-room logic fire for mobile the same way they do for web.
- Realtime message delivery stays as direct Supabase `postgres_changes` on `core_sellermessage` — this is not a bug, it's exactly what the web client does too (write via API, subscribe to Postgres changes directly for realtime).
- Add `isBot` to the message model so AI replies render visually distinct from human replies.
- Add a "Message Seller" entry point on the product detail screen (opens/creates a product-tagged room).
- Rewire "Help & Support" in the profile screen to open in-app support chat instead of an external browser link.
- Fetching the room list (`fetchRooms`) also moves to the API for a single source of truth, since the API's `getRooms` already returns `needsHuman`/`productId`/`productName` that the direct-Supabase read doesn't compute.

**Vendor subscription:**
- Replace the dead subscribe call with: `GET /subscriptions/plans` → pick a plan → `POST /subscriptions/vendor/{vendorId}/checkout/{planId}` → open the returned `authorization_url` in an in-app WebView (reusing the existing `OrderPaymentScreen` pattern) → on the app's own callback-path detection, poll `POST /payments/verify` → on success, invalidate the subscription provider and return to the vendor tab, which now shows the real dashboard instead of `BecomeSellerScreen`.
- Plan model gains `billingPeriod`/`durationDays` so plan cards can show "/mo", "/yr", or "/N days" instead of a hardcoded "/month".
- The subscription-status read (`getMySubscription`) also moves to the API (`GET /subscriptions/vendor/{vendorId}`), consistent with using the API as the single source of truth rather than mixing direct-DB reads and API calls for the same feature.

## Architecture

### Chat

```
ChatDatasource (rewritten)
  fetchRooms()        → GET  /api/v1/chat/rooms                     (was: direct Supabase reads)
  getOrCreateRoom(id)  → POST /api/v1/chat/rooms  {participantId}    (was: direct Supabase insert)
  getOrCreateVendorRoom(vendorId, productId)
                       → POST /api/v1/chat/rooms  {participantId, productId}   (NEW method)
  getSupportRoom()     → POST /api/v1/chat/support-room             (NEW method)
  fetchMessages(roomId, {before, limit})
                       → GET  /api/v1/chat/rooms/{roomId}/messages   (was: direct Supabase reads)
  sendMessage(roomId, content)
                       → POST /api/v1/chat/rooms/{roomId}/messages   (was: direct Supabase insert)
  markAsRead(roomId)   → POST /api/v1/chat/rooms/{roomId}/read       (was: direct Supabase update)
  subscribeToMessages(roomId, onMessage)   — UNCHANGED, still direct Supabase postgres_changes
  unsubscribe(channel)                     — UNCHANGED
```

`ChatDatasource` becomes a `Dio`-based datasource (like `VendorDatasource`) instead of a `SupabaseClient`-based one — `ChatRoomModel`/`ChatMessageModel` already have `fromJson` factories shaped for camelCase API JSON (`@JsonKey(name: 'firstName')` etc.), so most of the model layer needs no changes, just two new fields (`isBot`, and `productId`/`productName`/`needsHuman` on the room model) plus deleting the manual Supabase-row-building code the datasource currently does by hand. `chat_provider.dart` needs no interface changes — it calls `ds.methodName()` the same way regardless of what's inside.

New entry points call `getOrCreateVendorRoom`/`getSupportRoom` and then `context.push(AppRoutes.conversationPath(room.id))` — the existing `ConversationScreen` needs no changes to display them.

### Vendor subscription

```
VendorDatasource (rewritten)
  getPlans()           → GET  /api/v1/subscriptions/plans            (was: direct Supabase read)
  getMySubscription()  → GET  /api/v1/subscriptions/vendor/{userId}   (was: direct Supabase read)
  checkoutPlan(planId) → POST /api/v1/subscriptions/vendor/{userId}/checkout/{planId}   (NEW — replaces subscribeToPlan)
```

`checkoutPlan` returns a new `SubscriptionCheckoutResultModel { authorizationUrl, reference }`, parsed from the endpoint's **snake_case** response (`authorization_url`, `reference` — this endpoint mirrors Paystack's own field names, unlike the order-checkout endpoint which returns camelCase; the model's `fromJson` must read the snake_case keys). `SubscribeNotifier.subscribe(planId)` changes from "call API, return bool" to "call checkout, return the checkout-result model (or null on failure)" — mirroring exactly how `CheckoutNotifier.placeOrder()` already works for orders. `BecomeSellerScreen`'s `_PlanCard.onSubscribe` becomes async: on a non-null result, `context.push(AppRoutes.subscriptionPayment, extra: result)`.

A new `SubscriptionPaymentScreen` is a near-copy of `OrderPaymentScreen` (same WebView, same external-app-deep-link fallback, same exponential-backoff verify loop), registered outside the `ShellRoute` the same way order-payment is (hides bottom nav during payment). Its own `_kCallbackPaths` constant is `['/seller-onboarding/subscription/verify']` — the web's default `returnPath` for this endpoint when Flutter omits the (optional, allowlisted) `returnPath` field entirely. The WebView never actually loads that page; it intercepts navigation to it and treats that as "payment attempt complete," identical to how the order flow's callback interception works. On successful verify: invalidate `myVendorSubscriptionProvider` and `subscriptionPlansProvider`, then `context.go(AppRoutes.vendor)` — `VendorDashboardScreen` re-reads the now-active subscription and swaps from `BecomeSellerScreen` to the real dashboard automatically, since that's already how it's wired today.

`★ Insight ─────────────────────────────────────`
The reason this migration is lower-risk than it might sound: both `ChatRoomModel`/`ChatMessageModel` already had `fromJson` factories written for camelCase API JSON, seemingly in anticipation of this exact change, and the provider/notifier layers only ever call `datasource.methodName()` — never touch Supabase directly. That separation of concerns means the rewrite is contained entirely inside two datasource files; nothing above them needs to know or care that the underlying transport changed from Supabase queries to HTTP calls.
`─────────────────────────────────────────────────`

## Data flow — new entry points

**Message Seller (product detail):** button appears in the `ProductDetailScreen` app bar (next to the wishlist heart) when `product.vendor != null` and `product.vendor!.id != myId`. Tap → `ChatDatasource.getOrCreateVendorRoom(vendorId, productId)` → `context.push(AppRoutes.conversationPath(room.id))`.

**Help & Support (profile):** the existing menu entry's `onTap` changes from `launchUrl(...)` to: call `ChatDatasource.getSupportRoom()` → `context.push(AppRoutes.conversationPath(room.id))`. Show a loading indicator/disable the tap while the request is in flight (a support room may need to be created server-side, not just fetched).

## Error handling

| Case | Behavior |
|---|---|
| Chat API call fails (network, 401, 500) | Same `ServerException` pattern already used by `VendorDatasource` — caught, message surfaced via existing UI (snackbar in `ConversationScreen`, error state in `ConversationsScreen`). |
| Vendor subscription checkout fails (plan inactive, gateway not configured) | `SubscribeState.error` shows the server's message in the existing red banner on `BecomeSellerScreen` — no WebView is opened. |
| Subscription payment WebView: transient verify failure (pending/circuit-open) | Same retry/backoff loop as `OrderPaymentScreen` — up to 8 attempts, exponential backoff, capped at 8s between tries. |
| User backgrounds/cancels the subscription WebView | Same as orders: tapping the close button routes back to the vendor tab without completing; no partial state is left behind since nothing is written until the payment actually completes server-side. |

## Testing

Flutter's test convention here is real `flutter_test` unit tests (not source-regex matching, unlike the web repo) — see `test/checkout_payment_test.dart` for the exact style to match. New/updated tests:
- `SubscriptionCheckoutResultModel.fromJson` — reads snake_case `authorization_url`/`reference`, nulls handled.
- `SubscriptionPlan.fromJson` (updated) — now parses the API's camelCase shape (`billingPeriod`, `durationDays`, `features: string[]` directly rather than raw `plan_description` objects) instead of the raw DB row shape.
- `ChatMessageModel`/`ChatRoomModel` `fromJson` — `isBot` field, room-level `productId`/`productName`/`needsHuman`.
- Manual verification (no Paystack sandbox available to an automated agent): full become-a-seller flow in Paystack test mode; sending a message as a buyer and confirming an AI reply arrives; "Message Seller" from a product page; "Help & Support" opening a real support room.

## Out of scope

- The dead compose/menu icons and hardcoded "offline" dot in `ConversationsScreen` — cosmetic, not part of what was asked.
- Typing indicators (web has them via Broadcast; Flutter doesn't, and adding them wasn't requested).
- Showing the other participant's name / product context in `ConversationScreen`'s app bar (currently a static "Chat" title) — a nice-to-have, not required for either fix to work correctly.
- Any change to `flutter/lib/features/auth/**` — sign-up already exists and works; user confirmed nothing needed there.
