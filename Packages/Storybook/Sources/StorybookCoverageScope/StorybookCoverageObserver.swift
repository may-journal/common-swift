// cspell:ignore profraw objc nonisolated
import Foundation
import XCTest

/// The XCTest form of `.storybookCoverage`, which XCTest creates when the bundle's Info.plist names it
/// as `NSPrincipalClass`. Outside the tool's run it does nothing.
@objc(StorybookCoverageObserver)
public final class StorybookCoverageObserver: NSObject, XCTestObservation {
    override public init() {
        super.init()
        guard CoverageRecorder.shared.isActive else { return }
        CoverageRecorder.shared.saveLaunch()
        XCTestObservationCenter.shared.addTestObserver(self)
    }

    /// Zeroes the counters, and attaches the test's profile in a teardown block when it passed.
    public func testCaseWillStart(_ testCase: XCTestCase) {
        let launch = CoverageRecorder.shared.begin()
        let test = Self.name(of: testCase)
        // XCTest runs the test and its teardown blocks on the main thread, one test at a time.
        nonisolated(unsafe) let testCase = testCase
        testCase.addTeardownBlock {
            let passed = testCase.testRun.map { $0.hasSucceeded } ?? false
            for profile in launch + (passed ? CoverageRecorder.shared.end(test: test) : []) {
                let attachment = XCTAttachment(data: profile.data)
                attachment.name = profile.name
                attachment.lifetime = .keepAlways
                testCase.add(attachment)
            }
        }
    }

    /// The test method's name, such as `test0012_1` for `-[ShowingTests test0012_1]`.
    static func name(of testCase: XCTestCase) -> String {
        let words = testCase.name.split(separator: " ")
        return CoverageRecorder.name(of: String((words.last ?? "").filter { $0 != "]" }))
    }
}
