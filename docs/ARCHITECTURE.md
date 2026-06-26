# Talyer — Target Architecture

> The spine every feature plugs into. Designed to fix the ARS audit's structural
> problems (non-transactional dispatch, client-trusted money, invisible trust,
> re-query "ledgers") *by construction*, and to stay cheap and testable as it
> grows from one barangay to nationwide.

## 1. Principles

1. **Feature-first clean architecture.** Code is organised by *feature*, each
   with three layers (`presentation → domain → data`). Dependencies point
   **inward only**: presentation depends on domain; data implements domain;
   domain depends on nothing. This is the one good bone we keep from ARS.
2. **Dependency inversion at every seam.** Domain declares repository
   *interfaces*; data provides Firestore implementations; providers wire them.
   → swap a `Fake*Repository` for tests or offline demos without touching a
   screen. (It's how the app runs *today* with no backend.)
3. **The server owns money and matching.** Anything that must be correct under
   races or can't trust the client — dispatch/accept, payment capture, the
   earnings ledger, rating aggregation — lives in **Cloud Functions**, not the
   app. This directly fixes ARS's non-transactional `acceptServiceRequest` and
   client-derived balances.
4. **Tokens & components, never ad-hoc UI.** All UI is built from the design
   system (`lib/core/design`). No raw hex/padding in a screen.
5. **Every state is designed.** Loading (skeleton), empty, error, and the
   launch-critical *no-mechanic-available* path are first-class, not
   afterthoughts (`TalyerEmptyState`).
6. **Accessible & localised by default.** ≥48dp targets, AA contrast, focus,
   reduce-motion; Taglish-for-warmth / English-for-trust copy via a single
   string layer.

## 2. Layers

```
presentation/   Widgets + screens + Riverpod controllers (Notifier/AsyncNotifier).
                Holds NO business rules and NO Firestore types — only domain entities.
        │ depends on ▼
domain/         Pure Dart. Entities, value objects, repository INTERFACES, use cases.
                No Flutter, no Firebase imports. The contract + the rules.
        ▲ implemented by │
data/           DTOs/models (json ↔ entity), repository IMPLEMENTATIONS, data sources
                (Firestore, Storage, FCM, REST). The only layer that imports Firebase.
```

**Rules of the road**
- A screen never imports `cloud_firestore`. If you see that import in
  `presentation/`, the boundary leaked.
- Entities are immutable (`final`, `copyWith`, value equality). DTOs convert at
  the data edge — domain never sees a `DocumentSnapshot`.
- Use cases hold multi-step rules (e.g. *RequestService* = validate vehicle →
  create booking → kick dispatch). Trivial pass-throughs may call the repo
  directly from the controller.

## 3. State management — Riverpod 3

ARS already chose Riverpod; we standardise the patterns.

| Need | Provider | Notes |
|---|---|---|
| Singletons (repos, services) | `Provider` | wired once; overridden with fakes in tests |
| Auth/session | `NotifierProvider` | `Session` = signedOut / customer / mechanic |
| Async reads (nearby mechanics, history) | `AsyncNotifierProvider` / `FutureProvider` | exposes `AsyncValue` → drives skeleton/empty/error |
| Live data (booking status, location) | `StreamProvider` | Firestore stream → UI |
| Screen-local form state | `NotifierProvider.autoDispose` | disposed with the route |

Controllers expose `AsyncValue<T>`; screens `switch` on it to render
skeleton / data / error — no manual `isLoading` bools. Start hand-written
(this repo) and adopt `riverpod_generator` once a toolchain + `build_runner`
are in the loop.

## 4. Routing — go_router

- One `GoRouter` behind a `Provider` so `redirect` can read auth/session.
- **Guarded redirects:** unauthenticated → `/login`; role mismatch → the right
  shell. Customer and mechanic are **two route subtrees in one app** (never the
  Move-It split-app mistake), switched by role.
- Typed route constants in `core/routing/app_routes.dart`; deep-link ready.

## 5. Folder structure (target)

```
lib/
  core/
    design/            ← design system (built — tokens, theme, components)
    routing/           app_router.dart, app_routes.dart (guards, role shells)
    di/                providers.dart (global repo/service providers)
    firebase/          bootstrap (guarded init), firebase_options (gitignored real)
    services/          interfaces + impls: location, routing(OSRM), notifications(FCM)
    models/            shared value objects (Money, GeoPoint, Money, PhoneNumber)
    error/             Failure types, Result, error mapping
    i18n/              string keys (Taglish/English)
  features/
    shared/
      auth/            login, signup, verify, account-deletion  (data/domain/presentation)
    customer/
      mechanics/       find-a-mechanic (slice shipped as the reference pattern)
      booking/         service select → quote → live track → pay → feedback
      vehicles/        garage
      payments/        methods, checkout
      history/         bookings + rebook
      support/         help, dispute, AI chat
    mechanic/
      onboarding/      6-step verification
      dispatch/        incoming offers, accept (server-authoritative)
      jobs/            active job, completion + proof-of-work
      earnings/        ledger, cashout
  app/                 app.dart, shell, splash, role-select, gallery (design-system)
  main.dart
functions/             Cloud Functions (dispatch, payments, ledger, aggregation) — Phase 1
```

## 6. Backend architecture (Firebase)

| Service | Used for |
|---|---|
| **Auth** | phone/email; custom claims carry `role` (customer/mechanic) + `verified` |
| **Firestore** | source of truth: users, mechanics, bookings, chat, ledger, ratings (schema in `SCALABILITY.md`) |
| **Storage** | docs (license, NC II, gov-ID), proof-of-work photos |
| **Cloud Functions** | **server-authoritative logic**: dispatch/accept (transaction), payment intent + webhook capture, earnings-ledger writes, rating aggregation, FCM fan-out, account-deletion cascade |
| **FCM** | new-offer push to mechanics, status push to customers, reminders |
| **Crashlytics + Analytics + Performance** | observability |
| **Remote Config** | feature flags + kill switches (surge on/off, city gating) |

**Why Functions, not the app:** dispatch and payments must be correct under
concurrency and can't trust a client. ARS's bug — two mechanics both "winning"
a job via a non-transactional `update()` — is impossible when accept is a
Firestore transaction inside a Function guarded on `status == pending`.

## 7. Data flow — booking (worked example)

```
FindMechanicScreen ──watch──▶ nearbyMechanicsProvider (AsyncNotifier)
        │ tap "Book"                       │ calls
        ▼                                  ▼
RequestServiceUseCase ──▶ BookingRepository (interface)
                               ▲ implements
                     FirestoreBookingRepository ──create──▶ bookings/{id} (status: pending)
                                                              │ onCreate trigger
                                                              ▼
                                              dispatchFn: nearest-first offer ladder
                                                  → mechanic FCM push
                                                  → mechanic accepts (txn) → status: accepted
        ┌──────────────────────────────────────────────────────────────┘
        ▼
bookingStreamProvider (StreamProvider) ──▶ live status + mechanic GPS → UI
```

## 8. Cross-cutting

- **Errors:** data layer maps exceptions → `Failure`; use cases return
  `Result<T, Failure>`; controllers surface `AsyncValue.error`; UI shows the
  designed error state. No raw exceptions reach a screen.
- **Logging:** `logger` + Crashlytics non-fatals; never log PII (gov-ID, plate).
- **Config/secrets:** no API keys in the client. Maps key via build config;
  payment + routing secrets live in Functions. (ARS leaked an OpenRouteService
  key in-app — that class of bug is structurally prevented here.)
- **i18n:** one string layer keyed by purpose; Taglish for warmth, English for
  money/safety/legal.
- **Testing:** domain unit-tested with fakes; design system golden-tested;
  critical flows integration-tested. `flutter analyze` + `flutter test` gate CI.

## 9. Modularity for the long run

Start as one app with clean module boundaries. When build times or team size
demand it, extract by the seams that already exist: `design` → a package,
`core` → a package, each `feature/*` → a package, orchestrated with **melos**.
Because layers already point inward and features don't import each other, this
is a lift-and-shift, not a rewrite.
