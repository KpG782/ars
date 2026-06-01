# ARS Light and Dark Mode Setup Plan

**Date:** 2026-06-01  
**Status:** Planning document for theme-mode rollout  
**Decision:** Build light and dark from the same semantic tokens. Do not create two unrelated palettes.

## 1. Mode Strategy

ARS should support both light and dark mode, but the implementation should start with a **complete light theme** and a **token-ready dark theme**. The first migration slice should wire both `ThemeData` objects even if the app initially defaults to system mode or light mode.

Recommended behavior:

- `themeMode: ThemeMode.system` after both themes pass contrast checks.
- During migration, optionally force `ThemeMode.light` until the first dark-mode pass is visually reviewed.
- Keep mode-specific values in token objects, not scattered through screens.
- Never branch inside feature widgets with `if (isDark)` unless a visual asset truly needs a separate file.

## 2. Architecture

Create one semantic token class per mode and one resolver:

```dart
enum AppThemeMode { light, dark }

abstract final class AppColors {
  static const light = AppColorTokens(...);
  static const dark = AppColorTokens(...);
}

class AppColorTokens {
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceRaised;
  final Color text1;
  final Color text2;
  final Color text3;
  final Color border;
  final Color borderStrong;
  final Color primary;
  final Color onPrimary;
  final Color emergency;
  final Color onEmergency;
  final Color trust;
  final Color onTrust;
  final Color info;
  final Color onInfo;
  final Color success;
  final Color warning;
  final Color danger;
}
```

`AppTheme` should expose:

```dart
static ThemeData get lightTheme;
static ThemeData get darkTheme;
static ThemeData themeFor(AppColorTokens colors);
```

`MaterialApp` should eventually use:

```dart
theme: AppTheme.lightTheme,
darkTheme: AppTheme.darkTheme,
themeMode: ThemeMode.system,
```

## 3. Light Theme Tokens

| Token | Hex | Usage |
|---|---:|---|
| `background` | `#F8F9FA` | app scaffold |
| `surface` | `#FFFFFF` | cards, sheets, inputs |
| `surfaceMuted` | `#F1F5F9` | subtle panels |
| `surfaceRaised` | `#E2E8F0` | selected muted surfaces |
| `text1` | `#0F172A` | primary text |
| `text2` | `#475569` | secondary text |
| `text3` | `#64748B` | tertiary text |
| `border` | `#CBD5E1` | standard outline |
| `borderStrong` | `#94A3B8` | active/selected outline |
| `primary` | `#F97316` | normal booking/service CTA |
| `onPrimary` | `#0F172A` | text on orange |
| `emergency` | `#DC2626` | SOS/destructive CTA |
| `onEmergency` | `#FFFFFF` | text on red |
| `trust` | `#3DB3A9` | trust/support accent |
| `onTrust` | `#0F172A` | text on teal |
| `info` | `#3B82F6` | map/route/info accent |
| `onInfo` | `#0F172A` | text on blue |
| `success` | `#16A34A` | completed/verified/available |
| `warning` | `#F59E0B` | pending/caution/rating |
| `danger` | `#DC2626` | error/destructive |

## 4. Dark Theme Tokens

Dark mode should be asphalt-first, not pure black. Pure black makes map/card surfaces too harsh and weakens the automotive dashboard feel.

| Token | Hex | Usage |
|---|---:|---|
| `background` | `#0F172A` | app scaffold |
| `surface` | `#111827` | cards, sheets, inputs |
| `surfaceMuted` | `#1E293B` | subtle panels |
| `surfaceRaised` | `#334155` | selected/elevated surfaces |
| `text1` | `#F8FAFC` | primary text |
| `text2` | `#CBD5E1` | secondary text |
| `text3` | `#94A3B8` | tertiary text |
| `border` | `#475569` | standard outline |
| `borderStrong` | `#64748B` | active/selected outline |
| `primary` | `#FB923C` | normal booking/service CTA |
| `onPrimary` | `#0F172A` | text on orange |
| `emergency` | `#DC2626` | SOS/destructive CTA |
| `onEmergency` | `#FFFFFF` | text on red |
| `trust` | `#5EEAD4` | trust/support accent |
| `onTrust` | `#0F172A` | text on teal |
| `info` | `#60A5FA` | map/route/info accent |
| `onInfo` | `#0F172A` | text on blue |
| `success` | `#4ADE80` | completed/verified/available |
| `warning` | `#FBBF24` | pending/caution/rating |
| `danger` | `#DC2626` | error/destructive |

Dark-mode notes:

- Use brighter accent steps in dark mode because the surrounding surfaces are darker.
- Keep dark text on bright orange/teal/blue/green/amber accents.
- Use white text on emergency red.
- Avoid low-alpha white borders for controls; prefer explicit slate borders.

## 5. Material 3 Mapping Per Mode

Use the same role mapping in both modes. Only token values change.

| ColorScheme role | Token |
|---|---|
| `brightness` | mode-specific |
| `primary` | `primary` |
| `onPrimary` | `onPrimary` |
| `primaryContainer` | `primaryBg` |
| `onPrimaryContainer` | `primaryTx` |
| `secondary` | `trust` |
| `onSecondary` | `onTrust` |
| `tertiary` | `info` |
| `onTertiary` | `onInfo` |
| `error` | `danger` |
| `onError` | `onEmergency` |
| `surface` | `surface` |
| `onSurface` | `text1` |
| `outline` | `border` |
| `outlineVariant` | `borderStrong` |

Add custom extension values for `background`, `surfaceMuted`, `surfaceRaised`, `emergency`, `warning`, `success`, `rating`, and tinted pairs because Flutter `ColorScheme` does not cover all product semantics.

## 6. Component Rules

Buttons:

- Routine `CustomButton.primary`: orange + asphalt text in both modes.
- `CustomButton.emergency`: red + white text.
- `CustomButton.neutral`: surface/surfaceMuted + text1.
- `CustomButton.outlined`: transparent + current role color + explicit border.

Inputs:

- Light: white fill, slate border, orange focus.
- Dark: `surface` fill, slate border, orange focus.
- Error always red border with text message.

Cards and sheets:

- Light: `surface` with `border`.
- Dark: `surface` or `surfaceMuted` with `border`.
- Avoid nesting cards inside cards; dark mode makes nested surfaces muddy.

Map and tracking:

- Map itself may stay provider-default, but overlays must use mode tokens.
- ETA/status chips use semantic tinted pairs.
- Route info uses `info`; SOS overlay uses `emergency`.

## 7. Testing Requirements

Add tests for both modes:

- `light.primary` + `light.onPrimary` contrast >= `4.5:1`.
- `dark.primary` + `dark.onPrimary` contrast >= `4.5:1`.
- `light.emergency` + `light.onEmergency` contrast >= `4.5:1`.
- `dark.emergency` + `dark.onEmergency` contrast >= `4.5:1`.
- `text1`, `text2`, and `text3` pass intended surface contrast in each mode.
- `border` and `borderStrong` meet `3:1` where they identify controls.
- `ColorScheme.brightness` is correct for each theme.
- Shared widgets render with mode-appropriate colors.

Manual review:

- 375px mobile light/dark.
- 430px mobile light/dark.
- Text scaling at 1.3x and 2.0x.
- SOS flow in dark mode.
- Booking flow in dark mode.
- Map overlays in dark mode.

## 8. Rollout Plan

1. Add mode token objects and contrast tests.
2. Wire `AppTheme.lightTheme` and `AppTheme.darkTheme`.
3. Keep app on `ThemeMode.light` while shared widgets migrate.
4. Migrate shared widgets.
5. Review core flows in both modes.
6. Switch to `ThemeMode.system`.
7. Add a settings toggle only if product needs manual override.

## 9. Acceptance Criteria

- Both themes compile.
- Both themes pass contrast tests.
- Shared widgets render correctly in both modes.
- No feature screen directly checks brightness for normal token use.
- `MaterialApp` has `theme`, `darkTheme`, and a deliberate `themeMode`.
- Dark mode is visually reviewed before `ThemeMode.system` ships.
