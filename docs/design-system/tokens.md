# Talyer Design Tokens

Single source of truth. Code lives in `lib/core/design/tokens/`. Never hardcode
a hex, size, or duration in a screen — reference a token.

## Colour

**Strategy:** trust-teal leads, orange energises, red is reserved for real
urgency, brass marks verification. All `on*` pairings meet WCAG AA for their use
(normal text ≥ 4.5:1; large/icon ≥ 3:1).

### Light

| Token | Hex | Use |
|---|---|---|
| `brand` | `#3DB3A9` | identity teal — logo, badges, decorative |
| `primary` | `#1F8079` | interactive fills; `onPrimary` = white (4.75:1) |
| `primaryPressed` | `#18655F` | pressed state |
| `primaryBg` / `primaryTx` | `#E8F6F5` / `#0F4B47` | tinted container + its text |
| `accent` | `#F97316` | energy / secondary CTA; `onAccent` = slate-900 |
| `emergency` | `#DC2626` | SOS / breakdown; `onEmergency` = white (4.9:1) |
| `verified` | `#B7892B` | brass seal; `verifiedBg` `#FBF1D9`, `verifiedTx` `#6B4F12` |
| `success` / `warning` / `info` | `#16A34A` / `#F59E0B` / `#3B82F6` | status |
| `rating` | `#F59E0B` | star amber |
| `background` / `surface` | `#F8FAFC` / `#FFFFFF` | app bg / cards |
| `text1` / `text2` / `text3` | `#0F172A` / `#475569` / `#64748B` | primary / secondary / tertiary |
| `border` / `borderStrong` | `#CBD5E1` / `#94A3B8` | dividers, outlines |

### Dark

Mirrors light with lifted tints: `background #0B1220`, `surface #111827`,
`primary #5EEAD4` (dark ink on it), `accent #FB923C`, `emergency #F87171`,
`verified #D9B65C`, text `#F8FAFC / #CBD5E1 / #94A3B8`.

Both sets are exposed as a `TalyerColors` `ThemeExtension` and mapped into the
Material `ColorScheme` (`primary→primary`, `accent→secondary`,
`verified→tertiary`, `emergency→error`).

## Typography — `TalyerType`

Display/headings **Space Grotesk**; body/UI **Inter** (both OFL via `google_fonts`).

| Style | Size / line | Weight |
|---|---|---|
| `displayLarge` | 40 / 48 | 700 |
| `displaySmall` | 32 / 40 | 700 |
| `headline` | 28 / 36 | 700 |
| `titleLarge` | 22 / 28 | 600 |
| `titleMedium` | 17 / 24 | 600 |
| `titleSmall` | 15 / 20 | 600 |
| `bodyLarge` | 16 / 24 | 400 |
| `bodyMedium` | 14 / 20 | 400 |
| `label` (buttons) | 15 / 20 | 600 |
| `caption` | 13 / 18 | 400 |
| `overline` | 11 / 16 | 700, +0.8 tracking |

Body never below 16px on mobile.

## Spacing — `TalyerSpacing` (4-pt)

`x1=4 · x2=8 · x3=12 · x4=16 (gutter) · x5=20 · x6=24 (screen) · x8=32 · x10=40 · x12=48 · x16=64`. `minTouch = 48`.

## Radius — `TalyerRadii`

`xs=8 · sm=12 · md=16 (cards) · lg=20 (sheets) · xl=28 (pill buttons) · pill=999`.

## Elevation — `TalyerElevation`

Soft, low-alpha shadows; borders + tint do most of the work. `card`, `sheet`,
`fab`. Dark mode drops card shadows (depth comes from surface steps).

## Motion — `TalyerMotion`

`instant 80 · fast 150 · base 200 · slow 300 · page 350`ms. Curves: `standard`
(easeOutCubic), `emphasized`. `respectReduceMotion(context, d)` returns
`Duration.zero` when the OS asks to reduce motion.
