import Observation

/// The one gate for every exit from an editing screen: it parks a leave while work is unsaved.
/// Hide the stack's own back button meanwhile, since its swipe skips the gate.
@Observable
@MainActor
public final class LeaveGuard<Leave: Equatable> {
    /// Where the user asked to go while work was unsaved. Non-nil shows the prompt.
    public private(set) var pending: Leave?
    /// A save from the prompt is running; new requests wait until it ends.
    public private(set) var isSaving = false

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
        guard !isSaving else { return }
        if hasUnsavedWork() {
            pending = leave
        } else {
            perform(leave)
        }
    }

    /// Cancel: stay, with the work intact.
    public func cancel() {
        guard !isSaving else { return }
        pending = nil
    }

    /// Discard: go without saving.
    public func discard() {
        guard !isSaving, let leave = pending else { return }
        pending = nil
        perform(leave)
    }

    /// Save, then go once the work really saved; work still unsaved afterwards asks again.
    /// A failed save closes the prompt and rethrows, so the screen can say why.
    public func saveThenLeave(_ save: @MainActor () async throws -> Void) async throws {
        guard !isSaving, let leave = pending else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            try await save()
        } catch {
            pending = nil
            throw error
        }
        // A reset during the save dropped the leave, so it must not run now.
        guard pending == leave, !hasUnsavedWork() else { return }
        pending = nil
        perform(leave)
    }

    /// Drops a parked request, as when the item it guarded is gone.
    public func reset() {
        pending = nil
    }
}
