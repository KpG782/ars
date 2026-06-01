# ARS Feature Architecture Audit Phase 2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Audit the whole ARS app feature setup and prove whether each feature follows the intended architecture, design-system contract, and testable workflow boundaries.

**Architecture:** Keep the app’s existing feature-first structure, then verify each feature has clean dependency direction: `presentation -> domain -> data`, with `core` providing shared services, routing, theme, widgets, and cross-feature utilities. The audit should produce facts first, then only propose refactors where a boundary is clearly broken or a file is blocking safe maintenance.

**Tech Stack:** Flutter, Dart analyzer, Riverpod providers, GoRouter routing, Firebase repositories, Material 3 theme tokens, Flutter widget/unit tests.

---

## Audit Scope

Audit these feature areas first because they drive the product:

- `lib/features/onboarding`
- `lib/features/customer/auth`
- `lib/features/customer/booking`
- `lib/features/customer/dashboard`
- `lib/features/customer/payment`
- `lib/features/customer/history`
- `lib/features/customer/support`
- `lib/features/mechanic/auth`
- `lib/features/mechanic/dashboard`
- `lib/features/mechanic/chat`
- `lib/features/mechanic/earnings`
- `lib/features/mechanic/services`
- `lib/core`

The output should answer:

- Does the feature have clear `data`, `domain`, and `presentation` boundaries where needed?
- Does presentation import data-layer implementation details directly?
- Does data import presentation or UI code?
- Are domain models pure enough to test without Flutter?
- Are providers/routing kept in predictable places?
- Does the feature use `AppTheme`, `ArsLightColors`/`ArsDarkColors`, and shared widgets instead of raw UI values?
- Which large files should be split, and which should be left alone?
- Which tests prove the feature still works after cleanup?

## Task 1: Build The Feature Inventory

**Files:**
- Create: `docs/architecture/FEATURE_ARCHITECTURE_AUDIT.md`
- Read: `lib/features/**`
- Read: `lib/core/**`

- [ ] Create `docs/architecture/FEATURE_ARCHITECTURE_AUDIT.md`.
- [ ] Add a table with columns: `Feature`, `Folders Present`, `Main Entry Points`, `State/Providers`, `Repositories`, `Known Risks`, `Audit Status`.
- [ ] Use `rg --files lib/features lib/core` to list feature files.
- [ ] Fill each feature row with facts only. Do not propose refactors in this task.
- [ ] Run `dart format lib test` only if code files were touched. This task should normally touch docs only.

## Task 2: Check Dependency Direction

**Files:**
- Modify: `docs/architecture/FEATURE_ARCHITECTURE_AUDIT.md`
- Read: all imports under `lib/features/**`

- [ ] For each feature, inspect imports with:

```bash
rg -n "^import " lib/features/<feature-path>
```

- [ ] Mark any presentation file importing a concrete data repository directly.
- [ ] Mark any domain file importing Flutter widgets, Firebase, routing, or presentation files.
- [ ] Mark any data file importing presentation files.
- [ ] Add a `Dependency Direction Findings` section with one bullet per violation.
- [ ] If no violation exists for a feature, write `No dependency direction issue found in sampled imports.`

## Task 3: Audit Design-System Usage By Feature

**Files:**
- Modify: `docs/architecture/FEATURE_ARCHITECTURE_AUDIT.md`
- Read: `test/design_system/no_raw_design_values_test.dart`
- Read: `lib/features/**`

- [ ] Run:

```bash
flutter test test/design_system/no_raw_design_values_test.dart
```

- [ ] Record the result in the audit doc.
- [ ] Search for token bypasses that the guard intentionally allows, such as `Colors.white`, `Colors.black`, raw `EdgeInsets`, raw `BorderRadius`, raw `Duration`, and raw `IconData` maps.
- [ ] Classify each bypass as one of: acceptable Flutter primitive, should become spacing/radius/motion token, should become feature semantic helper.
- [ ] Add a `Design-System Usage Findings` section.

## Task 4: Audit Routing And Provider Ownership

**Files:**
- Modify: `docs/architecture/FEATURE_ARCHITECTURE_AUDIT.md`
- Read: `lib/core/routing/app_router.dart`
- Read: `lib/core/providers/core_providers.dart`
- Read: feature controllers/providers under `lib/features/**/presentation/controllers`

- [ ] List all routes and the feature/screen they point to.
- [ ] Flag routes that instantiate dependencies manually instead of using providers.
- [ ] List global providers in `core_providers.dart` and classify them as app-wide, auth-wide, customer-only, or mechanic-only.
- [ ] Flag providers that should move closer to a feature because they are not cross-feature.
- [ ] Add a `Routing And Provider Findings` section.

## Task 5: Audit Repository And Service Boundaries

**Files:**
- Modify: `docs/architecture/FEATURE_ARCHITECTURE_AUDIT.md`
- Read: `lib/features/**/data/repositories/*.dart`
- Read: `lib/features/**/domain/repositories/*.dart`
- Read: `lib/core/services/*.dart`

- [ ] For each domain repository interface, list its concrete implementation.
- [ ] Flag concrete repositories without matching domain interfaces.
- [ ] Flag duplicated Firebase/Firestore access patterns that could become a shared core helper.
- [ ] Flag core services that are actually feature-specific.
- [ ] Add a `Data And Service Boundary Findings` section.

## Task 6: Identify Large-File Refactor Candidates

**Files:**
- Modify: `docs/architecture/FEATURE_ARCHITECTURE_AUDIT.md`

- [ ] Run:

```bash
wc -l $(rg --files lib/features lib/core | rg "\.dart$")
```

- [ ] List files over 500 lines.
- [ ] For each large file, classify it as: acceptable coordinator, should split widgets, should split controller logic, should split data helpers.
- [ ] Do not split files in this task.
- [ ] Add a `Large File Findings` section with exact split recommendations.

## Task 7: Define Feature Smoke Tests

**Files:**
- Modify: `docs/architecture/FEATURE_ARCHITECTURE_AUDIT.md`
- Future tests: `test/features/**`

- [ ] For each core flow, define one smoke test:
  - onboarding shell renders
  - customer login/signup shell renders
  - customer booking shell renders with theme
  - customer payment shell renders with theme
  - mechanic auth shell renders
  - mechanic dashboard shell renders with theme
  - mechanic chat shell renders with theme
- [ ] For each test, document required mocks or fake repositories.
- [ ] Add a `Feature Smoke Test Plan` section.

## Task 8: Produce The Phase 3 Refactor Backlog

**Files:**
- Create: `docs/architecture/FEATURE_ARCHITECTURE_REFACTOR_BACKLOG.md`
- Read: `docs/architecture/FEATURE_ARCHITECTURE_AUDIT.md`

- [ ] Convert audit findings into prioritized backlog items.
- [ ] Use priority labels:
  - `P0`: bug or architecture violation that can cause runtime failure
  - `P1`: makes analyzer/test cleanup harder
  - `P2`: maintainability improvement
  - `P3`: cosmetic or optional cleanup
- [ ] Each backlog item must include exact files, expected tests, and risk.
- [ ] Do not include vague items like "clean up booking". Name the exact boundary to fix.

## Task 9: Final Verification

- [ ] Run:

```bash
flutter test
```

- [ ] Run:

```bash
flutter analyze
```

- [ ] If analyzer still fails, record the exact count and top categories in `docs/architecture/FEATURE_ARCHITECTURE_AUDIT.md`.
- [ ] Run:

```bash
dart analyze --format machine
```

- [ ] Confirm whether any `ERROR` diagnostics exist.

## Deliverables

The phase is complete when these files exist and are internally consistent:

- `docs/architecture/FEATURE_ARCHITECTURE_AUDIT.md`
- `docs/architecture/FEATURE_ARCHITECTURE_REFACTOR_BACKLOG.md`

The audit should be factual enough that the next implementation phase can fix one feature boundary at a time without guessing.

