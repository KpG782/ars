# ARS Design System

**Date:** 2026-06-01  
**Current source of truth:** `ARS_DESIGN_SYSTEM_PREVIEW.html` for visual tokens, mirrored by `lib/core/theme/app_colors.dart` and `lib/core/theme/app_theme.dart`  
**Status:** Initial Flutter theme rollout is implemented. Analyzer cleanup remains tracked separately.

This folder collects the ARS design-system audit, proposed tokens, and rollout plan.

## Documents

- [Interactive HTML Preview](./ARS_DESIGN_SYSTEM_PREVIEW.html) - standalone light/dark design-system preview with live contrast checks.
- [Design System Audit](./DESIGN_SYSTEM_AUDIT.md) - current color, typography, spacing, radius, and component findings.
- [Token Proposal](./DESIGN_SYSTEM_TOKENS.md) - proposed ARS color, type, spacing, radius, and motion tokens.
- [Light and Dark Mode Setup](./DESIGN_SYSTEM_THEME_MODES.md) - mode-specific tokens and Flutter theme wiring.
- [Implementation Plan](./DESIGN_SYSTEM_PLAN.md) - phased rollout from current hard-coded styles to a tokenized system.
- [Migration Setup](./DESIGN_SYSTEM_MIGRATION_SETUP.md) - first migration slice to prepare the codebase safely.
- [Architecture And Analyzer Cleanup Plan](./ARS_ARCHITECTURE_ANALYZE_CLEANUP_PLAN.md) - plan for reducing the remaining analyzer backlog without destabilizing the theme migration.
- [Feature Architecture Audit Phase 2](./ARS_FEATURE_ARCHITECTURE_AUDIT_PHASE_2.md) - next phase to audit feature boundaries, dependency direction, routing/providers, and smoke-test coverage.

## Current Verdict

ARS now has a tokenized Flutter theme foundation: Figtree typography, Material 3 color roles, explicit light/dark palettes, spacing/radius/motion tokens, and a guard test that keeps feature code from reintroducing raw colors or raw font sizes. The remaining work is analyzer hygiene and selective architecture cleanup, not another color-system redesign.

Recommended direction after external review: **asphalt-first foundation + orange normal service action + red SOS/destructive action + teal trust/support accent + blue map/info + green success only**.

## Updated Verdict From External Research

The external research changes one important implementation decision: **do not make red the general app primary.** Red is category-correct for SOS and destructive states, but using it as the everyday booking/confirm color would make routine flows feel like danger. The stronger setup is:

- **Normal service CTA:** orange `#F97316` with dark text.
- **Emergency/SOS CTA:** red `#DC2626` with white text.
- **Support/trust accent:** teal `#3DB3A9` with dark text.
- **Map/info accent:** blue `#3B82F6` with dark text.
- **Success only:** green `#16A34A`.
- **Foundation:** asphalt/slate neutrals and off-white surfaces.

This is worth migrating because it fixes the current white-on-teal contrast failure, maps color roles to road/service semantics, and gives ARS two clear modes: calm booking and urgent SOS.

## Historical Deep Research Prompt

This was the research prompt used before the current migration. Keep it as context, not as the live source of truth.

```text
I am designing the production design system for ARS, a Flutter mobile app for automotive roadside assistance and auto repair services in the Philippines.

Product context:
- App name: ARS / Auto Repair Service.
- Users: customers who need roadside repair, and mechanics who accept service requests.
- Core flows: onboarding, login/signup, booking a repair, choosing services, map/ETA, chat, payment, mechanic dashboard, service history, support.
- Brand goal: trustworthy, urgent when needed, automotive/roadside-specific, modern, readable, accessible, and suitable for repeated operational use.
- Current stack: Flutter, Material 3 ThemeData, ColorScheme, google_fonts, Figtree currently wired in `lib/core/theme/app_theme.dart`.

Current theme facts:
- Current primary: teal `#3DB3A9`.
- Current primary text/CTA foreground is usually white.
- Contrast problem: `#3DB3A9` on white foreground is only about 2.55:1, so it fails WCAG AA for normal text.
- Other current theme colors:
  - `primaryLight #6DCCC4`
  - `primaryDark #2A8A82`
  - `primarySurface #E8F6F5`
  - `secondaryColor #2D2D3A`
  - `accentYellow #F5C842`
  - `surfaceColor #FAFAFA`
  - `cardColor #FFFFFF`
  - `onSurfaceColor #1A1A2E`
  - `subtitleColor #6B7280`
  - `borderColor #E5E7EB`
  - `errorColor #EF4444`
  - `successColor #22C55E`
- Existing hard-coded colors in the app still include many `#00BFA5`, `Colors.red`, `Colors.green`, `Colors.orange`, `Colors.blue`, and grey values.
- Typography currently uses Figtree via Google Fonts. Local font assets still exist for CabinetGrotesk, Chillax, and Satoshi.
- Current font sizes in code are scattered: 10, 11, 12, 13, 14, 15, 16, 18, 20, 22, 24, 28, 32, 36, 40, 48, 56.
- Spacing mostly follows a hidden 4pt grid with values like 4, 8, 12, 16, 20, 24, 32, but there are no named spacing tokens yet.
- Radius values are scattered: 8, 12, 14, 16, 20, 24, 28, 30.

Current proposed direction from the internal audit:
- Move away from teal as the primary CTA.
- Use an asphalt/slate foundation for road/reliability/premium UI.
- Use rescue red for emergency/high-priority primary roadside CTA.
- Use service orange for repair, caution, ETA, and service accents.
- Keep teal only as a trust/support accent, not as primary action.
- Use green only for success/verified/mechanic availability.
- Use blue for maps, routes, ETA info, and neutral information states.

Candidate token direction:
- Neutrals:
  - background `#F8FAFC`
  - surface `#FFFFFF`
  - surfaceMuted `#F1F5F9`
  - border `#CBD5E1`
  - borderStrong `#94A3B8`
  - text1 `#0F172A`
  - text2 `#475569`
  - text3 `#64748B`
  - inverseSurface `#1E293B`
- Brand/action:
  - primary/service orange `#F97316`, onPrimary `#0F172A`
  - emergency red `#DC2626`, onEmergency `#FFFFFF`
  - trust teal `#3DB3A9`, onTrust `#0F172A`
- Semantic:
  - success `#16A34A`
  - info `#3B82F6`
  - warning/rating `#F59E0B`
  - danger `#DC2626`

I need research-backed recommendations, not personal taste. Please evaluate:
1. What color architecture best fits an automotive roadside assistance app: teal-first, red-first, orange-first, dark/asphalt-first with red/orange accents, or another approach?
2. What should be the primary CTA color for normal booking vs emergency/SOS action?
3. Should red be used as the app primary color, or reserved only for emergency/destructive states?
4. Is orange better than red for general roadside repair action because of road-work/maintenance associations?
5. Where, if anywhere, should the current teal remain in the system?
6. What complete color token set should ARS use for light theme first, with future dark theme compatibility?
7. What typography system is best for a Flutter operational service app: keep Figtree, switch to another Google Font, use local Satoshi/Cabinet/Chillax, or pair display/body fonts?
8. What type scale should be used for mobile, including headings, body, labels, metadata, buttons, and numeric values such as ETA, distance, price, and ratings?
9. What spacing, radius, and motion tokens should be standardized for a mobile app with maps, bottom sheets, cards, service chips, forms, and dashboards?
10. What should the Flutter Material 3 ColorScheme role mapping be?
11. What accessibility checks should be mandatory before implementation?

Please produce:
- A short verdict.
- A recommended palette with token names, hex values, intended usage, and foreground colors.
- Contrast notes for every text-on-color pair.
- A typography scale table with font, size, weight, line-height, and use case.
- Spacing/radius/motion token tables.
- Flutter Material 3 role mapping.
- Do/don't rules for using red, orange, teal, green, blue, amber, and neutral colors.
- Risks or tradeoffs in the recommendation.
- A phased implementation plan for migrating an existing Flutter codebase with many hard-coded colors.

Use research standards such as WCAG 2.2 contrast, Material 3 color roles, mobile touch target guidance, road/traffic color semantics where relevant, and current product UI best practices. Include source links.
```
