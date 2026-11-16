import Foundation

/// Reads the acceptances out of one requirement doc, as `docs/requirements` writes them:
/// a `- 0006.3` line, then its indented Given, When and Then lines.
enum StorybookRequirementDoc {
    /// One acceptance: its ID, its lines as written, and its Then line without "Then".
    struct Block: Equatable {
        let id: String
        let lines: String
        let then: String
    }

    /// Every acceptance in `body`, in the order the doc lists them.
    static func acceptances(in body: String) -> [Block] {
        var blocks: [Block] = []
        var id: String?
        var lines: [Substring] = []
        func finish() {
            guard let id else { return }
            blocks.append(Block(id: id, lines: lines.joined(separator: "\n"), then: then(in: lines)))
        }
        for line in body.split(separator: "\n", omittingEmptySubsequences: false) {
            if let match = line.wholeMatch(of: /- ([0-9]{4}\.[0-9]+)\s*/) {
                finish()
                id = String(match.output.1)
                lines = []
            } else if line.first == " " || line.first == "\t" {
                lines.append(line)
            } else if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                finish()
                id = nil
                lines = []
            }
        }
        finish()
        return blocks
    }

    /// The words after "Then" on the block's Then line.
    private static func then(in lines: [Substring]) -> String {
        for line in lines {
            if let match = line.firstMatch(of: /- Then (.+)/) { return String(match.output.1) }
        }
        return ""
    }
}
