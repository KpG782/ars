# Talyer — Deployment & Release

> From `flutter run` to the stores, without the rejection loop. The store-
> compliance gate below is non-negotiable — it's the exact list that bounces
> apps like this.

## 1. Environments & flavors

Three isolated **Firebase projects**, one app, selected at build time — no
secrets in source.

| Env | Firebase project | Build |
|---|---|---|
| dev | `talyer-dev` | `flutter run --dart-define=ENV=dev` |
| staging | `talyer-staging` | internal testers (Firebase App Distribution / TestFlight) |
| prod | `talyer-prod` | store releases |

- Android **flavors** (`dev`/`staging`/`prod`) + matching `applicationId`
  suffixes; iOS **schemes/configs**. `firebase_options_<env>.dart` selected via
  `ENV`. Real `google-services.json` / `GoogleService-Info.plist` are
  **gitignored** and injected by CI from secrets.
- Bundle id: **`ph.talyer.app`** (prod) — never `com.example.*` (auto-reject).

## 2. Build & release

| Platform | Command | Target |
|---|---|---|
| Android | `flutter build appbundle --flavor prod` | Play Console (internal → closed → prod, staged %) |
| iOS | `flutter build ipa --flavor prod` | App Store Connect → TestFlight → review |
| Web (ops/landing) | `flutter build web` | Firebase Hosting |

## 3. ⛔ Store-compliance gate (must pass before submit)

Straight from the ARS audit — each is a hard rejection on its own:

- [ ] **Account deletion** in-app (customer **and** mechanic) + public web
      deletion URL + server-side cascade (Apple 5.1.1(v) / Google Play).
- [ ] **iOS location usage string** `NSLocationWhenInUseUsageDescription`
      (foreground-only to avoid heavier review); Android prominent disclosure
      for FINE location.
- [ ] **Chat moderation** — report/block + abuse queue + EULA objectionable-
      content clause (Apple 1.2 UGC).
- [ ] **Real config** — `ph.talyer.app` bundle id, real Firebase, real Maps key,
      no `usesCleartextTraffic`, no leaked keys (the ORS key is deleted).
- [ ] **Privacy** — privacy policy URL; **Play Data Safety** form + **Apple
      privacy nutrition labels** matching what's collected (location, gov-ID,
      chat). **PH Data Privacy Act / NPC** registration for sensitive PII.
- [ ] **Payments framing** — repair = physical service → external rails
      (PayMongo/GCash/cash), **not** IAP. Review note: *"on-demand marketplace;
      payments are for in-person physical repair, consumed outside the app —
      per Apple 3.1.5(a), like Uber/Grab."* (Only digital add-ons — premium AI,
      paid loyalty, boosts — would need IAP.)

## 4. CI/CD (GitHub Actions)

`.github/workflows/ci.yaml` (in this repo) runs on every PR:
`flutter pub get → format check → flutter analyze → flutter test`. Extend per
phase:

| Stage | Adds |
|---|---|
| PR | analyze + test + (Phase 1) Firestore **rules emulator tests** |
| merge → main | build dev/staging artifacts; deploy Functions + rules to staging |
| tag `v*` | build prod AAB/IPA; upload to Play internal + TestFlight; deploy prod Functions/rules |

Secrets (keystores, service accounts, store API keys, `google-services.json`)
live in **GitHub Actions secrets**, injected at build — never committed.

## 5. Backend deploy

- **Functions/rules/indexes** versioned in `functions/` + `firestore.rules` +
  `firestore.indexes.json`; deployed per env via CI (`firebase deploy --only
  functions,firestore:rules,firestore:indexes -P <env>`).
- **Migrations:** additive, backward-compatible; never a destructive rename on a
  live collection — dual-write then backfill.

## 6. Rollout & safety

- **Staged Play rollout** (5% → 20% → 100%) watching Crashlytics + ANR.
- **Remote Config kill switches**: surge on/off, city gating, feature flags for
  half-built features — disable a bad feature without shipping a build.
- **Crashlytics velocity alerts**; payment-webhook failure alerts; dispatch
  match-rate dashboard.
- **Rollback**: Functions/rules redeploy previous version; app via Play halt +
  prior track.

## 7. Pre-launch checklist
Spine green in CI · §3 gate fully checked · staging soak with real mechanics in
one barangay · privacy policy + deletion URL live · monitoring + alerts wired ·
support inbox + dispute path manned.
