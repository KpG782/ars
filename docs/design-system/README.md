# Talyer Design System

The source of truth lives in **code** at `lib/core/design/`. This folder is the
human-readable companion.

- **[tokens.md](tokens.md)** — colour, type, spacing, radius, elevation, motion.
- **[components.md](components.md)** — the component library + usage.
- **[preview.html](preview.html)** — static one-page preview (open in any
  browser) for designers/stakeholders without a Flutter toolchain.

The **canonical** preview is the in-app `GalleryScreen` (`/gallery`), which
renders the real widgets in the real engine, light & dark.

## Principles
1. **Trust is visible.** Verification and ratings are first-class components, not
   afterthoughts — they're the whole reason to leave the free FB-group mekaniko.
2. **No dead-ends.** Every empty/error/loading state offers the next action.
3. **Accessible by default.** ≥48dp targets, AA contrast, focus states,
   reduce-motion honoured.
4. **Taglish for warmth, English for trust.** Warm Filipino in conversational
   copy; clean English for pricing, safety, verification.
5. **Tokens, not magic numbers.** If you're typing a hex or a pixel in a screen,
   it belongs in a token.

## Provenance
Palette, voice, and component priorities come from the ARS rebrand + competitor
analysis (`docs/REBRAND_AND_COMPETITOR_ANALYSIS.md` in the source repo): teal-led
trust palette, the activated emergency token, and the "surface the trust you
already collect" thesis.
