# Talyer

> **Verified mechanics, on demand.** A Philippine on-demand mechanic / roadside-repair marketplace — vehicle owners ↔ TESDA-verified mechanics. *Talyer* (from Spanish *taller*) is the everyday Filipino word for an auto repair shop, so the name owns the category the way **Angkas** owns the ride.

This repository is the **clean Talyer foundation**: a complete Flutter **design system**, an **app shell** (splash → role-select → gallery), a **feature-first clean-architecture spine** (Riverpod + go_router), and **one reference feature slice** wired end-to-end. No legacy code — it's the base to migrate every ARS feature onto, the *right* way.

## Plans (read these)

| Doc | What |
|---|---|
| **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** | the spine: layers, dependency inversion, Riverpod, routing, Firebase + Cloud Functions, why the server owns money & matching |
| **[docs/MIGRATION_PLAN.md](docs/MIGRATION_PLAN.md)** | every ARS feature → Talyer module + action, with audit issues fixed *as you port*; phased roadmap |
| **[docs/SCALABILITY.md](docs/SCALABILITY.md)** | Firestore data model, dispatch at scale, the live-GPS cost trap, observability |
| **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** | environments/flavors, CI/CD, the ⛔ store-compliance gate, rollout & rollback |

> ⚠️ **Brand/legal note:** *Talyer* is a generic common word, so for protection register a **distinctive mark** (stylised wordmark, or a compound such as *TalyerGo / Talyer PH*) and run an IPOPHL + App/Play Store name-availability check before launch.

## What's inside

```
lib/
  core/design/            ← the design system (import via design.dart)
    tokens/               colors · typography · spacing · radii · elevation · motion
    theme/                talyer_theme.dart (Material 3 ColorScheme + ThemeData, light+dark)
    components/           button · card · verified badge · status chip · rating ·
                          text field · service tile · mechanic card · empty state · bottom sheet
    design.dart           single-import barrel
  features/
    shared/auth/          ← landing + authentication (first feature)
      domain/             app_user.dart · auth_repository.dart (incl. deleteAccount, a P0)
      data/               fake_auth_repository.dart (→ FirebaseAuth in Phase 1)
      presentation/       auth_controller (Notifier) · landing/login/signup screens
    customer/mechanics/   ← REFERENCE SLICE (the pattern every feature follows)
      domain/             mechanic.dart (entity) · mechanic_repository.dart (interface)
      data/               fake_mechanic_repository.dart (→ Firestore in Phase 1)
      presentation/       providers + find_mechanic_screen.dart (skeleton/empty/error/data)
  app/
    app.dart  router.dart screens/ (splash · role_select · gallery)
  main.dart               ProviderScope root
test/                     design_system_test.dart · auth_test.dart
docs/                     ARCHITECTURE · MIGRATION_PLAN · SCALABILITY · DEPLOYMENT
docs/design-system/       tokens.md · components.md · preview.html · README.md
.github/workflows/ci.yaml flutter analyze + test on every PR
```

### The reference slice

`customer/mechanics` is the architectural proof: tap **Magpa-ayos** → Continue
and you see a real `AsyncValue` flow — skeleton → data (`MechanicCard` list) →
empty (`TalyerEmptyState.noMechanic`) → error — fed by a `FakeMechanicRepository`
behind a domain interface. Phase 1 swaps the fake for Firestore by changing
**one provider override**; the screen never changes. Copy this shape for every
migrated feature.

### Entry flow (auth — first feature)

`splash → landing (/welcome) → signup | login → role-select → find-mechanic`.

The **landing page** sells the trust promise (verified mechanics · no-surprise
pricing · anywhere) with two CTAs. **Login/Signup** run through
`AuthController` (`Notifier<AsyncValue<AppUser?>>`) backed by a
`FakeAuthRepository` — visible labels, inline validation, a loading button, and
an announced (`Semantics.liveRegion`) error with a recovery path. The
`AuthRepository` interface includes **`deleteAccount`** from day one (the P0
store requirement ARS was missing). Try `wrong@talyer.ph` to see the error
state. Phase 1 swaps the fake for `FirebaseAuthRepository` — screens unchanged.

## Design system at a glance

| Token | Value | Role |
|---|---|---|
| **Brand teal** | `#3DB3A9` | identity — logo, verified badge, headers |
| **Primary (interactive)** | `#1F8079` | filled buttons (white text clears AA 4.5:1) |
| **Accent orange** | `#F97316` | energy / secondary CTA |
| **Emergency red** | `#DC2626` | SOS / breakdown only |
| **Verified brass** | `#B7892B` | the trust seal |
| Neutrals | slate `50→950` | surfaces & text |
| Type | **Space Grotesk** + **Inter** | display + body (OFL via `google_fonts`) |

Trust-teal leads; orange energises. Full light **and** dark themes ship from the same tokens.

## Run it

```bash
flutter pub get
flutter run                 # splash → role-select → design-system gallery
```

The **gallery screen** renders every token and component live in both light and dark — the fastest way to review the system. A static `docs/design-system/preview.html` mirrors it for non-Flutter viewers.

## Using the design system

```dart
import 'package:talyer/core/design/design.dart';

TalyerButton(label: 'Tawag ng Talyer', icon: Icons.handyman_rounded, onPressed: book);
MechanicCard(name: 'Mang Ramon', specialization: 'Engine • Brakes',
    rating: 4.8, reviews: 213, distanceKm: 1.4, etaMinutes: 8, priceFrom: '₱350');

// brand tokens anywhere:
final teal = context.talyer.primary;
```

## Principles (baked in)

- **Trust is visible** — the Verified seal and ratings are first-class components.
- **No dead-ends** — `TalyerEmptyState` always offers the next action (incl. the launch-critical "no mechanic available").
- **Accessible by default** — ≥48dp targets, AA contrast, focus states, `prefers-reduced-motion` honoured (`TalyerMotion.respectReduceMotion`).
- **Taglish for warmth, English for trust** — see the role-select & sheet copy.

---

Built from the strategy in the ARS audit (`docs/REBRAND_AND_COMPETITOR_ANALYSIS.md` in the source repo).
