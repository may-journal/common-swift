# Theme lessons

What the six may-journal iOS apps learned about design tokens, and where `Theme` keeps each lesson. Paths are on each app's `main` as of 2026-11-09.

## Every app keeps tokens under its own names

- may-calendar: `Palette`, `Spacing` and `Typography` in `src/UI/DesignSystem/`.
- may-journals: `Color.mj*`, `MJRadius` and `MJFont` in `src/UI/Shared/DesignSystem.swift`.
- photo-portal and secret-gifts: `Palette` in `src/UI/Theme/Palette.swift`.
- totalist: `Color.tl*` and `TillMetrics` in `totalist/TillTheme.swift`.
- may-photos: no tokens; spacing and radii are typed by hand in each view.

A shared view cannot name any of these. `Theme` holds roles, not names. The app maps its tokens onto `Palette`, `Spacing`, `Radii` and `TypeScale` and sets the theme once at its root.

## A fallback keeps the package building alone

totalist maps its surfaces onto system semantic colors, so both appearances come free. `Theme.standard` does the same on iOS and the Mac, so a view drawn without an app theme still reads well.

## Surface and background differ in dark mode

photo-portal found that one token for the screen and the card drew every card invisible on a black screen. `Palette` keeps `background` and `surface` as two roles.

## Light and dark values sit in one color

photo-portal and secret-gifts build each token from two hex values that resolve at draw time, so no view reads the color scheme. `Color(light:dark:)` keeps this on iOS and the Mac.

## Stored colors parse in one place

may-journals, photo-portal and secret-gifts each carry a hex parser for colors stored as `#RRGGBB`. `Color(hex:)` refuses anything else, so the caller picks the fallback.

## Type grows with the person's text size

may-calendar picks a step of its scale, never a literal size, and scales it with the step's text style. `.font(_:)` with a `TypeStep` does the same, reading the text size from the environment. A Mac draws one size, from its own smaller scale.
