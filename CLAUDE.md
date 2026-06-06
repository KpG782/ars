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
flutter test             # run tests (design-system + earnings controller suite; currently green)
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

`lib/firebase_options.dart` and `android/app/google-services.json` are **committed with clearly-fake placeholder values** (`FAKE-…` keys, `projectId: ars-placeholder`, package `com.example.arsapplication`) so the app **builds and runs out of the box**. `main.dart` wraps `Firebase.initializeApp` in try/catch, so **the UI works, but anything backend-dependent (real auth, Firestore, push) will not.** Don't assume the backend works when debugging. To enable it: run `flutterfire configure` to overwrite the placeholders with real config, and add the native `ios/Runner/GoogleService-Info.plist` (still gitignored). The `.env` chatbot key is gitignored too; a SessionStart hook (`.claude/hooks/session-start.sh`) recreates it from `.env.example` in fresh web sessions.

## Known issues

See `docs/AUDIT.md` for the full audit. Highlights:

- `flutter analyze` is **clean (0 issues)** and `flutter test` is **green (15 tests)** — design-system token/semantics tests plus the earnings controller. The historical `booking_request.dart` import error, the broken default counter test, the `withOpacity`/`print` lint noise, the `docs copy/` folder, and the `_backup` screen are all already resolved/removed.
- Remaining cruft (report only — verify the import graph before deleting): likely-dead duplicates `lib/features/customer/data/models/mechanic.dart`, `lib/features/mechanic/dashboard/data/models/service_request.dart`, and the two `payment_confirmation_screen.dart`. The orphan `lib/.../services/presentation/screens/booking_request.dart` (reachable only via the unused `services/services.dart` barrel) hardcodes an OpenRouteService API key — rotate and remove it.
- `docs/AUDIT.md` predates the current code and is **stale** in places (it describes an earlier, smaller snapshot).

## Tooling available

- **Context7 MCP** (`context7`) — fetch up-to-date library/package docs (Flutter, Firebase, etc.). Prefer it over memorized APIs. Verify with `claude mcp list`.
- **Skills**: `ui-ux-pro-max` (UI/UX design), `hallmark` (design audit/redesign), `superpowers:brainstorming` (before feature work) and the wider superpowers suite (TDD, debugging, plans, verification).
