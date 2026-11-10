# Screen states lessons

What the six may-journal iOS apps learned about loading, empty and failed screens, and where `ScreenStates` keeps each lesson. Paths are on each app's `main` as of 2026-11-09.

## One switch per loading screen

photo-portal and secret-gifts each carry the same `LoadStateContent` in `src/UI/Components/StateViews.swift`. It switches over loading, failed, empty and loaded. may-calendar writes the same switch in `src/UI/History/EventHistoryUnavailable.swift`.

`LoadState` and `LoadStateView` keep the switch. A collection counts as empty when it has no items.

## A failure offers a way on

may-calendar's failed History shows its message with a Try Again button. photo-portal's `ErrorStateView` does the same after a failed sync.

`FailureView` shows the message, and Try Again only when the caller can retry.

## Empty and failed screens share one layout

photo-portal's `CenteredStatusView` draws a symbol tile, a title, a message and a button for both. Its sizes and colors were typed by hand.

`StatusView` keeps the layout and reads every color, size and radius from `Theme`.

## A placeholder is read as loading

may-calendar's `HistoryLoading` in `src/UI/History/HistoryLoading.swift` draws sample rows redacted and breathing. VoiceOver reads "Loading" and never the sample, and taps pass through.

`loadingPlaceholder` keeps all three, and stops breathing when the person asks for reduced motion.

## A slow task shows a pill

may-photos lays `StatusCapsule` over its grid while a task runs, in `src/UI/Components/StatusCapsule.swift`.

`StatusPill` keeps the spinner and the label, and VoiceOver reads the task as in progress.
