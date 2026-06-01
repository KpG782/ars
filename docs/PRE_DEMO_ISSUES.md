# ARS Application — Pre-Demo Issues & Hardcoded Values
> Generated: March 3, 2026 | Severity: 🔴 BREAKS DEMO · 🟠 VISIBLE BUG · 🟡 SILENT RISK · ⚪ COSMETIC

---

## Summary Table

| # | Feature Group | Issue | Severity |
|---|---------------|-------|----------|
| 1 | Mechanic Earnings | Hardcoded `'MECHANIC_ID'` string — loads no real data | 🔴 |
| 2 | Mechanic Service History | Hardcoded `'MECHANIC_ID'` string — loads no real data | 🔴 |
| 3 | Customer Booking — Shop Search | `MockShopRepository` in use — shows fake shops, not Firestore | 🔴 |
| 4 | Mechanic Profile Settings | Mock data fills phone, vehicle, experience fields | 🟠 |
| 5 | Customer Chat Screen | Falls back to `'guest_customer'` if user is not logged in | 🟠 |
| 6 | Customer AI Chat (bottom panel) | Session ID built as `'booking_$uid'` — fine, but null if logged out | 🟡 |
| 7 | Customer AI Chat (booking screen) | Hardcoded session ID `'booking_map_assistant'` | 🟡 |
| 8 | Customer AI Chat Screen | Falls back to `'anonymous'` if user is null | 🟡 |
| 9 | Mechanic Chat Screen | Falls back to `'unknown'` if mechanic not logged in | 🟠 |
| 10 | Notification Service | Navigation on tap is not implemented (TODO) | 🟡 |
| 11 | Customer Booking — Call Button | "Call mechanic" button does nothing (TODO) | 🟠 |
| 12 | Customer Booking — Location Search | Location search bar is not implemented (TODO) | 🟡 |
| 13 | Customer Booking — Map Location Select | Map-based location pick not implemented (TODO) | 🟡 |
| 14 | Customer Booking Status Panels | "Change location", "Call", "Message", "Track mechanic" all TODO | 🟠 |
| 15 | Customer Payment Success | Download receipt button not implemented (TODO) | ⚪ |
| 16 | Mechanic Dashboard | Request search bar not implemented (TODO) | ⚪ |
| 17 | Mechanic Dashboard Bottom Panel | "Call customer" button is TODO | 🟠 |
| 18 | Mechanic Profile Settings — Save | Save button writes nothing to Firebase (TODO) | 🔴 |
| 19 | Mechanic Profile Settings — Delete | Account deletion not implemented (TODO) | ⚪ |
| 20 | Customer Profile Repo | Phone auth flow is a placeholder comment | 🟡 |
| 21 | Completion Summary Screen | Customer rating widget is a placeholder | 🟠 |
| 22 | `print()` / `debugPrint()` — production logs | 40+ raw print statements in release code | 🟡 |
| 23 | `mechanic_enums.dart` | Stale TODO to remove file after updating imports | ⚪ |

---

## Group 1 — Mechanic Feature (🔴🔴 Fix First)

### 1.1 Earnings Screen — Hardcoded `'MECHANIC_ID'` 🔴
**File:** `lib/features/mechanic/earnings/presentation/screens/earnings_screen.dart`

- **Lines 38 & 419** — `final mechanicId = 'MECHANIC_ID'; // TODO: Get from auth`
- Both `getEarningsSummary()` and the withdrawal request use this string as the Firestore document key.
- **Result:** The earnings screen queries the wrong document — it either returns empty data or throws a Firestore permission error every time any mechanic opens it.

**Fix:**
```dart
// Replace both occurrences with:
final mechanicId = FirebaseAuth.instance.currentUser?.uid ?? '';
if (mechanicId.isEmpty) return; // guard
```

---

### 1.2 Service History Screen — Hardcoded `'MECHANIC_ID'` 🔴
**File:** `lib/features/mechanic/services/presentation/screens/service_history_screen.dart`

- **Line 30** — `const mechanicId = 'MECHANIC_ID'; // TODO: Get from auth`
- Used to query the mechanic's completed service history from Firestore.
- **Result:** No service history ever loads — query returns 0 results for every mechanic.

**Fix:**
```dart
final mechanicId = FirebaseAuth.instance.currentUser?.uid ?? '';
```

---

### 1.3 Mechanic Profile Settings — Mock Initial Data 🟠
**File:** `lib/features/mechanic/dashboard/presentation/screens/profile_settings_screen.dart`

- **Lines 37–44** — `_loadUserData()` fills all text fields with hardcoded values:
  - Phone: `'+639171234567'`
  - Vehicle type: `'Motorcycle'`
  - Experience: `'5 years'`
- **Line 422** — Save button has a TODO comment; no Firestore write happens.
- **Result:** Opening the profile settings always shows fake data. Saving does nothing.

**Fix (load):** Replace static values with a Firestore `.get()` on the mechanic's document.
**Fix (save):** Implement the `// TODO: Save to Firebase Firestore` block.

---

### 1.4 Mechanic Chat Screen — `'unknown'` fallback identity 🟠
**File:** `lib/features/mechanic/chat/presentation/screens/mechanic_chat_screen.dart`

- **Line 37** — `String get _mechanicId => FirebaseAuth.instance.currentUser?.uid ?? 'unknown';`
- If called while not authenticated, messages are sent under `'unknown'` as the sender UID.
- **Fix:** Add a pre-check and redirect to login if `currentUser` is null.

---

### 1.5 Mechanic Dashboard Bottom Panel — "Call Customer" TODO 🟠
**File:** `lib/features/mechanic/dashboard/presentation/widgets/mechanic_bottom_panels.dart`

- **Line 379** — `// TODO: Call customer`
- The call button is rendered but does nothing when pressed.

---

## Group 2 — Customer Booking Feature (🔴🟠)

### 2.1 Shop Search Uses `MockShopRepository` 🔴
**Files:**
- `lib/features/customer/booking/presentation/screens/booking.dart` **line 78**
- `lib/features/customer/booking/data/repositories/mock_shop_repository.dart`

- `_shopRepository = MockShopRepository();` is directly instantiated on screen init.
- `MockShopRepository.getShopsNearLocation()` generates fake random shops with hardcoded names, ratings, and coordinates offset from the user's position.
- **Result:** The map always shows fake mechanics, never real registered mechanics from Firestore.

**Fix:** Swap to `FirestoreShopRepository()` which already exists:
```dart
// booking.dart line 78 — replace:
_shopRepository = MockShopRepository();
// with:
_shopRepository = FirestoreShopRepository();
```

---

### 2.2 Customer Chat Screen — `'guest_customer'` fallback 🟠
**File:** `lib/features/customer/booking/presentation/screens/chat/chat_screen.dart`

- **Line 46** — `FirebaseAuth.instance.currentUser?.uid ?? 'guest_customer'`
- If a customer somehow reaches ChatScreen while not logged in, messages are attributed to `'guest_customer'`.
- Firestore chat room rules check `participants` array by UID — `'guest_customer'` will be **rejected by Firestore rules**, breaking the chat completely.

**Fix:** Guard the screen with an auth check before opening.

---

### 2.3 Booking Bottom Panel — `'guest'` fallback for AI Chat 🟡
**File:** `lib/features/customer/booking/presentation/widgets/booking_bottom_panels.dart`

- **Line 617** — `FirebaseAuth.instance.currentUser?.uid ?? 'guest'`
- Used to build the AI chat session ID: `'booking_$uid'`.
- If user is logged out, the session ID becomes `'booking_guest'` — all conversations are shared under one key.

---

### 2.4 Booking Screen — Hardcoded AI Session ID 🟡
**File:** `lib/features/customer/booking/presentation/screens/booking_screen.dart`

- **Line 346** — `sessionId: 'booking_map_assistant'`
- This is a static session ID. All users share the same AI conversation history via this key.
- Should be `'booking_map_assistant_${FirebaseAuth.instance.currentUser?.uid}'`.

---

### 2.5 AI Chat Screen — `'anonymous'` fallback user ID 🟡
**File:** `lib/features/customer/booking/presentation/screens/ai_chat_screen.dart`

- **Line 51** — `FirebaseAuth.instance.currentUser?.uid ?? 'anonymous'`
- Used as the user identifier when calling the AI API / saving conversation to Firestore.
- If unauthenticated, conversations are attributed to `'anonymous'`.

---

### 2.6 Booking Screen — Call Mechanic Button is Dead 🟠
**File:** `lib/features/customer/booking/presentation/screens/booking.dart`

- **Line 757** — `// TODO: Implement call functionality`
- A displayed "call" button does nothing on press.

---

### 2.7 Booking Status Panels — Multiple Dead Buttons 🟠
**File:** `lib/features/customer/booking/presentation/widgets/booking_status_panels.dart`

| Line | Issue |
|------|-------|
| 92 | `// TODO: Implement location change` |
| 394 | `// TODO: Implement call functionality` |
| 403 | `// TODO: Implement message functionality` |
| 424 | `// TODO: Implement track mechanic` |

All four buttons are visible but non-functional during the confirmed booking state.

---

### 2.8 Location Selection Screen — Not Implemented 🟡
**File:** `lib/features/customer/booking/presentation/screens/location_selection_screen.dart`

- **Line 117** — `// TODO: Implement logic to use current location`
- **Line 231** — `// TODO: Implement map selection logic`
- "Use current location" and "Pick on map" do nothing.

---

### 2.9 Payment Success — Receipt Download TODO ⚪
**File:** `lib/features/customer/booking/presentation/screens/payment/payment_success_screen.dart`

- **Line 313** — `// TODO: Implement receipt/invoice download`

---

## Group 3 — Customer Dashboard / Profile

### 3.1 Firebase Profile Repository — Phone Auth Placeholder 🟡
**File:** `lib/features/customer/dashboard/data/repositories/firebase_profile_repository.dart`

- **Line 63** — `// For now, this is a placeholder - you may need to implement phone auth flow`
- Phone number update flow is not connected to Firebase Auth phone re-auth.

---

## Group 4 — Mechanic Completion / Rating

### 4.1 Completion Summary Screen — Customer Rating is Placeholder 🟠
**File:** `lib/features/mechanic/dashboard/presentation/screens/completion_summary_screen.dart`

- **Line 290** — `// Customer Rating (placeholder)`
- The ratings widget renders but doesn't write submitted ratings to Firestore.

---

## Group 5 — Notifications

### 5.1 Push Notification Deep-Linking Not Implemented 🟡
**File:** `lib/core/services/notification_service.dart`

- **Line 117** — `// TODO: Navigate to appropriate screen based on payload`
- **Line 155** — `// TODO: Navigate based on message data`
- Tapping a push notification opens the app but navigates nowhere. For a demo this means testers won't be directed to the right screen after a notification.

---

## Group 6 — Mechanic Dashboard

### 6.1 Request Search Bar Not Implemented ⚪
**File:** `lib/features/mechanic/dashboard/presentation/screens/mechanic_dashboard.dart`

- **Line 1091** — `// TODO: Implement request search`

---

## Group 7 — Code Quality / Runtime Noise

### 7.1 40+ `print()` Statements in Release Code 🟡
Raw `print()` and `debugPrint()` calls in production-facing code:

| File | # of calls |
|------|-----------|
| `lib/core/services/notification_service.dart` | ~14 |
| `lib/features/customer/booking/presentation/screens/booking.dart` | ~18 |
| `lib/core/services/osrm_service.dart` | ~6 |
| `lib/features/mechanic/dashboard/presentation/screens/mechanic_dashboard.dart` | ~4 |
| Others (eta_display, location_sharing) | ~5 |

These don't crash the app but spam the console and can expose sensitive info (FCM token at line 41 of notification_service).

---

### 7.2 `mechanic_enums.dart` Stale TODO ⚪
**File:** `lib/features/mechanic/dashboard/presentation/widgets/mechanic_enums.dart`

- **Line 7** — `// TODO: Remove after updating all imports`

---

## Recommended Fix Order for Tomorrow's Demo

```
Priority 1 (will crash or show empty screens):
  ✅ Fix: earnings_screen.dart         — replace 'MECHANIC_ID' with real UID
  ✅ Fix: service_history_screen.dart  — replace 'MECHANIC_ID' with real UID
  ✅ Fix: booking.dart                 — swap MockShopRepository → FirestoreShopRepository
  ✅ Fix: profile_settings_screen.dart — load/save profile from Firestore

Priority 2 (visible to judges/audience):
  ✅ Fix: booking_status_panels.dart   — guard or hide unimplemented buttons
  ✅ Fix: booking.dart line 757        — guard or hide the call button
  ✅ Fix: mechanic_bottom_panels.dart  — guard or hide the call customer button
  ✅ Fix: completion_summary_screen    — wire up rating submission

Priority 3 (edge cases / logged-out paths):
  ✅ Fix: chat_screen.dart             — auth guard before opening chat
  ✅ Fix: booking_screen.dart:346      — per-user AI session ID
  ✅ Fix: ai_chat_screen.dart:51       — auth guard / no anonymous sessions
```

---

*This file was auto-generated by codebase scan. All line numbers reference the state of the repo as of 2026-03-03.*
