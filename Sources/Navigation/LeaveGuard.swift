import Observation

/// The one gate every exit from an editing screen goes through. With unsaved work it parks
/// the request in `pending`, and the screen asks Save, Discard or Cancel.
@Observable
@MainActor
public final class LeaveGuard<Leave: Equatable> {
    /// Where the user asked to go while work was unsaved. Non-nil shows the prompt.
    public private(set) var pending: Leave?

    @ObservationIgnored private let hasUnsavedWork: @MainActor () -> Bool
    @ObservationIgnored private let perform: @MainActor (Leave) -> Void

    /// `hasUnsavedWork` says whether a leave must ask; `perform` opens, closes or pops.
    public init(
        hasUnsavedWork: @escaping @MainActor () -> Bool,
        perform: @escaping @MainActor (Leave) -> Void
    ) {
        self.hasUnsavedWork = hasUnsavedWork
        self.perform = perform
    }

    /// Leaves now, or parks `leave` behind the prompt when work is unsaved.
    public func request(_ leave: Leave) {
        if hasUnsavedWork() {
            pending = leave
        } else {
            perform(leave)
        }
    }

    /// Cancel: stay, with the work intact.
    public func cancel() {
        pending = nil
    }

    /// Discard: go without saving.
    public func discard() {
        guard let leave = pending else { return }
        pending = nil
        perform(leave)
    }

    /// Save, then go, only once the work really saved. A failed save stays put with the work.
    public func saveThenLeave(_ save: @MainActor () async throws -> Void) async {
        guard let leave = pending else { return }
        pending = nil
        do {
            try await save()
        } catch {
            return
        }
        guard !hasUnsavedWork() else { return }
        perform(leave)
    }

    /// Drops a parked request, as when the item it guarded is gone.
    public func reset() {
        pending = nil
    }
}
