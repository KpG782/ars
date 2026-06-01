# ARS Architecture And Analyzer Cleanup Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring `flutter analyze` to zero diagnostics while keeping the ARS design-system rollout stable and source-of-truth driven by `docs/design-system/ARS_DESIGN_SYSTEM_PREVIEW.html`.

**Architecture:** Treat this as two tracks: first protect the design-system boundary, then reduce analyzer debt by category. Avoid one huge refactor. Large UI files should only be split when the analyzer cleanup already touches that feature area.

**Tech Stack:** Flutter, Dart analyzer, Material 3 `ThemeData`, Figtree via `google_fonts`, existing `flutter_test` suite.

---

## Architecture Audit

The codebase is now safer than before because the theme has a real token layer:

- `docs/design-system/ARS_DESIGN_SYSTEM_PREVIEW.html` is the visual/design source of truth.
- `lib/core/theme/app_colors.dart` stores light/dark token values.
- `lib/core/theme/app_theme.dart` maps tokens into Material 3 roles and keeps temporary compatibility aliases.
- `test/design_system/no_raw_design_values_test.dart` prevents feature code from reintroducing raw hex colors, raw semantic Material palette calls, or raw numeric font sizes.

The remaining architectural risks are separate from the theme migration:

- Several presentation files are too large, especially booking and mechanic dashboard panels. They mix layout, service categorization, state display, and action wiring.
- Service color/category logic is duplicated across customer and mechanic widgets.
- Analyzer output is mostly hygiene debt, but it is large enough that real future regressions will be harder to spot.
- Some docs still describe pre-migration state and should be cleaned after the analyzer pass.

## Analyzer Cleanup Strategy

Do not fix all 490 diagnostics randomly. Use category passes so each change is reviewable and testable.

### Task 1: Freeze The Design-System Contract

**Files:**
- Modify: `test/design_system/app_theme_test.dart`
- Verify: `docs/design-system/ARS_DESIGN_SYSTEM_PREVIEW.html`
- Verify: `lib/core/theme/app_colors.dart`

- [ ] Run `flutter test test/design_system/app_theme_test.dart`.
- [ ] Confirm the test checks light and dark CSS variables from the HTML preview against Dart tokens.
- [ ] Run `flutter test test/design_system/no_raw_design_values_test.dart`.
- [ ] Expected result: both design-system tests pass before any analyzer cleanup begins.

### Task 2: Remove Unused Imports, Fields, Locals, And Dead Null Checks

**Files shown by current analyzer output include:**
- `lib/core/services/notification_service.dart`
- `lib/features/customer/booking/data/repositories/firestore_service_request_repository.dart`
- `lib/features/customer/booking/presentation/screens/booking.dart`
- `lib/features/customer/booking/presentation/widgets/booking_bottom_panels.dart`
- `lib/features/customer/booking/presentation/widgets/share_location_sheet.dart`
- `lib/features/mechanic/auth/presentation/widgets/auth_widgets.dart`
- `lib/features/mechanic/dashboard/presentation/controllers/mechanic_dashboard_controller.dart`

- [ ] Run `dart analyze --format machine` and filter `UNUSED_IMPORT`, `UNUSED_FIELD`, `UNUSED_LOCAL_VARIABLE`, `UNUSED_ELEMENT`, `DEAD_CODE`, `DEAD_NULL_AWARE_EXPRESSION`, `INVALID_NULL_AWARE_OPERATOR`, and `UNNECESSARY_NULL_COMPARISON`.
- [ ] Remove unused imports directly.
- [ ] Remove unused locals when they do not feed side effects.
- [ ] For unused private fields/elements, either remove them or wire them only if the surrounding feature clearly intended to use them.
- [ ] Replace impossible null-aware expressions with the non-null expression the type system already proves.
- [ ] Run `flutter test` after this pass.

### Task 3: Fix Async Context Diagnostics

**Files shown by current analyzer output include:**
- `lib/features/customer/booking/presentation/screens/booking.dart`
- `lib/features/onboarding/presentation/screens/splash_screen.dart`

- [ ] For each `use_build_context_synchronously`, inspect the awaited call and the context use after it.
- [ ] If the code is inside a `State`, guard with `if (!mounted) return;` immediately after the `await`.
- [ ] If the code has only a local `BuildContext`, guard with `if (!context.mounted) return;`.
- [ ] Do not keep unrelated mounted checks that do not protect the exact context being used.
- [ ] Run the affected widget tests and then `flutter test`.

### Task 4: Convert Deprecated Opacity Calls

**Files shown by current analyzer output include:**
- payment screens
- booking bottom panels
- mechanic map/dashboard/detail widgets
- earnings screen

- [ ] Replace `color.withOpacity(x)` with `color.withValues(alpha: x)`.
- [ ] Do not change alpha values.
- [ ] Run `dart format lib`.
- [ ] Run `flutter test`.

### Task 5: Const And Style Hygiene Pass

**Files:** broad `lib/features/**` pass.

- [ ] Apply `prefer_const_constructors` and `prefer_const_literals_to_create_immutables` in small batches by feature folder.
- [ ] Do not add `const` if it makes token-driven values impossible or unclear.
- [ ] Fix `curly_braces_in_flow_control_structures`.
- [ ] Replace dangling library doc comments with regular comments or `library;` declarations only where appropriate.
- [ ] Run `flutter test` after each feature folder batch.

### Task 6: Extract Shared Service Presentation Semantics

**Files:**
- Create: `lib/core/theme/service_semantics.dart`
- Modify: customer booking service selection widgets
- Modify: mechanic request card/panel widgets
- Test: `test/design_system/service_semantics_test.dart`

- [ ] Create a small `ServiceVisualSemantics` value object with `label`, `icon`, `accent`, `background`, and `text` fields.
- [ ] Add a pure resolver such as `ServiceVisualSemantics serviceVisualSemantics(String serviceType)`.
- [ ] Move duplicated tire/brake/engine/battery color branching into the resolver.
- [ ] Write tests for tire, brake, engine/oil, battery/electrical/ac, and fallback service types.
- [ ] Replace duplicated widget-local maps only after tests pass.

### Task 7: Split Large Presentation Files Only Where It Pays Off

**Candidates:**
- `lib/features/customer/booking/presentation/widgets/booking_bottom_panels.dart`
- `lib/features/mechanic/dashboard/presentation/widgets/mechanic_bottom_panels.dart`
- `lib/features/customer/booking/presentation/screens/booking.dart`

- [ ] Do not split these just to reduce line count.
- [ ] Split only when a stable component boundary already exists: panel header, status chip, service list, action group, map/ETA summary, payment summary.
- [ ] Keep public widget APIs small and typed.
- [ ] After each extraction, run `flutter test` and `flutter analyze`.

### Task 8: Final Analyzer Gate

- [ ] Run `flutter test`.
- [ ] Run `flutter analyze`.
- [ ] Run `dart analyze --format machine` and confirm no `ERROR`, `WARNING`, `INFO`, or `HINT` rows remain.
- [ ] Run the raw design-value guard:

```bash
flutter test test/design_system/no_raw_design_values_test.dart
```

- [ ] Update this plan with any intentionally deferred diagnostics. The target is zero, so deferrals need an explicit reason.

