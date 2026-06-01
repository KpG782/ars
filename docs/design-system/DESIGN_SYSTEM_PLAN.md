# ARS Design System Implementation Plan

**Date:** 2026-06-01  
**Status:** Ready for review before implementation  
**Goal:** Move ARS from scattered local styling to a tokenized, accessible, roadside-specific design system.

## 1. Scope

This plan covers:

- color tokenization
- typography roles
- spacing/radius/motion tokens
- shared button/text-field migration
- hard-coded color cleanup
- contrast and token tests
- documentation updates

This plan does not redesign every screen visually in one pass. It builds the system first, then migrates high-impact surfaces.

## 2. Phase 1 - Token Foundation

Create token files:

- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_typography.dart`
- `lib/core/theme/app_spacing.dart`
- `lib/core/theme/app_radii.dart`
- `lib/core/theme/app_motion.dart`

Move raw constants out of `AppTheme` into token classes. Keep backward-compatible aliases in `AppTheme` initially:

- `AppTheme.primaryColor`
- `AppTheme.surfaceColor`
- `AppTheme.onSurfaceColor`
- `AppTheme.errorColor`
- existing text style getters

Reason: many screens already import `AppTheme`; removing aliases immediately would create unnecessary churn.

## 3. Phase 2 - ThemeData Wiring

Update `AppTheme.themeData` to use proposed tokens:

- `primary #F97316`, `onPrimary #0F172A`
- `secondary #3DB3A9`, `onSecondary #0F172A`
- `tertiary #3B82F6`, `onTertiary #0F172A`
- `surface #FFFFFF`, `onSurface #0F172A`
- `outline #CBD5E1`, `outlineVariant #94A3B8`
- `error #DC2626`, `onError #FFFFFF`

Update component themes:

- `ElevatedButtonThemeData`
- `OutlinedButtonThemeData`
- `TextButtonThemeData`
- `InputDecorationTheme`
- `CardThemeData`
- `SnackBarThemeData`
- `ChipThemeData`

## 4. Phase 3 - Shared Widgets First

Update:

- `lib/core/widgets/custom_button.dart`
- `lib/core/widgets/custom_text_field.dart`
- `lib/core/utils/toast_helper.dart`

Rules:

- `CustomButton` defaults to primary orange + asphalt text.
- Add optional `variant`: `primary`, `emergency`, `trust`, `info`, `danger`, `neutral`.
- SOS/destructive buttons use the `emergency`/`danger` variant: red + white.
- `CustomTextField` uses radius/border/spacing tokens.
- Toast helper uses semantic tokens instead of local `arsGreen`, `arsRed`, `arsBlue`, `arsOrange`.

## 5. Phase 4 - High-Impact Screen Migration

Migrate screens in this order:

1. `lib/features/onboarding/presentation/screens/`
2. `lib/features/customer/auth/presentation/screens/`
3. `lib/features/customer/booking/presentation/`
4. `lib/features/mechanic/dashboard/presentation/`
5. `lib/features/customer/booking/presentation/screens/payment/`
6. Remaining customer/mechanic support screens

Replace:

- `Color(0xFF00BFA5)` with role tokens
- `Colors.red` with `emergency`/`danger`; never routine primary
- `Colors.green` with `success`
- `Colors.orange` / `#F97316` with `primary` for routine CTA or `warning`/`rating` for status
- `Colors.blue` with `info`
- `Colors.grey[...]` with `text2`, `text3`, `border`, or `surfaceMuted`
- raw `fontSize` values with `Theme.of(context).textTheme.*`

## 6. Phase 5 - Tests and Guardrails

Add tests:

- contrast helper test for token foreground/background pairs
- `ThemeData.colorScheme` exact token mapping test
- `CustomButton` default color test
- docs/token drift test for banned strings where practical

Minimum assertions:

- normal button text contrast is at least `4.5:1`
- normal service CTAs use orange + dark text, not white text
- SOS/destructive CTAs use red + white text
- form focus/outline state reaches `3:1` where it defines control boundaries
- no `GeneralSans` references remain
- no new `Color(0xFF00BFA5)` references are introduced

## 7. Phase 6 - Documentation and Migration Finish

Update:

- `docs/design-system/DESIGN_SYSTEM_AUDIT.md`
- `docs/design-system/DESIGN_SYSTEM_TOKENS.md`
- `docs/design-system/DESIGN_SYSTEM_PLAN.md`
- `docs/STYLE_GUIDE.md` to point to the new token source after implementation
- `docs/README.md` to keep design-system docs discoverable

After migration, update `docs/design-system/DESIGN_SYSTEM_AUDIT.md` with post-fix counts.

## 8. Verification Commands

Run after implementation:

```bash
flutter pub get
flutter analyze
flutter test
rg "Color\\(0xFF00BFA5\\)|GeneralSans|fontSize:" lib
rg "Colors\\.(red|green|orange|blue|grey)" lib
```

Expected:

- tests pass, except any already-known unrelated baseline failures must be listed explicitly
- analyzer has no new design-system errors
- remaining raw colors/font sizes are either migrated or documented as intentional exceptions

## 9. Acceptance Criteria

- Design-system token files exist and are imported by `AppTheme`.
- Primary service CTA and SOS CTA foreground contrast pass WCAG AA.
- Shared button and text field use tokens.
- New screens have a clear token path and do not copy raw color constants.
- Design-system docs explain current state, target state, and migration order.
