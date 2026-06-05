# ARS — End-to-End Engineering & SRE Audit

_Audit date: 2026-06-05 · Scope: **read-only** (no source modified, no migrations run, no deploys). Auditor stance: cold-eyed staff-engineer + SRE._

> **Toolchain note:** the Flutter/Dart SDK is **not installed in this audit container** (`which flutter dart` → empty), so `flutter analyze`, `flutter test`, and `flutter build` could **not** be re-run here. Every finding below comes from reading the actual source/config. Where a verdict needs a live build/run, it is marked **❓ Could Not Verify** and listed in §6.

---

## ⚠️ Stack reality check (read this first)

The audit brief described the stack as _"Next.js 15, Supabase, PostgreSQL + pgvector + PostGIS, Redis, n8n, Claude API, FastAPI, Docker, EasyPanel."_ **That is largely fictional for this repository.** Verified against the actual files:

| Claimed | Reality in this repo | Evidence |
|---|---|---|
| Next.js 15 | ❌ **Flutter / Dart** mobile app (163 `.dart` files, Android-first) | `pubspec.yaml`, `lib/main.dart` |
| Supabase | ❌ **Firebase** (Auth, Firestore, Storage, Messaging, Crashlytics) | `pubspec.yaml:20-25`, `firebase.json` |
| PostgreSQL + pgvector + PostGIS | ❌ **Cloud Firestore** (NoSQL). Vectors/RAG live in an **off-repo** companion service (ChromaDB), not Postgres | `firestore.rules`, `README.md:67` |
| Redis | ⚠️ Real, but **in the off-repo companion API only** (not in this codebase) | `README.md:67` |
| n8n | ❌ **No evidence anywhere** in the repo | — |
| Claude API | ❌ The AI is **Google Gemini 2.0 Flash**, not Claude | `README.md:16,67` |
| FastAPI | ⚠️ Real, but the **off-repo "ARS Rapide" chatbot service** | `README.md:67`, `.env.example:5` |
| Docker | ❓ Implied by EasyPanel hosting; **no Dockerfile in this repo** | — |
| EasyPanel VPS | ✅ Real — hosts **two** services: the chatbot and a self-hosted OSRM router | `.env.example:5`, `lib/core/services/osrm_service.dart:11-12` |

**Consequence for this audit:** this repo is the **Flutter client only**. The FastAPI + Gemini + LangGraph + ChromaDB/RAG + Redis backend is a separate, unreachable codebase. Everything about the backend's prompt hygiene, model pinning, RAG quality, rate-limits, RLS-equivalent, and Redis policy is **❓ Could Not Verify** (§6). The 14 dimensions below are answered for the part that actually lives here, with the AI/data probes translated to their Firebase/Gemini equivalents.

---

## 1. Executive Summary

- **It's a polished client wrapped around a half-absent server.** The Flutter UI, theming, OSRM routing fallback, and chatbot failover are genuinely well-built. But the privileged half of the system (earnings crediting, withdrawal approval, mechanic verification, targeted notifications) is described in the rules as _"server-side only (Admin SDK)"_ — and **that server is not in this repo** (`functions/` does not exist). Several features are therefore non-functional or insecure by construction.
- **🔥 Fix-this-first:** a **fresh clone does not build.** `lib/main.dart:13` imports `firebase_options.dart` (gitignored, absent) and `pubspec.yaml:112` declares `.env` as a **required asset** (also gitignored, absent). Until both are created, `flutter run`/`build` fails before the app even starts.
- **Money model is broken _and_ exploitable.** `netEarnings` is defined as gross (`= mechanicEarnings`, `firebase_earnings_repository.dart:77`) — withdrawals are **never subtracted** (no ledger), so a balance never goes down. And because `firestore.rules:24-27` lets _either party_ rewrite a service request's price/tip/status fields, a mechanic can inflate their own pay. Both are latent today only because Firebase is placeholder.
- **Authorization is thin.** The router guard (`app_router.dart:46-64`) checks _logged-in_, never _role_ — a customer can open `/mechanic/dashboard`. And ~44 screens navigate via imperative `Navigator.push`, **bypassing the go_router guard entirely** (only ~13 routes are guarded). Mechanics can **self-grant verification** (`firestore.rules:13` + writable `verification` field), so the "verified mechanic" trust badge is meaningless.
- **No CI, no pipeline, no observability beyond Crashlytics.** `.github/workflows` does not exist; there is no automated build/test/deploy and no metrics/traces/alerting. Crashlytics _is_ wired (`main.dart:32`) — the one bright spot.
- **The repo's own docs lie to you.** `CLAUDE.md` and `docs/AUDIT.md` claim "the only test is the broken counter test" and "deprecated `withOpacity` everywhere" — both **false now**: there are **6 real tests** and **0** `withOpacity`/`print` calls. Trust the code, not the markdown.
- **Net health: a strong portfolio/demo front-end with production-grade fragility underneath.** Safe to show; **not** safe to wire to real money or real users without closing the P0/P1 items in §5.

---

## 2. Health Scorecard

| # | Dimension | Status | One-line verdict |
|---|---|---|---|
| 1 | Architecture & coupling | ⚠️ Risk | Clean-arch layering is real (even test-enforced), but a hybrid Navigator/go_router + StatefulWidget/Riverpod split and 3 rival `ServiceRequest` models create drift. |
| 2 | Data layer (schema/indexes/geo) | ❌ Broken | Two incompatible field schemas on one `service_requests` collection; geohash index defined but **unused**; geo done by client-side Haversine on a global 100-doc window. |
| 3 | API contracts & auth-on-every-route | ❌ Broken | Route guard is auth-only (no role); most screens bypass it via `Navigator`; Firestore `update` rules have no field validation. |
| 4 | Resilience (retries/idempotency/timeouts) | ⚠️ Risk | Good timeouts + graceful fallbacks, but **zero retries/backoff**, no idempotency on request creation, sequential batch ETA. |
| 5 | Security | ❌ Broken | Self-grantable mechanic verification; all-authed read of mechanic phone+precise location; chat-room metadata enumerable; API key shipped in client; cleartext traffic on. |
| 6 | Failure modes | ⚠️ Risk | Firebase failure is swallowed → "looks alive, silently does nothing"; targeted notifications need an absent Admin server. |
| 7 | Performance | ⚠️ Risk | Unbounded reads (all-time earnings, global pending feed), per-mechanic realtime listener fan-out, sequential HTTP. |
| 8 | Cost | ⚠️ Risk | Firestore read amplification is the cost curve; LLM token cost is off-repo/uncapped from the client; OSRM self-host = $0 routing (good). |
| 9 | AI prompt/model hygiene | ❓/⚠️ | Model = Gemini 2.0 Flash (off-repo). Client side: 45s timeout, no retry, no output-schema validation, key shipped to client. |
| 10 | Eval & safety | ❓ Unknown | "87.4% accuracy" claims have **no eval harness in repo**; PII (uid) sent to backend unscrubbed; no client guardrails beyond link handling. |
| 11 | Observability | ⚠️ Risk | Crashlytics ✅; structured `logger` ✅; but no metrics/traces/alerts/analytics — half-blind. |
| 12 | CI/CD & deploy | ❌ Missing | No `.github`, no pipeline, no env separation, **clone not reproducible** (missing `.env` + `firebase_options.dart`). |
| 13 | Testing | ⚠️ Risk | 6 real tests (design tokens, arch-layering, earnings logic, theme smoke) — better than docs claim, but no booking/auth/chat/rules coverage. |
| 14 | Docs & onboarding | ⚠️ Risk | 40+ docs, but meaningful drift; README mostly honest but overclaims AI metrics; unbuildable clone hurts day-one onboarding. |

---

## 3. System Map

```
                         ┌─────────────────────────────────────────────┐
                         │           ARS Flutter app (THIS REPO)        │
                         │   customer/* + mechanic/* + onboarding/*     │
                         │   StatefulWidget(45) + Riverpod(4) hybrid    │
                         │   Navigator.push(44) + go_router(13) hybrid  │
                         └───────┬───────────────┬───────────────┬──────┘
                                 │               │               │
            (Firebase SDKs)      │               │ HTTP          │ HTTP
                                 ▼               ▼               ▼
   ┌───────────────────────────────────┐  ┌──────────────┐  ┌────────────────────────┐
   │  Firebase project (PLACEHOLDER)    │  │ OSRM router  │  │ "ARS Rapide" chatbot    │
   │  • Auth (email/pwd)                │  │ EasyPanel    │  │ EasyPanel (OFF-REPO)    │
   │  • Firestore: users, mechanics,    │  │ /route/v1/.. │  │ FastAPI + Gemini 2.0    │
   │    service_requests, chat_rooms,   │  │ 10/15/5s TO  │  │ LangGraph + ChromaDB    │
   │    notifications, withdrawal_*,    │  │ Haversine    │  │ /chat  45s TO, key in   │
   │    shops                           │  │ fallback ✅  │  │ header, keyword fallback│
   │  • Storage (chat_media, profiles)  │  └──────────────┘  └────────────────────────┘
   │  • Messaging (FCM topics)          │
   │  • Crashlytics ✅                  │   ❌ NO server-side code in repo:
   │  rules: firestore.rules /          │      earnings credit, withdrawal approval,
   │         storage.rules              │      mechanic verification, targeted push
   └───────────────────────────────────┘      all say "Admin SDK only" but no Admin SDK
```

**Data entry points:** customer creates `service_requests` (client write); mechanic accepts/updates same doc; both write `chat_rooms/messages`; mechanic writes own `mechanics` doc (incl. verification) and `withdrawal_requests`. **Trust boundary = Firestore Security Rules only** (there is no API tier in front of the DB). External calls leave the device to two EasyPanel hosts.

---

## 4. Detailed Findings

### A. Architecture

#### A1 — Three incompatible `ServiceRequest` schemas on one collection — ❌
**Evidence:** customer writer `lib/features/customer/booking/domain/models/service_request.dart:67,99-107` writes `customerLocation` (a `{lat,lng}` map) + `createdAt`. The earnings reader `lib/features/mechanic/earnings/data/repositories/firebase_earnings_repository.dart:249` does `data['location'] as GeoPoint` and `:259` `data['requestTime'] as Timestamp`. Three model files exist: `find lib -name service_request.dart` → booking/domain, dashboard/domain, dashboard/data.
**👨‍💻 Senior read:** the write-path and the read-path disagree on field names *and* types (`customerLocation` map vs `location` GeoPoint; `createdAt` vs `requestTime`). The hard casts have no null guard, so the moment a real Firestore round-trips a customer-created request into the earnings/dashboard reader, `_mapDocToServiceRequest` throws and the whole earnings summary fails (caught and mislabeled as `networkError`, `:81-86`). It "works" today only because Firebase is placeholder and nothing actually persists. This is a data-contract break masquerading as a duplicate-file smell.
**🧒 Layman read:** two people are filling in and reading the same form, but one writes the address in the "Home" box and the other only ever reads the "Location" box. As long as the form is fake, nobody notices. The day it's real, the reader sees a blank and tears up the whole report.
**Fix:** **A)** Pick one canonical field set, add null-safe parsing (`data['location'] as GeoPoint?`) so a mismatch degrades instead of crashing. **B)** Collapse to a **single** `ServiceRequest` model + one `fromFirestore`/`toFirestore` in `core/models`, delete the rivals, and add a round-trip test (`toFirestore` → `fromFirestore` equality) so the contract can't silently drift again.

#### A2 — Hybrid navigation & state management (stalled migration) — ⚠️
**Evidence:** `grep` counts — `extends StatefulWidget` in **45** files vs `Consumer*` in **4**; raw `Navigator.(push|pop|of)` in **44** files vs `context.go/push`/`GoRoute` in **11**; only `5` files define Riverpod providers. `README.md:62` admits "feature-by-feature migration … in progress (earnings migrated as the reference slice)."
**👨‍💻 Senior read:** two navigation systems and two state paradigms coexist. The real hazard isn't aesthetic — it's that the go_router `redirect` auth guard (see A3) only governs routes entered through go_router; the 44 `Navigator.push` call sites slip past it. Deep-linking, back-stack behavior, and route guards are now non-uniform.
**🧒 Layman read:** the building has a guarded front door and 44 unguarded side doors. Half-finished renovation; both the old and new layouts are live at once.
**Fix:** **A)** Document the boundary and forbid new `Navigator.push` in PRs. **B)** Finish the go_router migration so every screen is a route behind the guard; make Riverpod the single state source per feature.

#### A3 — Clean-architecture layering is real and test-enforced — ✅ (positive)
**Evidence:** `lib/features/<role>/<feature>/{data,domain,presentation}` is consistent; `test/architecture/feature_dependency_direction_test.dart` actually fails the build if `data/` or `domain/` imports `presentation/`.
**👨‍💻 Senior read:** an executable architecture rule is rare and genuinely good — it stops the most common rot (UI leaking into repositories). Credit where due.
**🧒 Layman read:** there's an automatic inspector that rejects work if the plumbing reaches into the living room. Keep it.
**Fix:** **A)** none. **B)** extend the same test to forbid cross-feature imports and enforce the single-model rule from A1.

### B. Data Layer

#### B1 — geohash index defined but unused; geo is client-side on a global window — ❌
**Evidence:** `firestore.indexes.json:16-18` defines an `isOnline,isVerified,geohash` index and `pubspec.yaml:62` pulls `geoflutterfire_plus`, but `grep -r geohash/GeoFlutterFire lib/` → **0 hits**. The mechanic "nearby jobs" feed `lib/.../dashboard/data/.../firestore_service_request_repository.dart:91-116` queries `status==pending` `orderBy(createdAt) limit(100)` then filters by Haversine in Dart.
**👨‍💻 Senior read:** the query fetches the **100 most recent pending requests globally**, then keeps only those within `radiusKm`. If request volume ever exceeds ~100 across all regions, a mechanic's truly-nearby job can fall outside the 100-newest cutoff and **never appear**. It's both a correctness bug (missed jobs) and a scale bug (every mechanic streams 100 docs regardless of locality). The right tool (geohash range query) is paid for in the index and the dependency but not wired up.
**🧒 Layman read:** instead of "show me jobs near me," it says "show me the 100 newest jobs anywhere, then I'll squint and keep the close ones." In a busy city the close job scrolls off the list before you see it.
**Fix:** **A)** add a coarse geohash `whereIn` prefix filter before the limit to bound results geographically. **B)** adopt `geoflutterfire_plus` `GeoCollectionReference.subscribeWithin(...)` so the database does the radius query against the existing index; drop the global 100-window.

#### B2 — Unbounded reads / inconsistent pagination — ⚠️
**Evidence:** `firebase_earnings_repository.dart:97-105` (`getCompletedServices`) has **no `.limit()`**; `EarningsPeriod.allTime` starts `2020-01-01` (`:239`). `getWithdrawalHistory` *does* cap at 20 (`:166`) but `getPendingWithdrawals` (`:186-204`) does not. Repo-wide: **106** `.collection(` call sites vs **8** `.limit(`.
**👨‍💻 Senior read:** opening the earnings screen on "All time" reads **every** completed job the mechanic has ever done, every time — Firestore bills per document read and latency grows linearly forever. Pagination is applied unevenly, which suggests it's ad-hoc rather than a policy.
**🧒 Layman read:** every time you check your earnings, the app re-counts your entire career from scratch instead of keeping a running total. Slow and pricey as history grows.
**Fix:** **A)** add `.limit()` + date-window caps to the unbounded queries. **B)** maintain a rolled-up `mechanic_stats` aggregate (updated server-side on job completion) so the dashboard reads one document, not N.

### C. API Contracts, Reliability & Security

#### C1 — Route guard is authentication-only, and most screens bypass it — ❌
**Evidence:** `lib/core/routing/app_router.dart:46-64` — `redirect` computes `isLoggedIn` and a `isPublicRoute` allow-list; it never inspects user **role**. `/mechanic/dashboard` (`:122-125`) and `/customer/booking` (`:91-94`) are gated only by "logged in." Meanwhile 44 files use `Navigator.push` (A2), which never hits this redirect.
**👨‍💻 Senior read:** any authenticated customer can route to the mechanic dashboard and vice-versa; there is no client-side authorization, only authentication. And since the guard only fires for go_router transitions, the imperative-nav screens (history, vehicles, earnings, chat, payment) aren't guarded at all. The only true backstop is Firestore Rules — which are themselves role-agnostic (anyone authed can read `mechanics`, create `service_requests`, etc.).
**🧒 Layman read:** the bouncer checks that you have *a* ticket, not *which* ticket — so a customer can walk into the mechanics-only room. And there are side doors with no bouncer at all.
**Fix:** **A)** add a role claim check in `redirect` and block cross-role routes. **B)** move role to a Firebase **custom claim** set server-side at signup, enforce it in both the router and Firestore Rules (`request.auth.token.role == 'mechanic'`), and route everything through go_router.

#### C2 — Firestore `update` rules have no field-level validation (price/status tampering) — ❌
**Evidence:** `firestore.rules:24-27` — `service_requests` `allow update` for either `customerId` or `mechanicId` with **no constraint on which fields change**. Create is `if request.auth != null` only (`:19`), not pinned to `customerId == request.auth.uid`.
**👨‍💻 Senior read:** the mechanic (a legitimate party) can `update` `actualPrice`, `tipAmount`, `status`, even `mechanicEarnings` inputs on a request they're attached to — there's nothing in the rule restricting the field set or the legal state transitions. Combined with the client-computed earnings (D-section), this is a direct path to inflating payouts. The unconstrained `create` also lets a client forge `customerId`.
**🧒 Layman read:** once you're on the work order, you can rewrite the price and mark it "paid" yourself — the system just trusts whatever number you write in.
**Fix:** **A)** in rules, restrict updates to a whitelist of fields per role and forbid changing money fields client-side (`request.resource.data.actualPrice == resource.data.actualPrice`). **B)** make price/earnings/status transitions **server-authoritative** (Callable Function / Admin SDK); the client only requests transitions.

#### C3 — Mechanics can self-grant "verified" status — ❌ (security/trust)
**Evidence:** `firestore.rules:11-13` — a user may `create/update` their own `mechanics/{uid}` doc with no field restrictions; the mechanic model persists arbitrary fields. The repo even ships `lib/core/dev/approve_all_mechanics.dart`, a script that sets `verification: {status:'approved', isVerified:true}` — documenting that **no real approval flow exists**.
**👨‍💻 Senior read:** the booking side filters on `verification.status == 'approved'`, but since the mechanic owns their own doc and rules don't protect the `verification` map, a mechanic can write `verified: true` directly. The "verified" badge customers rely on is self-issued. The dev script is dormant (`grep` shows it's never called) but it's privileged code compiled into the shipped bundle and a roadmap of the missing control.
**🧒 Layman read:** the "background-checked ✅" badge is a sticker mechanics print themselves. Customers think it's vetted; it isn't.
**Fix:** **A)** in rules, deny client writes to `verification`/`isVerified` (`!request.resource.data.diff(resource.data).affectedKeys().hasAny(['verification','isVerified'])`); delete the dev script from `lib/`. **B)** build an admin/Cloud-Function verification workflow that's the only writer of those fields.

#### C4 — Mechanic phone number + precise location readable by any authenticated user — ⚠️
**Evidence:** `firestore.rules:11` `allow read: if request.auth != null` on **all** `mechanics`. Model `lib/features/customer/booking/domain/models/mechanic.dart:12,14,97,101` stores `location` (exact lat/lng) and `phoneNumber`.
**👨‍💻 Senior read:** anyone who can register (registration is open) can list every mechanic and harvest their phone numbers and exact coordinates — a scraping/stalking surface. Coarse location is justifiable for a map; exact coordinates + direct phone for *all* mechanics to *all* users is not.
**🧒 Layman read:** sign up once and you can download every mechanic's phone number and home pin. That's a phonebook + map of strangers, handed to anyone.
**Fix:** **A)** split sensitive fields into a sub-doc readable only by a matched customer on an active request; coarsen the public map location to a geohash cell. **B)** serve mechanic discovery through a Function that returns only what the caller is entitled to.

#### C5 — `chat_rooms` listing is open to any authenticated user — ⚠️
**Evidence:** `firestore.rules:33` `allow list: if request.auth != null` (only `get` at `:34-35` is participant-restricted).
**👨‍💻 Senior read:** in Firestore, `list` governs queries. A crafted query can enumerate **all** chat-room documents — participants, last-message preview, timestamps — regardless of membership; per-doc `get` restriction doesn't stop a `list`. Metadata leak across all conversations.
**🧒 Layman read:** you can't open other people's chats, but you *can* pull the full directory of who's talking to whom and the latest message snippet.
**Fix:** **A)** change `list` to require `request.auth.uid in resource.data.participants` and ensure client queries always include that `where`. **B)** model an inbox sub-collection per user so listing is naturally scoped.

#### C6 — Resilience: timeouts ✅, but no retries, no idempotency, sequential batch — ⚠️
**Evidence:** timeouts present — OSRM `osrm_service.dart:32,82,205` (10/15/5s), chatbot `ai_chat_screen.dart:217` (45s). Fallbacks present — Haversine (`osrm_service.dart:59-63,126`), keyword chatbot (`ai_chat_screen.dart:480-508`). **But:** `calculateBatchETA` (`osrm_service.dart:109-121`) `await`s each destination **sequentially**; no endpoint is retried with backoff; `createServiceRequest` (`firestore_service_request_repository.dart:16-27`) uses auto-id + `set` with **no idempotency key or submit-debounce** (`grep` for `isSubmitting`/`debounce` in booking presentation → none).
**👨‍💻 Senior read:** good degradation, weak transience handling. Batch ETA for N mechanics is N serial round-trips (up to 10s each) — a 10-mechanic list can hang ~100s. A double-tap or auto-retry on "Request" creates duplicate jobs because nothing dedupes the write.
**🧒 Layman read:** when a server hiccups, the app gives up instead of trying again; it checks driving times one-at-a-time instead of all at once; and tapping "Book" twice can book twice.
**Fix:** **A)** `Future.wait` the batch ETA; add an `isSubmitting` guard + 1-retry-with-jitter on idempotent GETs. **B)** deterministic request IDs (e.g., `customerId+timestamp` hash) so re-submits are no-ops; central HTTP client with backoff.

#### C7 — Client ships the chatbot API key; cleartext traffic enabled — ⚠️
**Evidence:** `pubspec.yaml:112` bundles `.env` **as an app asset**; `ai_chat_screen.dart:17-20,70-83` reads the key from `dotenv`/`String.fromEnvironment` and sends it in `X-API-Key` + `Authorization` headers (`:192-197`). `AndroidManifest.xml:20` sets `android:usesCleartextTraffic="true"`; `.env.example:7` advertises `http://` LAN fallbacks.
**👨‍💻 Senior read:** any key compiled into a mobile binary or bundled as an asset is **public** — extractable with `apktool`. This is the mobile equivalent of leaking via `NEXT_PUBLIC_*`. Cleartext + LAN http means the chatbot call can be MITM'd on hostile networks. (Good news: it's gitignored, so it's not in *history* — see C8.)
**🧒 Layman read:** the "secret" password is printed inside the app everyone downloads, and some calls go over an unlocked channel anyone on the Wi-Fi can read.
**Fix:** **A)** rotate the key; force HTTPS only (`usesCleartextTraffic="false"`, keep LAN behind a debug flag). **B)** proxy chatbot calls through a Function that injects the key server-side and rate-limits per Firebase user, so no key ships in the app.

#### C8 — No secrets committed to git history — ✅ (positive)
**Evidence:** `.gitignore:43,56-59` ignores `.env`, `lib/firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`; `git ls-files` shows none tracked; a full `git log -p` secret-pattern scan surfaced only CLAUDE.md prose, no real keys.
**👨‍💻 Senior read:** the gitignore hygiene predates the first commit, so no rotation-on-leak fire-drill is needed for the repo itself. (The *runtime* shipping of the key in C7 is the separate, real problem.)
**🧒 Layman read:** no passwords were accidentally saved into the project's permanent record. Good.
**Fix:** **A)** none. **B)** add a CI secret-scan (gitleaks) so it stays that way.

#### C9 — Failure modes: Firebase errors are swallowed; targeted notifications need an absent server — ⚠️
**Evidence:** `main.dart:24-30` swallows Firebase init errors (except duplicate-app); `NotificationService.initialize()` wraps everything in try/catch (`notification_service.dart:~35-75`). `firestore.rules:51-54` only lets a user write a notification where `uid == recipientId`, so a client **cannot** create a notification for another user; there is no `functions/` to do it via Admin SDK.
**👨‍💻 Senior read:** when Firebase is misconfigured or down, the app **looks** healthy and silently no-ops every read/write — the worst failure mode for debugging ("works on my screen, saves nothing"). Cross-user push (mechanic→customer "I'm on my way") is impossible client-side and there's no server to do it, so that feature is effectively non-functional.
**🧒 Layman read:** if the database is unplugged, the app keeps smiling and quietly drops everything you do. And the app literally can't send the other person a notification — that needs a back-office computer that doesn't exist yet.
**Fix:** **A)** surface a non-blocking "offline / backend unavailable" banner when init fails instead of silent success. **B)** stand up Cloud Functions for fan-out notifications (and the other "Admin SDK only" flows the rules already assume).

### D. Performance, Cost & the Money Model

#### D1 — Withdrawals never reduce the balance; "net" == gross; fee hardcoded twice — ❌ (P0 for real money)
**Evidence:** `lib/features/mechanic/dashboard/domain/models/service_request.dart:69-72` computes `mechanicEarnings = basePrice − 15% + tip`; `:122` `netEarnings => mechanicEarnings`; earnings summary `firebase_earnings_repository.dart:77` sets `netEarnings: totalEarnings`. `submitWithdrawalRequest` (`:116-161`) writes a `pending` doc but nothing ever debits earnings, and there's no server to settle it. The 15% rule is duplicated in the model (`:71`) and `completion_summary_screen.dart:37`.
**👨‍💻 Senior read:** there is **no ledger**. Earnings are recomputed from completed jobs each view; withdrawals are write-only `pending` records that never settle (no `functions/`) and never subtract. So the displayed balance is always gross-of-withdrawals — a mechanic could "withdraw" repeatedly against the same earnings. "Net" being equal to gross also means the 15% platform fee is computed and then ignored in the summary. Two copies of the fee constant will drift.
**🧒 Layman read:** your wallet shows your *total lifetime income* and never goes down when you cash out — so on paper you can cash out the same money again and again. And the "after fees" number is actually the "before fees" number.
**Fix:** **A)** subtract settled+pending withdrawals from displayed balance immediately; single-source the 15% constant. **B)** real double-entry: a server-owned `balance` credited on job completion and debited atomically on withdrawal approval (Function + Firestore transaction).

#### D2 — Read amplification & realtime fan-out drive both latency and cost — ⚠️
**Evidence:** every mechanic holds a `.snapshots()` listener over the global 100-doc pending feed (B1); all-time earnings re-reads every completed job (B2); batch ETA is serial HTTP (C6).
**👨‍💻 Senior read:** Firestore bills per document read and per listener delivery. With M online mechanics each streaming 100 pending docs, writes fan out to M×(matching listeners); the cost curve bends with `mechanics × pending_volume`, not with the jobs a mechanic actually does. OSRM being self-hosted keeps routing at $0 (genuinely smart), so the dominant infra cost is Firestore reads, not maps.
**🧒 Layman read:** every mechanic is subscribed to a firehose of every new job in the country, and the meter ticks for each drop. The fix is to only subscribe each mechanic to *their neighborhood*.
**Fix:** **A)** geo-bound + paginate the pending feed (B1/B2). **B)** aggregate dashboards (`mechanic_stats`, regional shards) so reads scale with usage, not with global volume.

### E. The AI Layer (client-visible portion)

#### E1 — Client AI integration: defensive parsing, but no schema validation, no retry, key in client — ⚠️
**Evidence:** `ai_chat_screen.dart` — multi-endpoint failover (`:201-266`), 45s timeout (`:217`), very permissive payload parsing that tries ~12 keys and ultimately returns the **raw body** if nothing matches (`:247-252`), keyword fallback on any failure (`:480-508`). No retry/backoff; key shipped (C7); the model/prompt/RAG are off-repo (`README.md:67`).
**👨‍💻 Senior read:** the client treats the LLM response as untyped soup — good for demo robustness, bad for correctness: there's **no structured-output contract** (no schema/version field validated), so a malformed or adversarial backend response renders as raw text in a Markdown widget. The 45s timeout is generous; combined with no retry, a single slow call blocks the conversation. Markdown link taps are sanitized to external-launch only (`:771-776`) — a small but real guardrail. ✅
**🧒 Layman read:** the app accepts whatever the AI says in any shape and just prints it. Usually fine; but it has no way to tell a good answer from a garbled one, and it waits up to 45 seconds before giving up.
**Fix:** **A)** validate a minimal response schema (`{response: string, ...}`) and reject/clearly-mark anything that doesn't conform; cut the timeout to ~15-20s with one retry. **B)** version the contract between app and chatbot; pin it; add a client-side "this answer may be wrong" disclaimer for diagnostics.

#### E2 — Eval/quality is unverifiable from here; PII sent unscrubbed — ❓/⚠️
**Evidence:** `README.md:46` claims "87.4% accurate … Taglish 97.5%" but there is **no eval harness, dataset, or test** in the repo to substantiate it. `ai_chat_screen.dart:211-215` posts `message` + Firebase `user_id` + `conversation_id` to the external host.
**👨‍💻 Senior read:** you can't detect a quality regression you can't measure, and all the measurement lives off-repo. Sending the stable Firebase uid to a third-party diagnostic service is a (mild) PII/linkage concern with no scrubbing or consent gate visible.
**🧒 Layman read:** the brochure quotes a precise accuracy score, but there's no test in the box that proves it. Also, your user ID rides along to the outside AI service.
**Fix:** **A)** send an opaque per-session token instead of the raw uid; caveat the accuracy claims as backend-measured. **B)** add a small golden-set eval (even 30 prompts) wired into CI against the chatbot so regressions are visible.

### F. Ops & Quality

#### F1 — Fresh clone does not build (missing `.env` + `firebase_options.dart`) — ❌ (P0 onboarding)
**Evidence:** `ls .env` and `ls lib/firebase_options.dart` → both **absent** (gitignored, `.gitignore:43,56`); `pubspec.yaml:112` lists `.env` as a **required asset**; `main.dart:13` imports `firebase_options.dart` and `:26` uses `DefaultFirebaseOptions.currentPlatform`.
**👨‍💻 Senior read:** two independent hard blockers. Flutter's asset bundler errors on a declared-but-missing asset, and the compiler errors on the missing `firebase_options.dart` import. The prior `docs/AUDIT.md` reporting a successful build was on a machine where these existed locally; **as cloned in CI/a new dev's machine, it won't compile.** This is the single biggest day-one friction.
**🧒 Layman read:** download the project and it won't even start — two required files are deliberately left out and there's no "create these first" guard rail that actually runs.
**Fix:** **A)** commit a checked-in `.env.example`→`.env` bootstrap step + a placeholder `firebase_options.dart` template, and a `SessionStart`/`make setup` that copies them; document in README. **B)** make the build fail *loudly with instructions* (a pre-build script that checks for both and prints the fix).

#### F2 — No CI/CD, no env separation, no rollback path — ❌
**Evidence:** `.github/workflows` does not exist; no other pipeline config; no dev/staging/prod Firebase split in the repo.
**👨‍💻 Senior read:** nothing runs `flutter analyze`/`flutter test` on push, so the 6 tests and the architecture guard only help if a human remembers to run them. There's one (placeholder) Firebase project, so there's no safe place to test rules/migrations before prod, and no rollback story.
**🧒 Layman read:** there's no automatic quality gate when code is pushed, and only one shared environment — changes go straight to "the real thing" with no undo.
**Fix:** **A)** add a GitHub Actions workflow: `flutter pub get && flutter analyze && flutter test` on PR (the repo already has a `session-start-hook` skill to make web sessions test-ready). **B)** separate dev/prod Firebase projects + `firebase deploy --only firestore:rules` in CI with review.

#### F3 — Observability: Crashlytics ✅, but no metrics/traces/alerts — ⚠️
**Evidence:** `main.dart:32` routes Flutter fatals to Crashlytics; `core/utils/app_logger.dart` (logger pkg) used in repositories; **47** `debugPrint` call sites; no analytics/metrics/tracing SDK present.
**👨‍💻 Senior read:** crash capture is the right first rung and it's done. But there are no product/perf metrics (request success rate, ETA latency, chatbot fallback rate) and no alerting — you'd learn about a chatbot outage from users, not a dashboard. `debugPrint` still emits in release.
**🧒 Layman read:** you'll hear about full crashes, but not about "the AI is silently failing 40% of the time" — nothing is watching the gauges.
**Fix:** **A)** log a Crashlytics custom event when the chatbot/OSRM fallback triggers, so silent degradation is visible. **B)** add Firebase Analytics/Performance for the hot paths + alerts.

#### F4 — Testing: better than the docs claim, but shallow where it matters — ⚠️
**Evidence:** 6 tests — `test/widget_test.dart:11-24` (a real theme smoke test, **not** the default counter), `test/design_system/{app_theme,no_raw_design_values,service_semantics}_test.dart`, `test/architecture/feature_dependency_direction_test.dart`, `test/features/mechanic/earnings/earnings_controller_test.dart`.
**👨‍💻 Senior read:** the existing tests are real and valuable (design tokens, layering guard, earnings notifier). But the **highest-risk logic is untested**: the schema round-trip (A1), Firestore rules (no emulator tests), booking/auth/chat flows, and the money math (D1). Earnings is the only feature with logic tests — and it's the feature whose model schema is broken.
**🧒 Layman read:** there are real tests, just not on the dangerous parts — the money and the data-format mismatch have no safety net.
**Fix:** **A)** add a `toFirestore→fromFirestore` round-trip test for `ServiceRequest` (would catch A1 today). **B)** Firestore **rules emulator** tests for the self-verification, price-tamper, and chat-list holes; a money-math test for withdrawals.

#### F5 — Documentation drift & residual cruft — ⚠️
**Evidence:** `CLAUDE.md` claims "only test is the broken counter test" and "deprecated `withOpacity`" — both false (`grep withOpacity lib/` → 0; `grep '[^.]print(' lib/` → 0; 6 tests exist). `docs/AUDIT.md:22,45-46` repeats the stale test claim and lists `docs copy/` + `_backup` cruft that is **already deleted** (`ls` confirms gone). Still present: duplicate `mechanic.dart` (×2), `service_request.dart` (×3), `payment_confirmation_screen.dart` (×2); orphan `booking_request.dart` (an **OpenRouteService**-based repo, pre-OSRM); `lib/examples/` (two demo files compiled into the app); empty `analyze_full.txt`; dormant `lib/core/dev/approve_all_mechanics.dart`. **Note:** the prior audit's "2 analyze errors" in `booking_request.dart` appear **resolved** — both its imports (`toast_helper.dart`, `openroute_booking_repository.dart`) now exist; current `flutter analyze` count is ❓ (couldn't run).
**👨‍💻 Senior read:** 40+ markdown docs is a lot of surface area to keep true, and it isn't — a new dev following `CLAUDE.md` would mistrust the (actually decent) test suite and chase non-existent `withOpacity` work. The duplicates feed A1's schema drift. `lib/examples/` and the dev backdoor ship dead/privileged code in the binary.
**🧒 Layman read:** the instruction manual describes an older, messier version of the app — some warnings are about problems already fixed, and it misses the real ones. And a few junk files are still bundled in.
**Fix:** **A)** correct `CLAUDE.md` (tests, lints, state mgmt) and delete `lib/examples/`, `lib/core/dev/`, `analyze_full.txt`, and verified-unused duplicates. **B)** prune docs to a small canonical set; add a docs-lint or "last-verified" date convention.

---

## 5. Prioritized Remediation Backlog

**Effort:** S = <½ day · M = ½–2 days · L = >2 days. (LLM-assisted; verify locally.)

### P0 — security / data-loss / will-break-prod
| ID | Item | Effort |
|---|---|---|
| P0-1 | **Make a clone buildable** — bootstrap `.env` + `firebase_options.dart` (template + setup script + README), fail loudly if missing (F1). | **S** |
| P0-2 | **Unify the `ServiceRequest` schema** to one model + round-trip test; null-safe parsing so a mismatch degrades, not crashes (A1). | **M** |
| P0-3 | **Lock down Firestore Rules**: pin `create` to `customerId==uid`; whitelist updatable fields; forbid client writes to `verification`/`isVerified`/money fields; scope `chat_rooms` `list` to participants (C2, C3, C5). | **M** |
| P0-4 | **Fix the money model**: server-owned balance, debit on withdrawal, single fee constant, real ledger (D1). | **L** |
| P0-5 | **Rotate + stop shipping the chatbot key**; force HTTPS (C7). | **S** |

### P1 — reliability / cost / authz
| ID | Item | Effort |
|---|---|---|
| P1-1 | **Role-aware routing** via custom claims; route every screen through go_router (C1, A2). | **M** |
| P1-2 | **Geo-bound the pending feed** with geohash + pagination (kills missed-jobs bug and read amplification) (B1, B2, D2). | **M** |
| P1-3 | **Stand up Cloud Functions** for the "Admin SDK only" flows: verification, withdrawal settlement, cross-user notifications (C3, C9, D1). | **L** |
| P1-4 | **Protect mechanic PII** — sub-doc + coarse public location (C4). | **M** |
| P1-5 | **Resilience pass** — parallel batch ETA, submit idempotency, retry-with-backoff (C6). | **S** |
| P1-6 | **CI** — `analyze + test` on PR; add rules-emulator tests for P0-3 (F2, F4). | **M** |

### P2 — maintainability / polish
| ID | Item | Effort |
|---|---|---|
| P2-1 | Delete `lib/examples/`, `lib/core/dev/`, `analyze_full.txt`, verified-unused duplicates & orphan `booking_request.dart` (F5). | **S** |
| P2-2 | Correct `CLAUDE.md`/docs drift; prune to a canonical doc set (F5). | **S** |
| P2-3 | AI response-schema validation + tighter timeout/retry; opaque session id instead of raw uid (E1, E2). | **M** |
| P2-4 | Degradation telemetry (Crashlytics events on OSRM/chatbot fallback) + perf metrics (F3). | **S** |
| P2-5 | Single-source the 15% platform-fee constant; remove the unused `geoflutterfire_plus` dep if B1 isn't adopted (D1, B1). | **S** |

---

## 6. Could Not Verify (needs a human)

- **❓ Live build/analyze/test results.** Flutter SDK absent in this container — `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk` were **not** run. The prior `docs/AUDIT.md` reported "125 issues / 2 errors" on Flutter 3.41.7, but those 2 errors appear resolved (both imports now exist). **Run `flutter analyze` + `flutter test` to get current numbers.**
- **❓ The entire backend** ("ARS Rapide" FastAPI + Gemini 2.0 + LangGraph + ChromaDB/RAG + Redis) lives in a **separate, unreachable repo**. Could not verify: model pinning, prompt versioning, `max_tokens`/cost ceiling, retry/timeout server-side, RAG index correctness, Redis eviction/rate-limit policy, structured-output contract, or PII handling at rest. **Audit that repo separately.**
- **❓ EasyPanel/VPS posture** — single-instance vs HA, backups + tested restore, healthchecks, resource limits, TLS config for both `pacebeats-ars-chatbot` and `pacebeats-osrm-philippines` hosts. Not inspectable from the client repo.
- **❓ Real Firebase project config** — whether production Firestore Rules/Indexes match the committed `firestore.rules`/`firestore.indexes.json`, App Check status, Auth providers enabled, and Storage CORS. The committed files are placeholders-adjacent (`com.example.arsapplication`).
- **❓ The "87.4% / 97.5% Taglish" accuracy claims** (`README.md:46`) — no eval harness in-repo to confirm or refute.
- **❓ Live-location "updates every 30s"** (`README.md:49`, `location_sharing_service.dart:30`) — the in-repo service only sends a **static** Google-Maps pin link; any recurring 30s refresh, if it exists, is elsewhere or aspirational. Confirm against the booking/dashboard map controllers on-device.
- **❓ Google Maps native rendering** — `AndroidManifest.xml:36-37` has a placeholder `YOUR_API_KEY_HERE`, so `google_maps_flutter` widgets won't render on Android until a real key is added (the app also uses `flutter_map`/OSM tiles, which don't need it). Verify which map path each screen actually uses.

---
_End of audit. Findings are evidence-based as of the repo state on 2026-06-05; re-run with the Flutter toolchain and access to the backend/EasyPanel to close the §6 gaps._
