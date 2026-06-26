# Talyer — Long-Term Scalability

> How Talyer stays correct, fast, and cheap from one barangay to nationwide. The
> theme: **server-authoritative writes, denormalised reads, and cost discipline
> on the two things that explode — live GPS and fan-out.**

## 1. Firestore data model

Modelled for the queries we actually run (nearby-available-mechanics; my active
booking; my history; a mechanic's offers/earnings), denormalising to keep reads
to a single document/query.

```
users/{uid}                      role, displayName, phone, photoUrl, createdAt
  (custom claims mirror role + verified for security rules & guards)

mechanics/{uid}                  profile, specializations[], serviceArea,
                                 verification{status, tesdaNcII, license, govId},
                                 availability: offline|available|busy,
                                 geohash, geopoint,            ← geoflutterfire_plus
                                 ratingAvg, ratingCount         ← aggregated, never client-written
  /documents/{docId}             storage refs (license, NC II, gov-ID)

bookings/{bookingId}             customerId, mechanicId?, status, serviceType,
                                 pickup{geopoint, address}, vehicleId,
                                 quote{labor, parts[], platformFee, total, approvedAt},
                                 price{estimated, final}, createdAt, timeline[]
  /messages/{msgId}              chat (sender, text, imageRef, reported?)
  /offers/{mechanicId}           dispatch offer ladder (offeredAt, expiresAt, state)

ledger/{entryId}                 APPEND-ONLY: bookingId, mechanicId, gross, fee,
                                 tip, net, createdAt   ← written ONLY by Functions
payouts/{payoutId}               mechanicId, amount, method, status

vehicles/{vehicleId}             ownerId, make, model, plate, lastServiceAt
ratings/{bookingId}              by, of, stars, text, createdAt → trigger aggregates to mechanics/*
referrals/{code}                 ownerId, kind, redemptions[]
```

**Rules**
- **Denormalise for the read.** Store `ratingAvg`/`ratingCount` on the mechanic
  doc so the find-a-mechanic list is one query, not N. A trigger keeps them
  fresh from `ratings/*`.
- **Append-only ledger.** Earnings are summed from immutable entries written by
  Functions — never re-derived by re-querying completed jobs (the ARS bug),
  never client-writable.
- **Security rules are the perimeter.** Clients can read their own data and
  create a booking; they **cannot** write `status`, `quote.approvedAt`,
  `ratingAvg`, or any `ledger` entry — those are Function-only. Verification and
  payout state likewise server-only.

## 2. Nearby-mechanic queries (geo)

Use `geoflutterfire_plus` geohashing (already a dep in ARS): query
`mechanics` where `availability == available` within radius via geohash range.
Index `(availability, geohash)`. Cap results, paginate, and **never** load all
mechanics client-side. Pre-compute a city/`serviceArea` filter to shrink the
candidate set before geo.

## 3. Dispatch at scale

- **Trigger:** `onCreate(bookings/{id})` Cloud Function builds a **nearest-first
  offer ladder** (filtered by specialization + availability), writes
  `offers/{mechanicId}` with a short `expiresAt`, and FCM-pushes that mechanic.
- **Accept = transaction** guarded on `booking.status == pending` → only the
  first writer wins; others get "offer taken." Fixes the double-accept race.
- **TTL sweep:** a scheduled Function expires stale offers → advances the ladder
  → on exhaustion flips `status = unmatched` so the customer sees the designed
  *no-mechanic-available* fallback (the most-hit launch state).
- **Pin privacy:** the precise pickup geopoint is revealed only **after** accept;
  pre-accept offers carry coarse distance only.

## 4. Live location — the cost trap

High-frequency GPS writes to Firestore are the #1 way this bill explodes
(one en-route job = hundreds of writes). Strategy:
- Stream the mechanic's live position over **Realtime Database** (or an ephemeral
  `presence` channel), **not** `bookings/*`; Firestore stores only milestone
  updates (accepted / arrived / started / done).
- **Throttle** client GPS to ~1 update / 3–5 s and only while a job is
  `enRoute|inProgress`; stop on background per platform rules.
- ETA via OSRM in `core/services` (server-proxied so the routing key isn't in
  the app).

## 5. Read/write cost discipline

| Lever | Practice |
|---|---|
| Reads | denormalised list cards; paginate (`limit` + cursor); enable offline persistence |
| Writes | batch related writes; milestones not high-frequency; debounce form autosave |
| Fan-out | FCM topics/condition sends, not per-doc loops |
| Aggregation | counters/rollups via triggers (ratings, earnings), not on-read scans |
| Hot docs | avoid a single counter doc under load — shard counters if needed |

## 6. Observability & performance budgets

- **Crashlytics** (crash-free > 99.5%), **Analytics** funnels (request → match →
  pay), **Performance Monitoring** (cold start < 2.5 s; find-a-mechanic < 1 s).
- Structured logs in Functions (never PII); alert on dispatch-match-rate drop
  and payment-webhook failures.

## 7. Growth-stage levers (when volume demands)

- Firestore scales automatically, but watch **index fan-out** and **hot
  geohash cells** in dense cities → finer geohash precision + city sharding.
- Move read-heavy aggregates (leaderboards, city supply heatmaps) to scheduled
  rollups or BigQuery export.
- Pick the **asia-southeast1** region; add CDN for static/marketing.
- Extract `design`/`core`/`feature/*` into melos packages so build + test stay
  fast as the team grows.

## 8. Quality gates that protect scale
Domain unit tests (fakes) · design-system golden tests · critical-flow
integration tests · Firestore **rules unit tests** (emulator) for every
server-only field · `flutter analyze`/`test` + rules tests in CI on every PR.
