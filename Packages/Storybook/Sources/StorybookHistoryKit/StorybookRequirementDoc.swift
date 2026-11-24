import Foundation

/// Reads titles and acceptances out of requirement docs: a `# 0006 Title` line, then each
/// `- 0006.3` line with its indented Given, When and Then lines.
enum StorybookRequirementDoc {
    /// Each doc's title by its number, from its `# 0006 Seeing the Storybook row` line.
    static func titles(in body: String) -> [String: String] {
        var titles: [String: String] = [:]
        for line in body.split(separator: "\n") {
            guard let match = line.wholeMatch(of: /# ([0-9]{4}) +(.+?)\s*/), titles[String(match.output.1)] == nil
            else { continue }
            titles[String(match.output.1)] = String(match.output.2)
        }
        return titles
    }

    /// One acceptance: its ID and its Then line without "Then".
    struct Block: Equatable {
        let id: String
        let then: String
    }

    /// Every acceptance in `body`, in the order the doc lists them.
    static func acceptances(in body: String) -> [Block] {
        var blocks: [Block] = []
        var id: String?
        var lines: [Substring] = []
        func finish() {
            guard let id else { return }
            blocks.append(Block(id: id, then: then(in: lines)))
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
