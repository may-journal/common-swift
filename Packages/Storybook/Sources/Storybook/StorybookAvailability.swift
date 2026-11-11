import Foundation
import Observation
import StorybookKit

/// Whether this build shows the Storybook catalog: the gate's rule, then a hidden switch that
/// seven taps on Version turn on for good. The app hands its one to both views.
@MainActor @Observable
public final class StorybookAvailability {
    /// How many taps on the version row unlock the catalog, as on Apple's own builds.
    public static let unlockTaps = 7

    /// The host's words, identifiers, version, pages and launch arguments.
    public let configuration: StorybookConfiguration
    /// Whether the build may show the catalog. Starts true in Debug, so a launch argument opens
    /// the catalog before the gate answers.
    public private(set) var isBuildAllowed: Bool
    /// Whether the hidden switch is on; Debug starts on, so development needs no taps.
    public private(set) var isUnlocked: Bool
    /// Whether the catalog is on screen. One cover at the app's root shows it for every way in,
    /// so two can never stack.
    var isCatalogPresented = false
    /// Whether the catalog really appeared, which a cover refused by an open sheet never does.
    @ObservationIgnored var isCatalogOnScreen = false
    @ObservationIgnored private let gate: StorybookGate
    @ObservationIgnored let defaults: UserDefaults
    @ObservationIgnored private var resolution: Task<Void, Never>?
    @ObservationIgnored private var versionTaps = 0
    @ObservationIgnored private var scanned: StorybookCatalog?
    /// What the next opening shows: the page the launch named, then the catalog's start.
    @ObservationIgnored private(set) var request: StorybookLaunchRequest
    /// Whether `--storybook` asked to open the catalog and no opening has used it yet.
    @ObservationIgnored private var isLaunchPending: Bool
    @ObservationIgnored private var opening: StorybookOpening?
    /// The user defaults key that keeps the switch on.
    public static let unlockKey = "storybook.unlocked"

    public init(
        gate: StorybookGate = .debugOnly,
        configuration: StorybookConfiguration = StorybookConfiguration(),
        defaults: UserDefaults = .standard
    ) {
        self.gate = gate
        self.configuration = configuration
        self.defaults = defaults
        isBuildAllowed = gate.isDebug
        isUnlocked = gate.isDebug || defaults.bool(forKey: Self.unlockKey)
        let launch = StorybookLaunchRequest(arguments: configuration.arguments)
        request = launch ?? .catalog
        isLaunchPending = launch != nil
    }

    /// Whether any way in may open the catalog now.
    public var isEnabled: Bool { isBuildAllowed && isUnlocked }

    /// Asks the gate once which build this is. Every caller waits for that one answer, so none
    /// reads `isEnabled` before it lands.
    public func resolve() async {
        if resolution == nil {
            resolution = Task {
                let answer = await gate.allows()
                isBuildAllowed = answer ?? gate.isDebug
                // A question that failed, as when offline, is asked again next time. A Debug
                // build is allowed whatever the answer, so it never asks again.
                if answer == nil, !gate.isDebug { resolution = nil }
            }
        }
        await resolution?.value
    }

    /// Opens the catalog's one cover. A cover blocked by an open sheet is asked afresh next
    /// time, so a refused shake never leaves the flag stuck.
    public func presentsCatalog() {
        guard isEnabled, !isCatalogOnScreen else { return }
        isCatalogPresented = false
        Task { isCatalogPresented = true }
    }

    /// Opens the catalog once if `--storybook` asked for it; a later window or redraw does not.
    func presentsLaunchRequest() {
        guard isLaunchPending else { return }
        isLaunchPending = false
        presentsCatalog()
    }

    /// Closes the catalog's one cover.
    public func closesCatalog() {
        isCatalogPresented = false
    }

    /// After the first close, every way in opens the catalog's start.
    func catalogClosed() {
        isCatalogOnScreen = false
        if request != .catalog {
            request = .catalog
            opening = nil
        }
    }

    /// Counts one tap on the version row; the seventh turns the switch on for good. A build
    /// the gate refuses counts nothing.
    public func tapsVersion() {
        guard isBuildAllowed, !isUnlocked else { return }
        versionTaps += 1
        guard versionTaps >= Self.unlockTaps else { return }
        isUnlocked = true
        defaults.set(true, forKey: Self.unlockKey)
    }

    /// The one scan of every preview, made when the catalog first opens. The launch arguments
    /// are read then too, once, since rereading would undo every header tap since launch.
    var catalog: StorybookCatalog {
        if let scanned { return scanned }
        StorybookSettings.apply(configuration.arguments, to: defaults)
        let catalog = StorybookCatalog(pages: configuration.pages())
        scanned = catalog
        return catalog
    }

    /// Where the catalog opens for `request`, worked out once however often SwiftUI redraws.
    var currentOpening: StorybookOpening {
        if let opening { return opening }
        let found = catalog.opening(for: request)
        opening = found
        return found
    }
}
