# Talyer Components

All in `lib/core/design/components/`, exported by `design.dart`. Each reads
tokens via `context.talyer` / `context.tt`, so they re-theme automatically in
light & dark.

## TalyerButton
Primary action. Variants: `primary` (teal), `accent` (orange), `emergency`
(red), `outline`, `ghost`. Always ≥48dp; shows an in-place spinner and
self-disables while `loading`; `Semantics(button:true)`.
```dart
TalyerButton(label: 'Tawag ng Talyer', icon: Icons.handyman_rounded, onPressed: book);
TalyerButton(label: 'SOS', variant: TalyerButtonVariant.emergency, onPressed: sos);
```

## TalyerCard
Calm bordered surface. `onTap` adds ink feedback; `selected` switches to the
teal container + 2px ring. Soft shadow in light, flat in dark.

## VerifiedBadge
The signature brass trust seal — surface it everywhere a mechanic appears.
`compact` for inline use. Carries an a11y label "Verified Talyer mechanic".

## StatusChip
Pill with tone + icon (status never by colour alone): `neutral · primary ·
success · warning · info · emergency · verified`.

## RatingStars
Star + value + `count` so a lone 5.0 doesn't outrank a seasoned 4.7. Announces
"x out of 5 stars, n reviews".

## TalyerTextField
Labelled input; the visible label is also the a11y label; errors render inline;
optional `helper`, `prefixIcon`, `suffix`.

## ServiceTile
Selectable service option with an **estimated price range shown at the point of
choice** (the no-surprise-pricing promise). Used in the service sheet.

## MechanicCard
The trust-forward result card: avatar, name + **Verified** seal, specialization,
`RatingStars`, distance/ETA chips, upfront price. The highest-leverage
conversion surface.

## TalyerEmptyState
Degraded/empty state that **always offers the next action**. Factory
`TalyerEmptyState.noMechanic(...)` ships the launch-critical "Walang available na
Talyer ngayon dito" fallback with *Notify me* / *Widen search*.

## Bottom sheet
`showTalyerSheet(context:, builder:)` + `TalyerSheetHeader(title:, subtitle:)` —
rounded top, drag handle, safe-area aware.

---

### Adding a component
1. Read tokens via `context.talyer` / `context.tt` — never hardcode.
2. ≥48dp targets, an a11y label/`Semantics` for icon-only controls, visible
   focus, AA contrast.
3. Export it from `design.dart` and add a section to `GalleryScreen`.
