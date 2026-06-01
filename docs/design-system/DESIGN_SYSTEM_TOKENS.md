# ARS Design System Token Proposal

**Date:** 2026-06-01  
**Status:** Proposed v1 tokens for review before code rollout  
**Companion:** [Design System Audit](./DESIGN_SYSTEM_AUDIT.md)

The proposed token system keeps ARS light-theme first, but moves from a teal-only brand to a roadside-specific palette.

## 1. Color Strategy

ARS should use a **role-based brand system**, not one accent everywhere:

- `primary` / `service`: orange, used for normal booking, confirm, and repair-service CTAs.
- `emergency`: red, used only for SOS, destructive, and true critical states.
- `trust`: teal, retained from the current brand for support and lower-pressure trust moments.
- `neutral`: asphalt/slate, used for structure, text, cards, dividers, and dark sections.
- `semantic`: success, warning, info, danger, rating.

## 2. Neutral Tokens

| Token | Hex | Role |
|---|---:|---|
| `background` | `#F8F9FA` | app scaffold |
| `surface` | `#FFFFFF` | cards, sheets, fields |
| `surfaceMuted` | `#F1F5F9` | subtle panels |
| `surfaceRaised` | `#E2E8F0` | selected muted surfaces |
| `border` | `#CBD5E1` | input/card border |
| `borderStrong` | `#94A3B8` | selected/active boundary |
| `text1` | `#0F172A` | primary text / asphalt text |
| `text2` | `#475569` | secondary text |
| `text3` | `#64748B` | tertiary text |
| `inverseSurface` | `#1E293B` | dark section/sheet |
| `onInverseSurface` | `#F8FAFC` | text on dark section |

## 3. Brand and Action Tokens

| Token | Hex | Foreground | Role |
|---|---:|---:|---|
| `primary` | `#F97316` | `#0F172A` | normal booking/confirm/service CTA |
| `primaryPressed` | `#EA580C` | `#0F172A` | pressed routine CTA |
| `primaryBg` | `#FFF7ED` | `#9A3412` | orange tinted chip/banner |
| `emergency` | `#DC2626` | `#FFFFFF` | SOS/destructive/critical CTA |
| `emergencyPressed` | `#B91C1C` | `#FFFFFF` | pressed SOS/destructive CTA |
| `emergencyBg` | `#FEE2E2` | `#991B1B` | red tinted chip/banner |
| `trust` | `#3DB3A9` | `#0F172A` | retained teal support/trust accent |
| `trustDark` | `#2A8A82` | `#FFFFFF` for large text only | dark teal accent |
| `trustBg` | `#E8F6F5` | `#2A8A82` | teal tinted background |
| `info` | `#3B82F6` | `#0F172A` | map, route, ETA, neutral info accent |
| `infoBg` | `#DBEAFE` | `#1D4ED8` | blue tinted chip/banner |

Important rule: do not use white normal text on `primary #F97316`, `trust #3DB3A9`, `info #3B82F6`, `warning #F59E0B`, or `success #16A34A`. Use dark asphalt text on those colors. Use white on `emergency #DC2626`.

## 4. Semantic Tokens

| Token | Hex | Tinted bg | Tinted text | Usage |
|---|---:|---:|---:|---|
| `success` | `#16A34A` | `#DCFCE7` | `#166534` | completed, verified, mechanic available |
| `info` | `#3B82F6` | `#DBEAFE` | `#1D4ED8` | route, ETA, neutral system info |
| `warning` | `#F59E0B` | `#FEF3C7` | `#92400E` | pending, caution, payment waiting |
| `danger` | `#DC2626` | `#FEE2E2` | `#991B1B` | destructive, failed, emergency |
| `rating` | `#F59E0B` | `#FFFBEB` | `#B45309` | stars and review rating only |

## 5. Flutter Role Mapping

Map tokens into `ColorScheme` like this:

| Flutter role | Token |
|---|---|
| `primary` | `primary` / orange |
| `onPrimary` | `onPrimary` / asphalt |
| `primaryContainer` | `primaryBg` |
| `onPrimaryContainer` | `primaryTx` |
| `secondary` | `trust` / teal |
| `onSecondary` | `onTrust` / asphalt |
| `tertiary` | `info` / blue |
| `onTertiary` | `onInfo` / asphalt |
| `error` | `emergency` / red |
| `onError` | `#FFFFFF` |
| `surface` | `surface` |
| `onSurface` | `text1` |
| `outline` | `border` |
| `outlineVariant` | `borderStrong` |

## 6. Typography Tokens

Recommended v1: keep **Figtree** as the main UI font. It is readable, modern, and already wired through `google_fonts`.

| Token | Font | Size | Weight | Line height | Usage |
|---|---|---:|---:|---:|---|
| `displayLarge` | Figtree | 57 | 400 | 64px | rare hero/stat display |
| `headlineLarge` | Figtree | 32 | 600 | 40px | app titles, SOS banners |
| `headlineMedium` | Figtree | 28 | 600 | 36px | section headers |
| `headlineSmall` | Figtree | 24 | 600 | 32px | feature headings |
| `titleLarge` | Figtree | 22 | 500 | 28px | screen titles/menus |
| `titleMedium` | Figtree | 16 | 500 | 24px | form labels, field titles |
| `titleSmall` | Figtree | 14 | 500 | 20px | card labels, button-adjacent text |
| `bodyLarge` | Figtree | 16 | 400 | 24px | main body |
| `bodyMedium` | Figtree | 14 | 400 | 20px | secondary body |
| `bodySmall` | Figtree | 12 | 400 | 18px | captions, disclaimers |
| `labelLarge` | Figtree | 14 | 600 | 18px | buttons, ETA emphasis |
| `labelMedium` | Figtree | 12 | 600 | 16px | metadata, distance, price |
| `labelSmall` | Figtree | 11 | 600 | 16px | tiny labels |

Rules:

- Use theme roles first, not raw `TextStyle(fontSize: ...)`.
- Keep 10px text out of production UI unless it is decorative and non-essential.
- Use tabular figures later for currency, ETA, distances, and counts if Figtree supports it cleanly.

## 7. Spacing Tokens

| Token | Value | Usage |
|---|---:|---|
| `none` | 0 | reset |
| `xs` | 4 | tight icon/text spacing |
| `sm` | 8 | compact gap |
| `md` | 16 | default screen/card gap |
| `lg` | 24 | section gap |
| `xl` | 32 | large section gap |
| `xxl` | 40 | major vertical section |

Use only these values for new UI unless a component has a fixed physical requirement.

## 8. Radius Tokens

| Token | Value | Usage |
|---|---:|---|
| `sm` | 4 | badges, handles, tiny chips |
| `md` | 8 | inputs, cards, common controls |
| `lg` | 16 | dialogs, bottom sheets, large panels |
| `xl` | 24 | immersive sheets only |
| `pill` | 999 | pill buttons/chips |

## 9. Motion Tokens

| Token | Value | Usage |
|---|---:|---|
| `fast` | 150ms | hover/tap state |
| `medium` | 250ms | panel transition |
| `slow` | 400ms | page/hero transition |
| `curveStandard` | `Curves.easeOutCubic` | default |
| `curveEmphasized` | `Curves.easeInOutCubic` | route/page transitions |

## 10. Token File Shape

Recommended code files after review:

- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_typography.dart`
- `lib/core/theme/app_spacing.dart`
- `lib/core/theme/app_radii.dart`
- `lib/core/theme/app_motion.dart`
- `lib/core/theme/app_theme.dart`

`AppTheme` should compose tokens into Flutter `ThemeData`. It should not be the primitive token store.
