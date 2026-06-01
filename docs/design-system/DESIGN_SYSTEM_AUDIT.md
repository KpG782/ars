# ARS Design System Audit

**Date:** 2026-06-01  
**Branch audited:** `local/feat-clean-with-updates` based on `origin/feat/clean`  
**Source of truth:** `lib/core/theme/app_theme.dart`  
**Companions:** [Token Proposal](./DESIGN_SYSTEM_TOKENS.md) and [Implementation Plan](./DESIGN_SYSTEM_PLAN.md)

This audit covers ARS's current color system, typography, spacing, radius, motion, and shared components. It is intentionally written before code rollout so the design direction can be reviewed cleanly.

## 1. Research Baseline

The audit uses these external baselines:

- WCAG 2.2 requires at least `4.5:1` contrast for normal text and `3:1` for large text, with non-text UI components needing `3:1` where visual boundaries matter: <https://www.w3.org/TR/WCAG22/> and <https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast>
- Flutter Material `ColorScheme` is the correct app-wide role surface for `primary`, `secondary`, `tertiary`, `error`, `surface`, and `on*` foregrounds: <https://api.flutter.dev/flutter/material/ColorScheme-class.html>
- Flutter has expanded Material 3 color roles around tone-based surfaces and accent groups, so ARS should not rely only on raw `primaryColor` constants: <https://docs.flutter.dev/release/breaking-changes/new-color-scheme-roles>
- FHWA/MUTCD road-sign conventions support orange for temporary traffic/control contexts, blue for services/guidance, green for guide/directional meaning, and red for stop/prohibition/critical action contexts: <https://mutcd.fhwa.dot.gov/index.htm> and <https://highways.dot.gov/safety/local-rural/maintenance-signs-and-sign-supports/ii-sign-principles-and-types>
- The external research verdict recommends an asphalt-first foundation, orange for routine service action, red only for SOS/destructive action, teal as trust/support, blue for map/info, and green for success.

## 2. Current Token Inventory

Current tokens in `app_theme.dart`:

| Token | Hex | OKLCH | Contrast vs white | Contrast vs black | Status |
|---|---:|---:|---:|---:|---|
| `primaryColor` | `#3DB3A9` | `oklch(69.9% 0.105 187)` | 2.55 | 8.22 | Fails white CTA text |
| `primaryLight` | `#6DCCC4` | `oklch(78.5% 0.091 188)` | 1.89 | 11.08 | Background/accent only |
| `primaryDark` | `#2A8A82` | `oklch(57.7% 0.088 187)` | 4.15 | 5.06 | Fails normal white text, passes large only |
| `primarySurface` | `#E8F6F5` | `oklch(96.2% 0.015 192)` | 1.11 | 18.93 | Good tinted background |
| `secondaryColor` | `#2D2D3A` | `oklch(30.3% 0.023 285)` | 13.57 | 1.55 | Good dark neutral |
| `accentYellow` | `#F5C842` | `oklch(85.0% 0.153 90)` | 1.59 | 13.22 | Warning/rating only |
| `surfaceColor` | `#FAFAFA` | `oklch(98.5% 0.000 90)` | 1.04 | 20.12 | Good app background |
| `cardColor` | `#FFFFFF` | `oklch(100.0% 0.000 90)` | 1.00 | 21.00 | Good card surface |
| `onSurfaceColor` | `#1A1A2E` | `oklch(22.8% 0.038 283)` | 17.06 | 1.23 | Good primary text |
| `subtitleColor` | `#6B7280` | `oklch(55.1% 0.023 264)` | 4.83 | 4.34 | Passes on white/surface |
| `borderColor` | `#E5E7EB` | `oklch(92.8% 0.006 265)` | 1.24 | 16.96 | Too subtle for control outlines |
| `errorColor` | `#EF4444` | `oklch(63.7% 0.208 25)` | 3.76 | 5.58 | White text fails normal CTA text |
| `successColor` | `#22C55E` | `oklch(72.3% 0.192 150)` | 2.28 | 9.22 | Functional, not CTA-safe with white |

Most-used hard-coded colors in `lib/`:

| Count | Value | Meaning today |
|---:|---|---|
| 377 | `Colors.white` | surfaces, text, icons, buttons |
| 118 | `#00BFA5` | legacy teal CTA/brand |
| 104 | `Colors.red` | errors/destructive/emergency |
| 84 | `Colors.grey[600]` | secondary text |
| 77 | `Colors.grey` | general disabled/muted |
| 73 | `Colors.grey[300]` | borders/dividers |
| 47 | `Colors.green` | success/mechanic state |
| 35 | `Colors.orange` | warning/ETA/payment |
| 23 | `#F59E0B` | amber warning/rating |
| 18 | `#4CAF50` | Material green |
| 13 | `#2196F3` | Material blue |

## 3. Color Findings

### C1. Current primary teal fails CTA foreground contrast (P0)

`primaryColor #3DB3A9` with white foreground is `2.55:1`, below WCAG AA for normal text. `CustomButton` and `ElevatedButtonTheme` both default to white foreground on the primary color.

Impact: primary actions can be visually attractive but fail accessibility and readability.

### C2. The brand color is not category-specific enough (P1)

Teal reads as clean, trust-oriented, and health/consumer-tech friendly, but it has weak roadside/automotive meaning. For ARS, the more category-relevant palette is:

- asphalt/slate for roads, reliability, and premium app structure
- red for urgent roadside/SOS action
- orange for repair, caution, ETA, and service-state emphasis
- blue for map/info/service guidance
- green for success/mechanic availability only

External review correction: red should not become the everyday primary CTA. Red should stay reserved for emergency/SOS and destructive contexts. Orange is the better default action color for repair/booking because it connects to work-zone/service semantics without making normal flows feel like error states.

### C3. Current code has multiple brand systems (P1)

The style guide says `#3DB3A9`, current hard-coded screens still use `#00BFA5`, mechanic screens use `#119E5A`, and semantic colors use Material `Colors.*` values. The result is not one palette; it is a set of accumulated local choices.

### C4. Borders are visually too soft for form/control state (P2)

`borderColor #E5E7EB` is acceptable as decorative card chrome, but it is very light. For input boundaries and selected states, ARS needs a stronger `outline` token around slate-300/400 and a distinct `focus` token.

### C5. Semantics are partially present but not named (P2)

The app already uses red, orange, green, blue, amber, but they are not centralized as `danger`, `warning`, `success`, `info`, `rating`, `route`, or `emergency`. This makes consistency impossible across customer and mechanic flows.

## 4. Typography Audit

Current theme direction:

- Theme text styles are Figtree via `google_fonts`.
- `pubspec.yaml` still declares local CabinetGrotesk, Chillax, and Satoshi font assets.
- Feature code uses direct `GoogleFonts.figtree` in shared widgets and loading screens.
- Previous `GeneralSans` drift appears resolved on this branch.

Current theme scale:

| Role | Size | Weight | Notes |
|---|---:|---:|---|
| `splashScreenTitle` | 48 | 900 | brand/splash |
| `headlineLarge` | 36 | 800 | display/screen heading |
| `headlineMedium` | 32 | 700 | large heading |
| `headlineSmall` | 24 | 700 | section heading |
| `titleMedium` | 20 | 700 | card/section title |
| `bodyLarge` | 18 | 400 | body |
| `bodyMedium` | 16 | 400 | body |
| `bodySmall` | 14 | 400 | caption/body small |
| `buttonLarge` | 18 | 600 | CTA |
| `buttonMedium` | 16 | 600 | CTA |
| `labelMedium` | 14 | 500 | fields/tags |

Hard-coded `fontSize` values still found in `lib/`:

`10, 11, 11.5, 12, 13, 13.5, 14, 15, 15.5, 16, 17, 18, 20, 22, 24, 26, 28, 32, 36, 40, 48, 56`

### T1. Figtree is a good app font, but the scale is not enforced (P1)

Figtree is a strong choice for a modern service app: readable, neutral, and less decorative than the previous mixed font setup. The problem is not the font, it is the absence of enforced role usage.

### T2. The small end is crowded (P2)

The app uses many adjacent sizes from 10 to 18. That produces inconsistent hierarchy and increases text fitting risk.

### T3. Line-height is implicit in many local styles (P2)

Theme styles do not consistently set `height`. Body text should standardize around `1.45-1.55`; headings should explicitly use tighter line-height around `1.1-1.25`.

### T4. Unused font assets should be decided, not left ambiguous (P3)

CabinetGrotesk, Chillax, and Satoshi are still declared. If Figtree is the final direction, remove local font assets later or reserve one for logo-only usage.

## 5. Spacing, Radius, and Motion Audit

Most-used spacing/radius values:

| Count | Value |
|---:|---|
| 198 | `16` |
| 197 | `12` |
| 186 | `8` |
| 142 | `BorderRadius.circular(12)` |
| 86 | `4` |
| 69 | `BorderRadius.circular(16)` |
| 68 | `24` |
| 64 | `EdgeInsets.all(16)` |
| 48 | `EdgeInsets.all(20)` |
| 47 | `20` |
| 43 | `BorderRadius.circular(8)` |
| 22 | `BorderRadius.circular(28)` |

### S1. The app mostly follows a 4pt grid, but it is implicit (P2)

The common values are reasonable: `4, 8, 12, 16, 20, 24, 32`. They need names and usage rules.

### S2. Radius scale is too broad (P2)

Common radii are `8, 12, 14, 16, 20, 24, 28, 30`. For a work-focused mobile app, this should collapse into:

- `sm 8` for chips and small controls
- `md 12` for inputs and compact cards
- `lg 16` for cards/sheets
- `pill 999` for pill CTAs

### S3. Motion exists locally but not as a system (P3)

Animation durations appear in splash/loading/route flows, but there is no central motion token file. Use `150ms`, `250ms`, `400ms` with `easeOutCubic`, and respect reduced-motion where practical.

## 6. Component Audit

### Shared `CustomButton`

Current behavior:

- height `54`
- radius `28`
- default background from `theme.colorScheme.primary`
- default foreground `Colors.white`
- Figtree 16/600
- optional leading/trailing icons

Issue: if `primary` remains teal, default foreground fails contrast. If primary moves to orange `#F97316`, the foreground must become dark asphalt/black, not white. Red `#DC2626` should be used by an explicit emergency/destructive variant with white foreground.

### Shared `CustomTextField`

Current behavior:

- label above field
- radius `14`
- Figtree label/body
- white fill
- focus border from primary

Issue: input radius and border should come from tokens. Focus should not depend on a low-contrast teal if action color changes.

### Theme

Current behavior:

- Material 3 enabled
- `ColorScheme` is present but minimal
- component themes exist for buttons, cards, inputs, text buttons

Issue: no primitive/token layer. Every value lives directly in `AppTheme`, so app-level and component-level naming are mixed together.

## 7. Priority Findings

| Priority | Finding | Fix |
|---|---|---|
| P0 | White text on teal primary fails contrast | Use orange primary with dark text, and red SOS with white text |
| P1 | Brand is not roadside-specific enough | Adopt asphalt + service orange + SOS red role model |
| P1 | Hard-coded color usage bypasses theme | Introduce `AppColors`, migrate shared widgets first |
| P1 | Token source of truth is only `AppTheme` | Split primitives/semantic tokens from `ThemeData` wiring |
| P2 | Type roles not enforced | Add `AppTypography` and remove hard-coded font sizes over time |
| P2 | Spacing/radius values are implicit | Add `AppSpacing` and `AppRadii` |
| P2 | Semantic colors are unnamed | Add `danger`, `warning`, `success`, `info`, `emergency`, `rating` |
| P3 | Unused local font assets remain | Decide Figtree-only vs logo/display font usage |

## 8. Branding Verdict

Current teal is usable as a support/trust accent, but it should not be the primary roadside action color. It is not contrast-safe with white and does not communicate repair/roadside action strongly enough.

Recommended ARS brand architecture:

- **Foundation:** asphalt/slate neutrals for road, reliability, and interface maturity.
- **Primary routine action:** service orange `#F97316` with asphalt text.
- **Emergency action:** rescue red `#DC2626` with white text.
- **Trust/support accent:** retain teal `#3DB3A9` for calm support moments, not primary CTAs.
- **Success:** green only for verified/completed/available states.
- **Info/map:** blue for routes, ETA info, and system notices.

This keeps ARS category-relevant without making every screen feel like an error state.

If the product is renamed to **Andar**, this color architecture still holds. The name adds a positive "get moving" cue, while the design system separates everyday motion (`orange`) from true emergency (`red`).
