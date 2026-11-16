import Foundation
import StorybookHistoryKit

// Writes the history of the repo holding the first argument's folder to the second argument's
// file, as the StorybookHistory plugin runs it. A repo without history writes none, and the
// catalog then shows no badges.
let arguments = CommandLine.arguments
guard arguments.count == 3 else {
    FileHandle.standardError.write(Data("usage: storybook-history <folder> <output.json>\n".utf8))
    exit(2)
}
let output = URL(filePath: arguments[2])
try? FileManager.default.removeItem(at: output)
if let history = StorybookHistoryReader.read(URL(filePath: arguments[1])) {
    try StorybookHistory.encoder.encode(history).write(to: output)
} else {
    // The build expects the file, so an empty object stands for no history.
    try Data("{}".utf8).write(to: output)
}
