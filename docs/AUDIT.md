# ARS Application — Setup & Health Audit

_Audit performed 2026-06-01. Cleanup scope: **report-only** (issues documented, no source files deleted or modified). Firebase: **run as-is** (no real backend wired)._

## TL;DR

**The app builds and runs.** It was bootstrapped, compiled to a debug APK, installed on an Android emulator, and launched to its role-selection screen ("Welcome to ARS! — I Need Repairs / I'm a Mechanic"). Firebase is placeholder so the backend doesn't connect, but the init error is caught and the UI works. There is meaningful cleanup debt (a duplicate docs folder, orphan/duplicate source files, a broken default test) that was documented but not changed.

## What ARS is

**ARS (Auto Repair Service)** — a Flutter app connecting vehicle owners with mechanics for on-demand auto repair: booking, live location sharing, OSRM-based ETA, in-app chat, payments, and a mechanic dashboard with a real-time map. Two roles (`customer`, `mechanic`) share one codebase. Backend: Firebase (Auth, Firestore, Storage, Messaging). Maps: `google_maps_flutter` + `flutter_map`. See `ARCHITECTURE.md`.

## Toolchain & build status

| Check | Result |
|---|---|
| Flutter | **3.41.7** (stable) at `/Users/kuya/development/flutter` |
| `flutter pub get` | ✅ success (`Changed 4 dependencies`; 82 packages have newer majors, none required) |
| `flutter analyze` | ⚠️ **125 issues** — 2 errors (in an orphan file, see below) + warnings/info |
| `flutter build apk --debug` | ✅ **Built `build/app/outputs/flutter-apk/app-debug.apk`** (first build ~383s; auto-installed Android SDK Platform 33) |
| Install + launch on `emulator-5554` | ✅ installed, app started (Impeller/OpenGLES), role-selection UI rendered |
| `flutter test` | ❌ **1 test, 0 passed, 1 failed** — the default counter test |
| Connected devices | Android phone (`SM A266B`), Android emulator (`emulator-5554`), macOS desktop, Chrome |

## Firebase — placeholder config (backend does not connect)

`lib/firebase_options.dart` holds **fake** credentials: API keys read `AlzaSy…` (the valid Google prefix is `AIzaSy…`), appIds are dummy hex (`…:android:a1b2c3d4e5f6g7h8`), and `iosClientId` is literally `'your-ios-client-id'`. `android/app/google-services.json` has a real-looking key but `package_name: com.example.arsapplication` and an empty `oauth_client`. There is **no** `ios/Runner/GoogleService-Info.plist`.

`main.dart` wraps `Firebase.initializeApp(...)` + notification init in a try/catch, so the app launches regardless. At runtime on Android the only Firebase log is `❌ Initialization error: [core/duplicate-app] A Firebase App named "[DEFAULT]" already exists` — caught and ignored (Android auto-initializes a default app from `google-services.json` before the manual call). **Net effect:** the UI works; real auth, Firestore reads/writes, and push notifications will not.

**To enable the backend later:** supply a real `google-services.json` + `GoogleService-Info.plist`, regenerate `firebase_options.dart` via the FlutterFire CLI (`flutterfire configure`), and change the `com.example.arsapplication` applicationId to a real one.

## `flutter analyze` — the 2 errors

Both are in **`lib/features/mechanic/services/presentation/screens/booking_request.dart`**:
- `uri_does_not_exist` — `import '../../../../core/utils/toast_helper.dart'` is off by one `../` (the file is 5 directories deep under `lib/`, so it needs five `../`, not four).
- `undefined_identifier` — `ToastHelper` (unresolved because of the bad import).

**This does not block the build:** the file is an **orphan** — nothing imports `booking_request.dart`, so it's never compiled by `flutter run`/`build`. The remaining ~123 issues are info/warnings: deprecated `withOpacity` (use `.withValues()`), deprecated Radio `groupValue`/`onChanged`, `avoid_print`, `use_build_context_synchronously`, and unused-element warnings.

## Cruft inventory (report-only — not changed)

| Item | Path | Note |
|---|---|---|
| Duplicate docs folder | `docs copy/` | Mirrors `docs/` with extra `… copy.md` files. Redundant. |
| Backup screen | `lib/features/mechanic/auth/presentation/screens/mechanic_splash_screen_backup.dart` | Dead copy of `mechanic_splash_screen.dart` (analyzer flags unused methods). |
| Orphan + broken import | `lib/features/mechanic/services/presentation/screens/booking_request.dart` | Imported nowhere; the source of the 2 analyzer errors. |
| Duplicate model | `lib/features/customer/booking/data/models/mechanic.dart` **and** `lib/features/customer/data/models/mechanic.dart` | Two `mechanic.dart`. |
| Duplicate model | `lib/features/mechanic/dashboard/data/models/service_request.dart` **and** `lib/features/mechanic/services/data/models/service_request.dart` | Two `service_request.dart`. |
| Duplicate screen | `lib/features/mechanic/dashboard/presentation/screens/payment_confirmation_screen.dart` **and** `lib/features/mechanic/services/presentation/screens/payment_confirmation_screen.dart` | Two `payment_confirmation_screen.dart`. |
| Empty file | `.env` | 0 bytes. |

> Before deleting any "duplicate," confirm which copy `main.dart`'s import graph actually uses — some are referenced, some are not.

## Test status

Only `test/widget_test.dart` exists, and it's the **default Flutter counter test** (`expect(find.text('0'), findsOneWidget)`), which fails because this app has no counter. There is effectively **no real test coverage**.

## Recommended next steps (prioritized)

1. **Fix or delete `booking_request.dart`** — either correct the import to `../../../../../core/utils/toast_helper.dart` or remove the orphan. Clears both analyzer errors.
2. **Replace the broken default test** with a real smoke test (e.g. pump `MyApp` and assert the role-selection screen renders) so `flutter test` is green.
3. **Wire real Firebase** when ready (FlutterFire configure + real config files + real applicationId), if the backend is needed.
4. **Remove cruft** — delete `docs copy/`, the `_backup` screen, and the verified-unused duplicate models/screens.
5. **Address lint noise** — migrate `withOpacity` → `.withValues()`, replace `print` with logging, and adopt `RadioGroup` for the deprecated radios.

## Claude tooling configured in this pass

- **`CLAUDE.md`** generated at repo root (commands, architecture, Firebase note, known issues, tooling).
- **Context7 MCP** added (local scope) and verified `✓ Connected` (`claude mcp list`) — for up-to-date library docs.
- **Project memory** written (5 facts + index) so future sessions know the project, the Firebase-placeholder situation, conventions, tooling, and cruft.
- Requested skills "impeccable" / "sobra" were **not recognized** and no source was given → skipped. `ui-ux-pro-max`, `superpowers` (incl. `brainstorming`), and `hallmark` are already installed.
