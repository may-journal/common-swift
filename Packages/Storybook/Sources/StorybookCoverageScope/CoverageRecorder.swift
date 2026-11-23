// cspell:ignore profraw
import Foundation
import Synchronization

/// The state the trait and the XCTest observer share: whether the tool asked for profiles, the
/// launch profile, and each profile's name.
final class CoverageRecorder: Sendable {
    static let shared = CoverageRecorder()

    /// True only when the storybook-coverage tool runs the tests. Xcode passes a `TEST_RUNNER_`
    /// variable on without its prefix, and `swift test` passes it as it is.
    let isActive: Bool

    private let state = Mutex(State())

    private struct State {
        /// The profiles before any test ran, kept until the first test attaches them.
        var launch: [(name: String, data: Data)]?
        var launchAttached = false
        var sequence = 0
        /// Every process's profiles before the running test, so those its own child processes write show.
        var before: Set<URL> = []
    }

    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        isActive = ["STORYBOOK_COVERAGE", "TEST_RUNNER_STORYBOOK_COVERAGE"].contains { environment[$0] == "1" }
    }

    /// Keeps the profiles of the launch, once, before the first test of the process runs. A test run
    /// alone launches too, so the tool adds them to every test's.
    func saveLaunch() {
        guard state.withLock({ $0.launch == nil }) else { return }
        let launch = profiles(ProfileCounters.files()) { "storybook-coverage-launch-\(getpid())-\($0).profraw" }
        state.withLock { $0.launch = $0.launch ?? launch }
    }

    /// Before a test, the launch profiles if no test has attached them yet, then zeroed counters.
    func begin() -> [(name: String, data: Data)] {
        saveLaunch()
        let launch = state.withLock { state in
            defer { state.launchAttached = true }
            return state.launchAttached ? [] : state.launch ?? []
        }
        let before = Set(ProfileCounters.files(anyProcess: true))
        state.withLock { $0.before = before }
        ProfileCounters.reset()
        return launch
    }

    /// After a test that passed, its raw profiles and those of processes it started, each named for
    /// the test. A failed test gets none, so the tool runs it alone and reports the failure.
    func end(test: String) -> [(name: String, data: Data)] {
        let (sequence, before) = state.withLock { state in
            state.sequence += 1
            return (state.sequence, state.before)
        }
        let own = ProfileCounters.files()
        let started = Set(ProfileCounters.files(anyProcess: true)).subtracting(before).subtracting(own)
        return profiles(own + started.sorted { $0.path < $1.path }) {
            "storybook-coverage-test-\(getpid())-\(sequence)-\($0)--\(test)--.profraw"
        }
    }

    private func profiles(_ files: [URL], named name: (Int) -> String) -> [(name: String, data: Data)] {
        files.enumerated().compactMap { index, file in
            (try? Data(contentsOf: file)).map { (name(index), $0) }
        }
    }

    /// The attachment that marks a failed test, so the tool drops what its passing cases recorded.
    static func failure(of test: String) -> String {
        "storybook-coverage-failed-\(getpid())--\(test)--.txt"
    }

    /// A test's function name without its argument labels, as the requirement test search spells it.
    static func name(of function: String) -> String {
        String(function.prefix { $0 != "(" })
    }
}

/// Runs one recorded test at a time, since every test shares the process's counters.
actor CoverageLock {
    static let shared = CoverageLock()

    private var busy = false
    private var waiting: [CheckedContinuation<Void, Never>] = []

    func acquire() async {
        guard busy else {
            busy = true
            return
        }
        await withCheckedContinuation { waiting.append($0) }
    }

    func release() {
        if waiting.isEmpty { busy = false } else { waiting.removeFirst().resume() }
    }
}
