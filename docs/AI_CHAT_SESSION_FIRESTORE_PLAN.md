# AI Chat Session Firestore Plan

## Goal
Persist ARS AI chat sessions in Firestore so conversations survive app restarts, stay tied to the correct user/session, and can be audited/debugged.

## Current State (Verified in Code)
- `AiChatScreen` keeps messages in local memory only (`_messages` list).
- User messages and bot replies are not written to Firestore.
- The screen sends `conversation_id` to the chatbot API, but that does not persist data in app Firestore.
- Current session IDs are inconsistent:
  - Global/static in map flow: `booking_map_assistant`
  - User-scoped in waiting flow: `booking_$uid`

## Scope
In scope:
- Firestore schema for AI chat sessions + messages
- App-side write/read flow for user and bot messages
- Security rules for AI chat data
- Session ID strategy and metadata consistency
- Tests + manual verification checklist

Out of scope:
- Changing the external chatbot backend memory implementation
- Analytics/dashboard UI

## Proposed Firestore Data Model
Collection: `ai_chat_sessions/{sessionId}`

Session document fields:
- `id`: string
- `userId`: string
- `contextType`: string (`booking_map`, `booking_waiting`, etc.)
- `contextRef`: string? (booking/request ID when available)
- `createdAt`: server timestamp
- `updatedAt`: server timestamp
- `lastMessagePreview`: string
- `messageCount`: number

Subcollection: `ai_chat_sessions/{sessionId}/messages/{messageId}`

Message document fields:
- `id`: string
- `role`: string (`user` | `assistant` | `system`)
- `content`: string
- `createdAt`: server timestamp
- `clientCreatedAt`: timestamp
- `senderId`: string? (required for user messages)
- `requestId`: string? (link request/response pair)
- `status`: string (`sending` | `sent` | `failed`)
- `error`: string? (only when failed)

## Implementation Plan

### Phase 1: Foundation
1. Create a repository/service for AI chat persistence.
2. Add constants for new collection names.
3. Add message/session models (`toMap/fromMap`) for Firestore compatibility.

Target files:
- `lib/features/customer/booking/data/repositories/` (new AI chat Firestore repository)
- `lib/features/customer/booking/domain/models/` (new session/message models)
- `lib/core/constants/app_constants.dart`

### Phase 2: Wire `AiChatScreen` to Firestore
1. On screen init:
   - Resolve final `sessionId` (see Session ID Strategy below).
   - Ensure session doc exists/updated.
   - Load or stream existing messages ordered by `createdAt`.
2. On send:
   - Immediately write user message to Firestore (`status: sending/sent`).
   - Call chatbot backend.
   - Write assistant reply to Firestore.
   - On failure, update message status and write fallback assistant message.
3. Replace local-only `_messages` with Firestore-backed state.

Target file:
- `lib/features/customer/booking/presentation/screens/ai_chat_screen.dart`

### Phase 3: Session ID Strategy (Fix Collisions)
Use deterministic, user-safe IDs:
- `ai_{userId}_{contextType}_{contextRefOrDefault}`

Examples:
- `ai_uid123_booking_map_default`
- `ai_uid123_booking_waiting_req_abc123`

Rules:
- Never use a global shared ID like `booking_map_assistant`.
- Include `userId` in every session ID.
- Keep same ID for same user + same context to resume conversation.

Target files:
- `lib/features/customer/booking/presentation/screens/booking_screen.dart`
- `lib/features/customer/booking/presentation/widgets/booking_bottom_panels.dart`

### Phase 4: Firestore Security Rules
Add rules for `ai_chat_sessions`:
- Only authenticated users can access.
- Read/write only when `request.auth.uid == resource.data.userId` (session doc).
- For messages subcollection, enforce parent session ownership.
- Disallow deletes by default unless explicitly needed.

Target file:
- `firestore.rules`

### Phase 5: Verification and Hardening
1. Add unit tests for repository mapping + error handling.
2. Add widget/integration test for send/reload flow.
3. Manual smoke tests on 2 accounts and restart scenarios.

## Verification Checklist
- [ ] User sends message -> appears in Firestore under correct session.
- [ ] Assistant reply is written to Firestore.
- [ ] App restart -> previous conversation loads from Firestore.
- [ ] Different users do not share the same AI session.
- [ ] `updatedAt`, `lastMessagePreview`, `messageCount` update correctly.
- [ ] Security rules block cross-user reads/writes.
- [ ] Offline send failure is visible (`failed`) and recoverable.

## Rollout Order
1. Implement repository + models.
2. Wire `AiChatScreen` with feature flag (optional but recommended).
3. Deploy Firestore rules.
4. Run staging smoke tests.
5. Enable for production users.

## Risks and Mitigations
- Risk: Message duplication when retrying.
  - Mitigation: Use deterministic `requestId` and idempotent writes.
- Risk: Timestamp ordering issues.
  - Mitigation: Store both `createdAt` (server) and `clientCreatedAt`.
- Risk: Rule misconfiguration blocks chat.
  - Mitigation: Add emulator/rules tests before deploy.

## Definition of Done
- AI messages persist in Firestore per user session.
- Session resumes after app restart.
- No cross-user session leakage.
- Firestore rules enforce ownership.
- Basic tests and manual checklist pass.
