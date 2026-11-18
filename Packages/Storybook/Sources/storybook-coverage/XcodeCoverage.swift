// cspell:ignore xccov xcresult xctest xcworkspace xcodeproj xcresulttool
import Foundation

/// Runs an Xcode scheme's requirement tests with coverage: once for those the scope records, then
/// alone for the rest, read with `xccov`. UI tests count, since Xcode gathers the app's coverage then.
struct XcodeCoverage {
    /// An `.xcodeproj`, an `.xcworkspace`, or a folder holding a `Package.swift`.
    let container: URL
    let scheme: String?
    let destination: String
    let root: URL
    /// A folder of an earlier run's `<test>.xcresult` bundles, read instead of running the tests.
    var results: URL?
    /// Arguments each xcodebuild call passes on, such as `-allowProvisioningUpdates` or `-xcconfig <file>`.
    var arguments: [String] = []

    /// Each test's covered repo files, keyed by the test's name. A test the scheme does not run is left out.
    func covered(_ tests: [String]) throws -> [String: [String]] {
        if let results {
            say("Reading \(results.path(percentEncoded: false))")
            return try tests.reduce(into: [:]) { found, test in
                let bundle = results.appending(path: "\(test).xcresult")
                // A test without a bundle maps to its own file rather than running again.
                guard FileManager.default.fileExists(atPath: bundle.path) else {
                    say("  \(test) has no result bundle there, so it maps to its own file")
                    found[test] = []
                    return
                }
                found[test] = try files(bundle)
            }
        }
        let work = FileManager.default.temporaryDirectory.appending(path: "storybook-coverage-xcode")
            .appending(path: root.path(percentEncoded: false).replacing("/", with: "_"))
        try? FileManager.default.removeItem(at: work.appending(path: "results"))
        let scheme = try self.scheme ?? onlyScheme()
        let base = location + [
            "-scheme", scheme, "-destination", destination,
            "-derivedDataPath", work.appending(path: "DerivedData").path(percentEncoded: false),
            "-skipPackagePluginValidation", "-skipMacroValidation", "-quiet"
        ] + arguments
        say("Building \(container.lastPathComponent) scheme \(scheme) with coverage")
        try run(["xcodebuild", "build-for-testing", "-enableCodeCoverage", "YES"] + base, in: folder)
        let listing = work.appending(path: "tests.json")
        // xcodebuild refuses to overwrite an earlier run's listing.
        try? FileManager.default.removeItem(at: listing)
        try run(
            ["xcodebuild", "test-without-building", "-enumerate-tests", "-test-enumeration-style", "flat",
             "-test-enumeration-format", "json", "-test-enumeration-output-path",
             listing.path(percentEncoded: false)] + base, in: folder)
        let wanted = try identifiers(listing).filter { tests.contains(Self.name(of: $0)) }
        var found = try once(wanted, base: base, work: work)
        for identifier in wanted {
            let test = Self.name(of: identifier)
            guard found[test] == nil else { continue }
            say("  \(test)")
            let bundle = work.appending(path: "results/\(test).xcresult")
            try run(
                ["xcodebuild", "test-without-building", "-enableCodeCoverage", "YES", "-only-testing:\(identifier)",
                 "-resultBundlePath", bundle.path(percentEncoded: false)] + base, in: folder)
            found[test, default: []] += try files(bundle)
        }
        return found
    }

    /// The test's name in an identifier such as `DemoKitTests/Showing/test0012_1()`.
    static func name(of identifier: String) -> String {
        String(identifier.split(separator: "/").last ?? "").replacing("()", with: "")
    }

    /// Runs every wanted test in one `xcodebuild`, one at a time, and reads the profiles the scope
    /// attached against the binaries built. A failed test leaves none, so it runs alone after.
    private func once(_ identifiers: [String], base: [String], work: URL) throws -> [String: [String]] {
        guard !identifiers.isEmpty else { return [:] }
        let bundle = work.appending(path: "results/all.xcresult")
        let export = work.appending(path: "results/attachments")
        try? FileManager.default.createDirectory(at: export, withIntermediateDirectories: true)
        say("Running \(identifiers.count) \(identifiers.count == 1 ? "test" : "tests") once")
        try run(
            ["xcodebuild", "test-without-building", "-enableCodeCoverage", "YES",
             "-parallel-testing-enabled", "NO", "-resultBundlePath", bundle.path(percentEncoded: false)]
                + identifiers.map { "-only-testing:\($0)" } + base,
            in: folder, environment: ScopeProfiles.environment, check: false)
        _ = try? run(
            ["xcrun", "xcresulttool", "export", "attachments", "--path", bundle.path(percentEncoded: false),
             "--output-path", export.path(percentEncoded: false)])
        let objects = ScopeProfiles.objects(in: work.appending(path: "DerivedData/Build/Products"))
        let tests = identifiers.map(Self.name(of:))
        let found = ScopeProfiles(export: export).covered(tests, objects: objects, root: root)
        tests.filter { found[$0] == nil }.forEach { say("  \($0) has no profile from that run, so it runs alone") }
        return found
    }

    /// The folder xcodebuild runs in: a package's own, or the project's.
    private var folder: URL {
        isPackage ? container : container.deletingLastPathComponent()
    }

    private var isPackage: Bool {
        FileManager.default.fileExists(atPath: container.appending(path: "Package.swift").path)
    }

    private var location: [String] {
        switch container.pathExtension {
        case "xcworkspace": ["-workspace", container.path(percentEncoded: false)]
        case "xcodeproj": ["-project", container.path(percentEncoded: false)]
        default: []
        }
    }

    /// The scheme when the container has just one, as a package with one product does.
    private func onlyScheme() throws -> String {
        let text = try run(["xcodebuild", "-list", "-json"] + location, in: folder)
        let start = text.firstIndex(of: "{") ?? text.startIndex
        let json = try JSONSerialization.jsonObject(with: Data(text[start...].utf8)) as? [String: Any]
        let container = (json?["project"] ?? json?["workspace"]) as? [String: Any]
        let schemes = container?["schemes"] as? [String] ?? []
        guard schemes.count == 1, let scheme = schemes.first else {
            throw CommandFailure(
                command: ["storybook-coverage"],
                log: "Pass --scheme, one of: \(schemes.joined(separator: ", "))\n")
        }
        return scheme
    }

    /// The test identifiers the scheme runs, such as `DemoKitTests/DemoKitTests/Showing/test0012_1()`.
    private func identifiers(_ listing: URL) throws -> [String] {
        let json = try JSONSerialization.jsonObject(with: Data(contentsOf: listing)) as? [String: Any]
        let plans = json?["values"] as? [[String: Any]] ?? []
        return plans.flatMap { plan in
            (plan["enabledTests"] as? [[String: Any]] ?? []).compactMap { $0["identifier"] as? String }
        }
    }

    /// The bundle's files with covered lines, leaving out those built into test bundles.
    private func files(_ bundle: URL) throws -> [String] {
        let text = try run(["xcrun", "xccov", "view", "--report", "--json", bundle.path(percentEncoded: false)])
        let json = try JSONSerialization.jsonObject(with: Data(text.utf8)) as? [String: Any]
        let targets = (json?["targets"] as? [[String: Any]] ?? [])
            .filter { !($0["buildProductPath"] as? String ?? "").contains(".xctest/") }
        let covered = targets.flatMap { target in
            (target["files"] as? [[String: Any]] ?? []).compactMap { file -> String? in
                guard let lines = file["coveredLines"] as? Int, lines > 0 else { return nil }
                return file["path"] as? String
            }
        }
        return sources(covered, root: root)
    }
}
