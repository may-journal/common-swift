import Foundation
import Synchronization
import Testing

/// Lets the storybook-coverage tool map each test from one run of the suite: put `.storybookCoverage`
/// on the root suite. Outside the tool's run it does nothing.
///
/// ```swift
/// @Suite(.serialized, .storybookCoverage) struct DiaryTests {}
/// ```
public struct StorybookCoverageTrait: TestTrait, SuiteTrait, TestScoping {
    public var isRecursive: Bool { true }

    /// Each test case of the suite and of the suites inside it, but not the suites themselves.
    public func scopeProvider(for test: Test, testCase: Test.Case?) -> Self? {
        testCase != nil && CoverageRecorder.shared.isActive ? self : nil
    }

    /// Keeps the launch's profile while the run plans its tests, before any test runs, under the trait or not.
    public func prepare(for test: Test) async throws {
        if CoverageRecorder.shared.isActive { CoverageRecorder.shared.saveLaunch() }
    }

    /// Runs the test alone on zeroed counters, then attaches its profile when no issue failed it.
    public func provideScope(
        for test: Test, testCase: Test.Case?, performing function: @Sendable () async throws -> Void
    ) async throws {
        // A test the trait reaches twice, from a suite and a suite inside it, records once.
        guard !Self.recording else {
            try await function()
            return
        }
        await CoverageLock.shared.acquire()
        let failed = Failed()
        do {
            for profile in CoverageRecorder.shared.begin() { Attachment.record(profile.data, named: profile.name) }
            let watch = IssueHandlingTrait.compactMapIssues { issue in
                if issue.isFailure { failed.value.store(true, ordering: .relaxed) }
                return issue
            }
            try await Self.$recording.withValue(true) {
                try await watch.provideScope(for: test, testCase: testCase, performing: function)
            }
        } catch {
            await CoverageLock.shared.release()
            throw error
        }
        if !failed.value.load(ordering: .relaxed) {
            for profile in CoverageRecorder.shared.end(test: CoverageRecorder.name(of: test.name)) {
                Attachment.record(profile.data, named: profile.name)
            }
        }
        await CoverageLock.shared.release()
    }

    @TaskLocal private static var recording = false

    private final class Failed: Sendable {
        let value = Atomic(false)
    }
}

extension Trait where Self == StorybookCoverageTrait {
    /// Lets the storybook-coverage tool map each test from one run of the suite.
    public static var storybookCoverage: Self { Self() }
}
