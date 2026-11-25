import Foundation

/// Reads titles from `# 0006 Title` lines, and acceptances from `- 0006.3` bullets or `SCENARIO: 0006.3` gherkin lines.
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
        var inGherkin = false
        for line in body.split(separator: "\n", omittingEmptySubsequences: false) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if inGherkin {
                if trimmed == "```" {
                    finish()
                    id = nil
                    inGherkin = false
                } else if let match = trimmed.wholeMatch(of: /SCENARIO:\s*([0-9]{4}\.[0-9]+)(?:\s.*)?/) {
                    finish()
                    id = String(match.output.1)
                    lines = []
                } else {
                    lines.append(line)
                }
            } else if trimmed == "```gherkin" {
                finish()
                id = nil
                inGherkin = true
            } else if let match = line.wholeMatch(of: /- ([0-9]{4}\.[0-9]+)\s*/) {
                finish()
                id = String(match.output.1)
                lines = []
            } else if line.first == " " || line.first == "\t" {
                lines.append(line)
            } else if !trimmed.isEmpty {
                finish()
                id = nil
                lines = []
            }
        }
        finish()
        return blocks
    }

    /// The words after "Then" on the block's Then line. A Gherkin THEN takes the AND and BUT lines
    /// right under it, joined as one sentence.
    private static func then(in lines: [Substring]) -> String {
        var then: String?
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if let found = then {
                guard let match = trimmed.wholeMatch(of: /(AND|BUT) (.+)/) else { break }
                then = found + " \(match.output.1.lowercased()) \(match.output.2)"
            } else if let match = line.firstMatch(of: /- Then (.+)/) {
                return String(match.output.1)
            } else if let match = trimmed.wholeMatch(of: /THEN (.+)/) {
                then = String(match.output.1)
            }
        }
        return then ?? ""
    }
}
