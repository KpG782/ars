# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

**ARS (Auto Repair Service)** — a Flutter app connecting vehicle owners with mechanics for on-demand auto repair: booking, live location sharing, ETA, in-app chat, payments, and a mechanic dashboard with a real-time map. Backend is Firebase (Auth, Firestore, Storage, Messaging); maps via `google_maps_flutter` and `flutter_map`. Android-first; also targets iOS/web/macOS.

## Commands

```bash
flutter pub get          # install/resolve dependencies (run after pulling)
flutter run              # run on the default device; -d <id> to choose (e.g. -d emulator-5554, -d chrome, -d macos)
flutter devices          # list connected devices/emulators
flutter analyze          # static analysis / lints (see "Known issues" below)
flutter test             # run tests (NOTE: the only test is the broken default counter test)
flutter build apk --debug    # build a debug Android APK
```

## Architecture

Feature-first **clean architecture**. Full map in `docs/ARCHITECTURE.md`.

- `lib/core/` — shared: `auth/`, `theme/`, `services/` (notifications, OSRM routing, location sharing), `widgets/`, `utils/`, `constants/`, `models/`.
- `lib/features/<role>/<feature>/` — each with `data/` (models, repositories, services), `domain/` (entities, repositories, usecases), `presentation/` (screens, widgets).
  - Roles: `customer/`, `mechanic/`, and shared `onboarding/`.
- `lib/main.dart` — entry point; initializes Firebase (in a try/catch) + notifications, then shows the splash screen.

**Naming convention:** customer screens are prefixed `user_*` (e.g. `user_login_screen.dart`); mechanic screens are prefixed `mechanic_*` (e.g. `mechanic_dashboard.dart`).

**State management:** plain `StatefulWidget` today (BLoC is proposed in docs, not implemented). Navigation: pure Flutter `Navigator`.

## Firebase: placeholder config — backend does NOT work

`lib/firebase_options.dart` contains **fake** credentials (keys read `AlzaSy…` not `AIzaSy…`; dummy appIds; `iosClientId: 'your-ios-client-id'`). `android/app/google-services.json` uses `com.example.arsapplication` with an empty `oauth_client`; there is no `ios/Runner/GoogleService-Info.plist`. `main.dart` catches the init error, so **the app launches and the UI works, but anything backend-dependent (real auth, Firestore, push) will not.** Don't assume the backend works when debugging. To enable it: provide real config files, regenerate `firebase_options.dart` via the FlutterFire CLI, and fix the applicationId.

## Known issues

See `docs/AUDIT.md` for the full audit. Highlights:

- `flutter analyze` reports ~125 issues; **2 are errors** in `lib/features/mechanic/services/presentation/screens/booking_request.dart` (a wrong relative import). That file is an **orphan** (imported nowhere), so it does **not** block the build. The rest are info/warnings (deprecated `withOpacity`, `avoid_print`, unused elements in a backup file).
- Cruft (not cleaned — report only): duplicate `docs copy/` folder; `mechanic_splash_screen_backup.dart`; duplicate `mechanic.dart`, `service_request.dart`, and `payment_confirmation_screen.dart`. Verify the import graph before deleting any "duplicate."
- `test/widget_test.dart` is the default counter test and fails; it's the only test.

## Tooling available

- **Context7 MCP** (`context7`) — fetch up-to-date library/package docs (Flutter, Firebase, etc.). Prefer it over memorized APIs. Verify with `claude mcp list`.
- **Skills**: `ui-ux-pro-max` (UI/UX design), `hallmark` (design audit/redesign), `superpowers:brainstorming` (before feature work) and the wider superpowers suite (TDD, debugging, plans, verification).
