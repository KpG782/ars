# Chat Feature — End-to-End Presentation Guide

> **Purpose**: Complete checklist and walkthrough for presenting the real-time chat feature (text + images) on presentation day.

---

## Current State: What Exists vs What is Wired

| Layer | Mechanic Chat | Customer Chat |
|---|---|---|
| UI Screen | ✅ `MechanicChatScreen` | ✅ `ChatScreen` |
| Firebase Firestore | ✅ Connected via `FirebaseChatRepository` | ✅ Connected via `FirebaseChatRepository` |
| Firebase Storage (images) | ✅ `FirebaseChatMediaRepository` uploads real files | ✅ `FirebaseChatMediaRepository` uploads real files |
| Real-time message stream | ✅ `getMessages()` Firestore stream | ✅ `getMessages()` Firestore stream |
| Auth user ID | ✅ `FirebaseAuth.instance.currentUser` | ✅ `FirebaseAuth.instance.currentUser` |
| Image upload progress | ✅ Progress callback wired | ✅ Wired |
| Cross-user messaging | ✅ Shared deterministic chatRoomId | ✅ Shared deterministic chatRoomId |

---

## Critical Bugs — All Fixed ✅

### ✅ Bug 1 — Customer Chat Wired to Firebase

**File**: [lib/features/customer/booking/presentation/screens/chat/chat_screen.dart](../lib/features/customer/booking/presentation/screens/chat/chat_screen.dart)

**Fixed**: `ChatScreen` is now fully wired to `FirebaseChatRepository` and `FirebaseChatMediaRepository`:
- Uses domain `ChatMessage` model from `lib/features/mechanic/chat/domain/models/chat_message.dart`
- `_sendMessage()` writes to Firestore
- `_pickImage()` uploads to Firebase Storage, then stores the download URL
- Real-time `StreamSubscription` updates the message list instantly
- Subscription cancelled in `dispose()` to prevent memory leaks

---

### ✅ Bug 2 — Mechanic ID Uses Real Firebase Auth

**File**: [lib/features/mechanic/chat/presentation/screens/mechanic_chat_screen.dart](../lib/features/mechanic/chat/presentation/screens/mechanic_chat_screen.dart)

**Fixed**: Replaced hardcoded strings with:
```dart
String get _mechanicId => FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
String get _mechanicName => FirebaseAuth.instance.currentUser?.displayName
    ?? FirebaseAuth.instance.currentUser?.email ?? 'Mechanic';
```

---

### ✅ Bug 3 — Deterministic Shared ChatRoom Key

Both the mechanic side and customer side now compute the same deterministic `serviceRequestId`:
- **Customer**: `'${mechanic.id}_${customerId}'`  (auto-computed, no manual arg needed)
- **Mechanic**: `'${_mechanicId}_${customerId}'`  (customerId from `ServiceRequest.customerId`)

The `ServiceRequest` domain model now includes an explicit `customerId` field (defaults to `''` for backward compatibility).

---

### ✅ Bug 4 — Firebase Storage Rules Created

`storage.rules` and `firebase.json` now exist in the project root. Deploy with:
```
firebase deploy --only storage,firestore:rules
```

---

## What Needs to Work End-to-End (Demo Flow)

```
Customer opens app
  └─> Logs in (Firebase Auth)
  └─> Books a service / has an active service request
  └─> Taps "Chat with Mechanic" → ChatScreen opens
      └─> ChatScreen joins the shared chat room (same ID as mechanic)
      └─> Types a message → sent to Firestore chat_rooms/{id}/messages
      └─> Taps attachment → picks image → uploaded to Firebase Storage
      └─> Image URL stored in Firestore message doc

Mechanic opens app (separate device / account)
  └─> Logs in (Firebase Auth)
  └─> Opens job from dashboard → MechanicChatScreen opens
      └─> Sees customer's text message arrive in real time
      └─> Sees customer's image rendered from Firebase Storage URL
      └─> Replies → customer sees it instantly via Firestore stream
```

---

## Complete Pre-Presentation Checklist

### Firebase Console
- [ ] Firestore **`chat_rooms`** collection exists (or will be auto-created)
- [ ] Firestore indexes exist for `messages` subcollection ordered by `timestamp` ascending
- [ ] Firebase Storage bucket exists and access rules allow authenticated writes to `chat_media/**`
- [ ] Both test accounts (customer + mechanic) are created in **Firebase Auth**

### Firestore Security Rules
- [ ] Rule `chat_rooms/{roomId}` allows read/write for participants ✅ (already in `firestore.rules`)
- [ ] Rule `chat_rooms/{roomId}/messages/{messageId}` allows create/read by participants ✅
- [ ] Rules are **deployed** — run `firebase deploy --only firestore:rules`

### Storage Security Rules
- [x] Storage rules file exists (`storage.rules`) ✅
- [x] Authenticated users can write to `chat_media/{chatRoomId}/**` ✅
- [ ] Rules are deployed — run `firebase deploy --only storage`

### Code Fixes
- [x] **Customer** `ChatScreen` connected to `FirebaseChatRepository` ✅
- [x] **Customer** `ChatScreen` uploads images via `FirebaseChatMediaRepository` ✅
- [x] **Mechanic** `MechanicChatScreen` reads real UID from `FirebaseAuth.instance.currentUser` ✅
- [x] **Mechanic** `MechanicChatScreen` reads real display name from current user ✅
- [x] `ServiceRequest` model has explicit `customerId` field ✅
- [x] Both screens compute the same `chatRoomId` via deterministic `mechanicId_customerId` key ✅

### Packages
- [x] `firebase_storage: ^13.0.1` ✅ (already in pubspec.yaml)
- [x] `cloud_firestore: ^6.0.1` ✅
- [x] `firebase_auth: ^6.0.2` ✅
- [x] `image_picker: ^1.0.4` ✅
- [x] Android: `READ_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES`, `CAMERA` permissions added to `AndroidManifest.xml` ✅
- [x] iOS: `NSPhotoLibraryUsageDescription`, `NSCameraUsageDescription`, `NSMicrophoneUsageDescription` added to `Info.plist` ✅

### Device Permissions (Runtime)
- [ ] Camera permission granted on test device(s)
- [ ] Photo library / gallery permission granted on test device(s)
- [ ] Internet permission confirmed (usually auto-granted on Android)

### Build & Run
- [ ] `flutter pub get` — no dependency errors
- [ ] `flutter build apk --release` builds without errors
- [ ] App installs and runs on demo device
- [ ] No "Firebase not initialized" crash at startup

---

## Architecture Overview

```
lib/features/mechanic/chat/
├── domain/
│   ├── models/
│   │   ├── chat_message.dart       # ChatMessage entity, MessageType enum
│   │   └── chat_room.dart          # ChatRoom entity
│   └── repositories/
│       └── chat_repository.dart    # Abstract interfaces (ChatRepository, ChatMediaRepository)
├── data/
│   └── repositories/
│       ├── firebase_chat_repository.dart       # Firestore: send/receive messages, manage rooms
│       └── firebase_chat_media_repository.dart # Firebase Storage: upload images/documents
└── presentation/
    ├── screens/
    │   └── mechanic_chat_screen.dart           # Mechanic-side chat UI
    └── widgets/
        ├── chat_bubble.dart        # Renders text + image messages
        ├── chat_input_field.dart   # Text field + attachment toggle + send button
        ├── attachment_menu.dart    # Gallery / Camera / Video options
        ├── attachment_option.dart  # Single option tile in attachment menu
        └── call_dialog.dart        # Voice/Video call modal

lib/features/customer/booking/presentation/screens/chat/
└── chat_screen.dart                # Customer-side chat UI (needs Firebase wiring)
```

---

## Firestore Data Structure

```
chat_rooms/                          ← Collection
  {chatRoomId}/                      ← Document (ID = serviceRequestId)
    id: string
    serviceRequestId: string
    mechanicId: string
    mechanicName: string
    customerId: string
    customerName: string
    participants: [mechanicId, customerId]   ← Used by security rules
    lastMessage: { ... }
    createdAt: timestamp
    updatedAt: timestamp
    
    messages/                        ← Subcollection
      {messageId}/                   ← Document (UUID)
        id: string
        chatRoomId: string
        senderId: string
        senderName: string
        content: string              ← Text body or image caption
        type: "text" | "image" | "document" | "location"
        isFromMechanic: bool
        timestamp: timestamp
        status: "sending" | "sent" | "delivered" | "read"
        mediaUrl: string?            ← Firebase Storage download URL (for images)
        thumbnailUrl: string?
```

---

## Firebase Storage Path Structure

```
chat_media/
  {chatRoomId}/
    images/
      {uuid}.jpg                     ← Uploaded images (max 10 MB)
    documents/
      {uuid}.pdf                     ← Uploaded documents (max 20 MB)
```

---

## Image Send Flow (Step by Step)

1. User taps **+** attachment button in `ChatInputField`
2. `AttachmentMenu` appears with Gallery / Camera / Video
3. `image_picker` opens device gallery or camera
4. `_pickImage()` calls `FirebaseChatMediaRepository.uploadImage()`
   - Validates file exists and is ≤ 10 MB
   - Validates extension is `.jpg`, `.jpeg`, `.png`, `.gif`, or `.webp`
   - Uploads to `chat_media/{chatRoomId}/images/{uuid}.ext`
   - Returns `MediaUploadResult` containing the public `url`
5. `_chatRepository.sendMediaMessage()` creates a Firestore document with `type: "image"` and `mediaUrl: url`
6. The real-time Firestore stream picks up the new document
7. `ChatBubble` renders it as `Image.network(message.mediaUrl!)`
8. Other participant's screen updates via their own live stream listener

---

## Text Send Flow (Step by Step)

1. User types in `ChatInputField` text field
2. Taps send button (or presses Enter)
3. `_sendMessage()` calls `FirebaseChatRepository.sendMessage()`
4. A new document is written to `chat_rooms/{chatRoomId}/messages/{uuid}`
5. The `updatedAt` and `lastMessage` fields on the chat room doc are updated
6. The Firestore stream `getMessages(chatRoomId)` emits the updated list
7. `setState()` rebuilds both participants' `ListView` with the new message
8. `_scrollToBottom()` animates to the latest message

---

## Quick Smoke Test (Before Presentation)

| Test | Expected Result |
|---|---|
| Open chat from mechanic dashboard | Chat room initializes, messages load |
| Type text and send | Message appears in teal bubble on mechanic side |
| Open same chat on customer device | Customer sees the mechanic's message in real time |
| Customer replies with text | Mechanic sees it arrive without refresh |
| Tap Gallery, pick a photo | "Uploading image..." toast → image appears in chat bubble |
| Other device sees the image | Image loads from Firebase Storage URL |
| Kill app, reopen chat | Message history is preserved from Firestore |
| Send from offline → go online | Message sends once connection restored |

---

## Known Limitations (For Presentation Awareness)

- **No push notifications** when app is backgrounded (Firebase Messaging integration is separate)
- **No read receipts** — `status` field exists in model but UI does not render tick marks
- **No typing indicator** — no presence/typing doc in Firestore
- **Video send not wired** — "Video" option appears in attachment menu but has no handler
- **No message deletion** — Firestore `delete` is blocked by security rules by design
- **Customer chat currently offline** — ~~must be fixed before demo~~ **FIXED** ✅
