# ARS Application — Style Guide

> **Design Language**: Google Stitch-inspired, modern & clean
> **Primary Brand Color**: `#3DB3A9` (Teal)
> **Font**: [Figtree](https://fonts.google.com/specimen/Figtree) via `google_fonts` package

---

## Color Palette

| Token | Hex | Usage |
|---|---|---|
| `primaryColor` | `#3DB3A9` | Buttons, links, hero sections, icons |
| `primaryLight` | `#6DCCC4` | Hover states, subtle accents |
| `primaryDark` | `#2A8A82` | Pressed states, darker accents |
| `primarySurface` | `#E8F6F5` | Light tinted backgrounds, card highlights |
| `secondaryColor` | `#2D2D3A` | Dark text, secondary elements |
| `accentYellow` | `#F5C842` | Star ratings, warnings, badges |
| `surfaceColor` | `#FAFAFA` | Page backgrounds |
| `cardColor` | `#FFFFFF` | Card & sheet backgrounds |
| `onSurfaceColor` | `#1A1A2E` | Primary text (headings, titles) |
| `subtitleColor` | `#6B7280` | Secondary text, hints, captions |
| `borderColor` | `#E5E7EB` | Card borders, dividers, input borders |
| `errorColor` | `#EF4444` | Errors, destructive actions |
| `successColor` | `#22C55E` | Success states, verified badges |

---

## Typography

All text uses **Figtree** from Google Fonts. Never use `CabinetGrotesk`, `GeneralSans`, or system defaults.

| Style Name | Weight | Usage Examples |
|---|---|---|
| `figtreeRegular` | 400 | Body text, descriptions, hints |
| `figtreeMedium` | 500 | Labels, captions, secondary buttons |
| `figtreeSemiBold` | 600 | Button text, links, active labels |
| `figtreeBold` | 700 | Section titles, app bar titles |
| `figtreeExtraBold` | 800 | Screen headings, hero titles |
| `figtreeBlack` | 900 | Splash logo text |

### Usage Pattern
```dart
AppTheme.figtreeExtraBold.copyWith(fontSize: 28, color: AppTheme.onSurfaceColor)
AppTheme.figtreeRegular.copyWith(fontSize: 14, color: AppTheme.subtitleColor)
```

---

## Component Patterns

### Buttons
- **Shape**: Pill (`borderRadius: 28`)
- **Primary**: Solid `primaryColor` bg, white text, `CustomButton`
- **Outlined**: `primaryColor` border, transparent bg, `CustomButton(isOutlined: true)`
- **Trailing arrow**: Use `trailingIcon: LucideIcons.arrow_right` for CTAs
- **Disabled**: `primaryColor.withAlpha(100)`

### Text Fields
- **Widget**: `CustomTextField` with separated label above
- **Borders**: Rounded 14px, `borderColor` default, `primaryColor` on focus
- **Fill**: White
- **Prefix icons**: Colored with `AppTheme.primaryColor`, size 20

### Cards
- **Corners**: 16px radius
- **Border**: 1px `borderColor`
- **Elevation**: 0 (flat design)
- **Selection state**: `primarySurface` bg + 2px `primaryColor` border + radio dot

### Hero Sections (Auth Screens)
- Full-width `primaryColor` background
- Rounded bottom corners (`borderRadius: bottomLeft: 32, bottomRight: 32`)
- White bold headline + semi-transparent white subtitle
- Back button with white chevron

### Bottom Sheets / Panels
- White background with top rounded corners (24px)
- Shadow: subtle `Colors.black.withAlpha(10)` spread
- Drag handle: 40w × 4h centered bar in `borderColor`

### App Bars
- Background: white or `surfaceColor`
- Elevation: 0
- Title: `figtreeBold`, 18–20px, `onSurfaceColor`
- Back icon: `LucideIcons.chevron_left`, `onSurfaceColor`

### Status Badges / Chips
- Rounded pill shape (radius 20)
- Light tinted background (e.g. `primarySurface`, `successColor.withAlpha(30)`)
- SemiBold text in matching full color

### Page Indicators (Onboarding)
- Active: 24w × 8h pill, `primaryColor`
- Inactive: 8w × 8h circle, `borderColor`

### Notifications / Toast
- Use `ToastHelper` (existing utility) for feedback
- Success: green, Error: red, Info: blue

---

## Icon Library

Use **flutter_lucide** (`LucideIcons.xxx`) exclusively. Do not mix with Material Icons.

Common icons:
- Navigation: `chevron_left`, `chevron_right`, `arrow_right`, `x`
- Auth: `mail`, `lock`, `user`, `phone`, `at_sign`
- Features: `wrench`, `car`, `map_pin`, `wallet`, `badge_check`
- Status: `check_circle`, `triangle_alert`, `info`, `clock`
- Actions: `search`, `plus`, `edit`, `trash_2`

---

## Logo

- SVG: `assets/ars_logo.svg` (for splash, colorable)
- PNG: `assets/ars_logo.png` (for cards, avatars)
- Color filter: `ColorFilter.mode(AppTheme.primaryColor, BlendMode.srcIn)`

---

## Key Principles

1. **Use `AppTheme.*` constants** — never hard-code colors or font styles
2. **Flat design** — shadows are minimal (`elevation: 0` on most components)
3. **White backgrounds** — screens default to `Colors.white`, surfaces to `#FAFAFA`
4. **Generous spacing** — 24px horizontal padding on pages, 16–20px between sections
5. **Rounded everything** — buttons 28px, inputs 14px, cards 16px, hero sections 32px
6. **go_router navigation** — use `context.go(AppRoutes.xxx)` and `context.push(...)`
7. **Repository pattern** — auth uses `AuthRepository` / `FirebaseAuthRepository`
8. **ToastHelper** — for user-facing feedback, not `ScaffoldMessenger`
