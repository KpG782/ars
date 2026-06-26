# Talyer — Feature Migration Plan (ARS → Talyer)

> Port **every** ARS feature into Talyer's architecture — but fix the audit's
> issues *as you port*, not after. Strategy: **strangler pattern** — stand up
> the spine, move one vertical slice at a time (domain → fake → Firestore →
> UI), keep the app runnable at every commit.

## 1. Migration strategy

1. **Spine first (done / in this repo):** design system, app shell, routing,
   Riverpod wiring, and one reference slice (`customer/mechanics`) proving
   domain → repo interface → fake data → provider → design-system UI.
2. **Per feature, in this order, every time:**
   `domain` (entities + repo interface + use cases) → `data` (Fake repo so the
   screen runs now) → `presentation` (screens from design-system components) →
   **swap Fake → Firestore** when Phase-1 backend lands. The screen never
   changes when the backend arrives — that's the point of the interface.
3. **Definition of done (per feature):** all four UI states designed; domain
   unit-tested with the fake; no `cloud_firestore` import in `presentation/`;
   a11y pass (targets/contrast/labels); copy in the string layer; the relevant
   audit issue closed.

## 2. Feature inventory & action map

Action: **Port** (lift with light cleanup) · **Refactor** (re-layer into clean
arch) · **Rebuild** (audit issue ⇒ redesign) · **New** (gap to fill) · **Drop**.

| ARS feature | Action | Talyer module | Audit issue fixed |
|---|---|---|---|
| Customer auth (login/signup/email verify) | Refactor | `shared/auth` | — |
| **Customer account deletion** | **New** | `shared/auth` | ⛔ store ship-blocker (Apple 5.1.1(v)) |
| Mechanic 6-step onboarding + verification | Refactor | `mechanic/onboarding` | surface as Verified badge |
| Service selection (Tire/Brake/Engine/Other) | Refactor | `customer/booking` | add price range + Motorcycle lane |
| **Pricing / quote engine** | **New** | `customer/booking` | ⛔ absent; two-funnel quote |
| Location select | Port | `customer/booking` | + iOS location usage string |
| Live map + ETA (OSRM) | Refactor | `customer/booking` + `core/services` | static-point → live GPS stream |
| **Dispatch / matching** | **Rebuild** | `mechanic/dispatch` + Functions | ⛔ broadcast pin-leak + non-txn accept |
| In-app chat | Refactor | `customer/booking` + `mechanic/jobs` | ⛔ add moderation (Apple 1.2) |
| AI chatbot | Port | `customer/support` | repurpose as photo-triage diagnosis |
| Payments | **Rebuild** | `customer/payments` + Functions | ⛔ placeholder → PayMongo/Xendit + escrow |
| Tipping | Port | `customer/payments` | 100% pass-through |
| Vehicles (garage) | Port | `customer/vehicles` | feed maintenance reminders |
| Booking history | Refactor | `customer/history` | wire to one-tap rebook |
| Saved places | Port | `customer/booking` | — |
| Feedback / ratings | **Rebuild** | `customer/booking` + Functions | ⛔ collected-but-invisible → surfaced + ranks |
| Support | Refactor | `customer/support` | attach to booking; add dispute |
| Payment methods | Port | `customer/payments` | — |
| Mechanic dashboard + map | Refactor | `mechanic/dispatch` | pin-privacy, FCM push |
| Mechanic earnings + history | **Rebuild** | `mechanic/earnings` + Functions | re-query → append-only ledger + cashout |
| Completion summary | Refactor | `mechanic/jobs` | mandatory proof-of-work photos |
| **SOS / share-trip** | **New** | `customer/booking` | activate dead `emergency` token |
| **Referrals / growth loop** | **New** | `shared/growth` | wire dead `appliedPromoCode` |
| Maintenance reminders → rebook | **New** | `customer/history` | highest-ROI demand lever |
| Notifications (FCM) | Port | `core/services` | reuse for push + reminders |
| Orphan `BookingRequestMapScreen` (leaked ORS key) | **Drop** | — | rotate key, delete |
| Placeholder Firebase / `com.example.*` bundle id | **Rebuild** | `core/firebase` + config | ⛔ store ship-blockers |

## 3. Phased roadmap (sequenced to *ship*, mirrors the strategy doc)

### Phase 0 — Spine (this repo)
Design system ✓ · app shell ✓ · routing + Riverpod ✓ · reference slice ✓ · CI ✓.

### Phase 1 — Backend + submittable (P0)
- Real Firebase project + flavors; real bundle id `ph.talyer.app`; rotate/remove
  leaked keys.
- `shared/auth` incl. **customer account deletion** + web deletion URL + cascade
  Function.
- iOS `NSLocationWhenInUseUsageDescription`; Android prominent disclosure.
- Chat **moderation** (report/block + queue + EULA).
- Swap reference slice + auth Fake repos → Firestore.
- **Server dispatch** (Cloud Function, nearest-first, **transactional accept**,
  offer TTL, FCM) — closes the double-accept + pin-leak bugs.
- Surface **Verified badge + ratings** (data already exists).

### Phase 2 — Parity (P1)
Payments (PayMongo/Xendit + authorize-then-capture escrow + tipping) ·
two-tier **quote engine** + AI photo-triage · live GPS stream + animated marker ·
append-only **earnings ledger** + GCash cashout · **SOS** + share-trip + warranty ·
cancellation/no-show + go-fee · vehicles/history/saved-places ported.

### Phase 3 — Growth (P2)
Referrals (mechanic-refers-mechanic, paid on completed jobs) · maintenance
reminders → rebook · motorcycle-first lane · B2B2C/fleet white-label · random
selfie re-verification.

## 4. Risk controls
- **Keep it runnable.** Every feature ships with a Fake repo first; `main` never
  needs a live backend to launch.
- **Feature-flag the half-built.** Remote Config gates unfinished features out
  of production builds.
- **No big-bang cutover.** ARS keeps running; Talyer grows slice-by-slice until
  it reaches parity, then becomes the product.
