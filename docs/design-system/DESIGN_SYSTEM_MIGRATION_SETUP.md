# ARS Design System Migration Setup

**Date:** 2026-06-01  
**Status:** Setup plan only; do this before app-wide visual migration  
**Decision:** External research accepted with one clear architecture: orange routine action, red SOS/destructive.

## 1. Is This Setup Worth It?

Yes, the migration is worth doing, but only if it is staged. The current app has enough style drift that a direct screen-by-screen repaint would create more inconsistency. The right first move is to install the token layer, add contrast tests, and migrate only shared widgets before touching major flows.

Why it is worth it:

- The current primary teal `#3DB3A9` with white text fails WCAG AA at about `2.55:1`.
- The app has multiple active brand colors: `#3DB3A9`, `#00BFA5`, red, green, orange, blue, and many greys.
- ARS has two product modes: routine booking and emergency SOS. One CTA color cannot express both well.
- Orange for normal service and red for SOS gives the app clear information architecture.
- A token layer lets future rename/brand work, including **Andar**, happen without restyling every screen manually.

Do not migrate every screen first. Build the system first.

## 2. Target Migration Architecture

Create a token layer under `lib/core/theme/`:

- `app_colors.dart` - primitive and semantic color tokens.
- `app_typography.dart` - Figtree text roles and numeric/text rules.
- `app_spacing.dart` - 8dp grid spacing tokens.
- `app_radii.dart` - radius tokens.
- `app_motion.dart` - duration and curve tokens.
- `app_theme.dart` - Material 3 `ThemeData` composition only.

Keep `AppTheme` backwards-compatible during migration so existing screens do not break immediately.

## 3. Color Decisions To Lock

| Purpose | Token | Hex | Foreground | Notes |
|---|---|---:|---:|---|
| Routine CTA | `primary` | `#F97316` | `#0F172A` | booking, confirm, continue |
| SOS/destructive | `emergency` / `danger` | `#DC2626` | `#FFFFFF` | SOS, delete, cancel job |
| Trust/support | `trust` | `#3DB3A9` | `#0F172A` | support, non-critical highlights |
| Map/info | `info` | `#3B82F6` | `#0F172A` | routes, ETA, links |
| Success | `success` | `#16A34A` | `#0F172A` | completed, verified, available |
| Warning/rating | `warning` / `rating` | `#F59E0B` | `#0F172A` | pending, caution, stars |
| Text/foundation | `text1` | `#0F172A` | n/a | asphalt primary text |
| Surface | `surface` | `#FFFFFF` | `#0F172A` | cards, sheets, inputs |

Rules:

- Never use white normal text on orange, teal, blue, green, or amber.
- Use white normal text on red only.
- Do not use red for normal booking or continue buttons.
- Do not use green as a CTA.

## 4. Flutter Material 3 Mapping

Map `ColorScheme` like this:

| Role | Token |
|---|---|
| `primary` | `primary #F97316` |
| `onPrimary` | `text1 #0F172A` |
| `primaryContainer` | `primaryBg #FFF7ED` |
| `onPrimaryContainer` | `primaryTx #9A3412` |
| `secondary` | `trust #3DB3A9` |
| `onSecondary` | `text1 #0F172A` |
| `tertiary` | `info #3B82F6` |
| `onTertiary` | `text1 #0F172A` |
| `error` | `emergency #DC2626` |
| `onError` | `#FFFFFF` |
| `surface` | `surface #FFFFFF` |
| `onSurface` | `text1 #0F172A` |
| `outline` | `border #CBD5E1` |
| `outlineVariant` | `borderStrong #94A3B8` |

Add custom extension tokens for:

- `emergency`
- `onEmergency`
- `success`
- `warning`
- `info`
- `rating`
- tinted bg/text pairs

## 5. First Implementation Slice

The first code migration should touch only:

- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_typography.dart`
- `lib/core/theme/app_spacing.dart`
- `lib/core/theme/app_radii.dart`
- `lib/core/theme/app_motion.dart`
- `lib/core/theme/app_theme.dart`
- `lib/core/widgets/custom_button.dart`
- `lib/core/widgets/custom_text_field.dart`
- `lib/core/utils/toast_helper.dart`
- `test/design_system_test.dart`

Do not migrate feature screens in the first slice except where compilation requires it.

## 6. Test-First Setup

Before changing production theme code, add `test/design_system_test.dart` with:

- contrast helper for WCAG ratios
- orange primary + asphalt text contrast test
- red emergency + white text contrast test
- teal trust + asphalt text contrast test
- `ColorScheme.primary == AppColors.primary`
- `ColorScheme.error == AppColors.emergency`
- `CustomButton` default variant uses orange + asphalt text
- `CustomButton.emergency` or equivalent variant uses red + white text

Expected first run: fail because token files and button variants do not exist yet.

## 7. Migration Order After Setup Passes

After the token/shared-widget setup is green, migrate screens in this order:

1. Onboarding and splash: brand foundation and first impression.
2. Customer auth: forms, buttons, text fields.
3. Booking flow: routine orange CTA and service chips.
4. SOS/emergency surfaces: red-only urgency mode.
5. Map/ETA/tracking: blue info and route states.
6. Mechanic dashboard: success/availability states.
7. Payment and history: status chips, totals, tabular figures.
8. Support/settings: trust teal and neutral cards.

## 8. Guardrails

Add temporary migration checks:

```bash
rg "Color\\(0xFF00BFA5\\)|GeneralSans" lib
rg "Colors\\.(red|green|orange|blue|grey)" lib
rg "fontSize:" lib
```

These do not need to reach zero in the first slice. They must trend down and remaining hits must be intentional.

## 9. Acceptance Criteria For Setup

The setup is accepted when:

- Token files exist and compile.
- `AppTheme.themeData` maps to tokens.
- Primary routine CTA uses orange + asphalt text.
- Emergency/destructive CTA uses red + white text.
- Shared button and shared text field use spacing/radius/type tokens.
- Contrast tests pass for all token pairs.
- Existing app still builds after the shared widget migration.

