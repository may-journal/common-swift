import Foundation

/// The coverage map's text: each acceptance's ID mapped to the repo files its test covers. IDs and
/// paths sort by code point and indent by two spaces, so the same coverage always writes the same bytes.
public enum StorybookCoverageMap {
    public static func json(_ map: [String: Set<String>]) -> String {
        guard !map.isEmpty else { return "{}\n" }
        let entries = map.keys.sorted(by: precedes).map { id in
            let files = map[id, default: []].sorted(by: precedes).map { "    \(quoted($0))" }
            return files.isEmpty
                ? "  \(quoted(id)): []" : "  \(quoted(id)): [\n\(files.joined(separator: ",\n"))\n  ]"
        }
        return "{\n\(entries.joined(separator: ",\n"))\n}\n"
    }

    private static func precedes(_ first: String, _ second: String) -> Bool {
        first.unicodeScalars.lexicographicallyPrecedes(second.unicodeScalars)
    }

    /// A JSON string, escaping quotes, backslashes and control characters.
    private static func quoted(_ text: String) -> String {
        var out = "\""
        for scalar in text.unicodeScalars {
            switch scalar {
            case "\"": out += "\\\""
            case "\\": out += "\\\\"
            case "\n": out += "\\n"
            case "\t": out += "\\t"
            case _ where scalar.value < 0x20: out += String(format: "\\u%04x", scalar.value)
            default: out.unicodeScalars.append(scalar)
            }
        }
        return out + "\""
    }
}
