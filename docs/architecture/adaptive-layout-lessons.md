# Adaptive layout lessons

What the may-journal iOS apps learned about wide and narrow screens, and where `AdaptiveLayout` keeps each lesson. Paths are on each app's `main` as of 2026-11-09.

## Split on a wide screen, push on a narrow one

may-journals' `HalfSplitView` in `src/UI/Shared/HalfSplitView.swift` lays out a list and a detail pane side by side. On a phone the detail pushes onto the enclosing stack, so Back writes `false` to the binding. may-photos switches between `LibraryShellView` and `LibrarySplitView` the same way.

`SplitOrStack` keeps both halves. It reads the measured width, not the size class, because a Mac window has no size class. It draws nothing until the width is known, so a wide screen never starts stacked.

## Text stops at a readable width

may-calendar's `CardColumn` in `src/UI/DesignSystem/Spacing.swift` caps a card at 720 points and centers it. Its margin grows on a regular width, since a narrow margin leaves the card hugging a wide screen.

`readableColumn` keeps the cap and both margins, and reads all three from `Theme`.

## A grid fills its rows

may-photos writes `GridItem(.adaptive(minimum:))` by hand in `src/UI/Library/PhotoGridView+Sections.swift`, in its search and in its browse page. Each copy picks its own gap.

`AdaptiveGrid` keeps the adaptive columns and takes the gap from the theme.

## One card surface

photo-portal and secret-gifts hand-write a rounded fill and border about 25 times, with radii from 12 to 30. may-calendar keeps the one shared modifier, `.tileCard()` in `src/UI/Mosaic/MosaicTileStyle.swift`.

`card` draws the theme's surface, hairline and large radius around the theme's inset.
