@testable import DemoKit
import FamilyDay
import Testing
import UITestingLibrary

/// Requirement 0019: the catalog shows a day's row for each sender app. The FamilyDay package's
/// own tests prove the rest of it.
extension DemoKitTests {
    @MainActor
    @Suite struct DayRows {
        @Test func test0019_5() async throws {
            let launch = try Launch(.pad, arguments: ["--storybook", "0019.5 Row for each app"])
            for app in FamilyApp.allCases {
                try await launch.user.sees(.text("\(app.name) row"))
            }
            try launch.quits()
        }
    }
}
