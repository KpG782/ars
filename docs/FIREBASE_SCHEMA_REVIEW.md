# Firebase / Firestore Schema Review

_Validation of `firestore.rules` + `firestore.indexes.json` against the queries the app actually runs._
_Last reviewed: 2026-06-02. Backend config is still placeholder (see `CLAUDE.md`), so nothing below is deployed yet._

## Collections in use (verified against real, non-example code)

| Collection | Written/Read by | Access model (rules) |
|---|---|---|
| `users/{userId}` | auth/profile | owner-only read+write |
| `mechanics/{mechanicId}` | search, dashboard | any authed read; owner create/update; no delete |
| `service_requests/{requestId}` | booking, dashboard | create by any authed; read/update by customer **or** mechanic on the doc; no delete |
| `chat_rooms/{roomId}` (+ `/messages`) | `firebase_chat_repository.dart` (const `_chatRoomsCollection = 'chat_rooms'`) | participants-only get/update; any authed `list`; messages restricted to room participants |
| `notifications/{notifId}` | notifications | recipient-only |
| `shops/{shopId}` | shop browse | any authed read; no client write (admin-only) |
| `withdrawal_requests/{id}` | `firebase_earnings_repository.dart` | **was missing — added this pass** (see below) |

### Not bugs (verified)
The strings `serviceRequests` (camelCase), `chats`, `completedServices`, and a top-level `messages`
appear **only in commented-out illustrative code** under `lib/examples/*_notification_integration.dart`.
They are not live queries, so they are not collection-name mismatches. The live chat path correctly
uses `chat_rooms` + the `messages` subcollection, matching the rules.

## Gap found and fixed: `withdrawal_requests`

The mechanic earnings feature (`lib/features/mechanic/earnings/data/repositories/firebase_earnings_repository.dart`)
reads/writes `withdrawal_requests`, but the collection had **no security rule** (default-denied → the whole
withdrawal flow would fail under real rules) and **no composite indexes** for its queries.

**Observed operations**
- create: `{ mechanicId, amount, paymentMethod, accountDetails, requestDate, status: 'pending' }`
- `getWithdrawalHistory`: `where(mechanicId ==) . orderBy(requestDate desc)`
- `getPendingWithdrawals`: `where(mechanicId ==) . where(status == 'pending') . orderBy(requestDate desc)`
- `cancelWithdrawal`: `update({ status: 'cancelled', cancelledAt })`

**Rule added** (owner-scoped; clients can create a pending request and cancel it; approve/pay is
server-side via the Admin SDK, which bypasses rules — so a mechanic cannot mark their own request paid):

```
match /withdrawal_requests/{withdrawalId} {
  allow read:   if auth.uid == resource.data.mechanicId;
  allow create: if auth.uid == request.resource.data.mechanicId
                   && request.resource.data.status == 'pending';
  allow update: if auth.uid == resource.data.mechanicId
                   && resource.data.status == 'pending'
                   && request.resource.data.status == 'cancelled';
  allow delete: if false;
}
```

**Indexes added** to `firestore.indexes.json`:
- `withdrawal_requests`: `mechanicId ASC, requestDate DESC`
- `withdrawal_requests`: `mechanicId ASC, status ASC, requestDate DESC`

## Index inventory (after this pass — 7 total)

| Collection | Fields | Serves |
|---|---|---|
| `mechanics` | `verification.status ASC, isOnline ASC` | verified + online filter |
| `mechanics` | `isOnline ASC, isVerified ASC, geohash ASC` | nearby online verified (geohash) |
| `service_requests` | `customerId ASC, createdAt DESC` | customer's request history |
| `service_requests` | `mechanicId ASC, createdAt DESC` | mechanic's request history |
| `service_requests` | `status ASC, createdAt DESC` | open-request feed |
| `withdrawal_requests` | `mechanicId ASC, requestDate DESC` | withdrawal history (added) |
| `withdrawal_requests` | `mechanicId ASC, status ASC, requestDate DESC` | pending withdrawals (added) |

## Remaining actions (require real Firebase project)
1. Provide real `google-services.json` / `GoogleService-Info.plist` + regenerate `firebase_options.dart`.
2. `firebase deploy --only firestore:rules,firestore:indexes`.
3. Treat the Firebase console's runtime "missing index" errors as the source of truth — exercise each
   screen against a live project and add any index it asks for. This review covers the queries visible in
   the current code; runtime confirms completeness.
