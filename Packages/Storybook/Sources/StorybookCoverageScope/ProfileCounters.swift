// cspell:ignore getsectiondata profraw prf cnts dyld globfree pathc pathv
import Darwin
import Foundation
import MachO

/// The LLVM coverage counters of every image loaded in this process, and the raw profiles they write.
/// It reads unofficial runtime internals, so when anything here is missing the tool runs the test alone.
enum ProfileCounters {
    /// Zeroes each loaded image's counter and bitmap sections, so the next profile shows one test alone.
    static func reset() {
        for index in 0..<_dyld_image_count() {
            guard let header = _dyld_get_image_header(index) else { continue }
            header.withMemoryRebound(to: mach_header_64.self, capacity: 1) { image in
                for section in ["__llvm_prf_cnts", "__llvm_prf_bits"] {
                    var size: UInt = 0
                    guard let start = getsectiondata(image, "__DATA", section, &size), size > 0 else { continue }
                    memset(start, 0, Int(size))
                }
            }
        }
    }

    /// The live raw profiles of this process, or of every process sharing its pattern, in continuous mode.
    /// Without that mode, which Xcode and the tool turn on, a file is stale, so it returns none.
    static func files(
        anyProcess: Bool = false, environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> [URL] {
        guard let pattern = environment["LLVM_PROFILE_FILE"], pattern.contains("%c") else { return [] }
        let expanded = glob(pattern, process: anyProcess ? nil : getpid(), environment: environment)
        var found = Darwin.glob_t()
        defer { globfree(&found) }
        guard Darwin.glob(expanded, 0, nil, &found) == 0 else { return [] }
        return (0..<Int(found.gl_pathc)).compactMap { index in
            found.gl_pathv[index].map { URL(filePath: String(cString: $0)) }
        }
    }

    /// The pattern as a shell glob, where `%p` is the process ID, or any ID without one. `%c` drops out,
    /// `%t` is the temporary folder, and any other placeholder matches anything.
    static func glob(_ pattern: String, process: pid_t?, environment: [String: String]) -> String {
        var out = ""
        var characters = pattern.makeIterator()
        while let character = characters.next() {
            guard character == "%" else {
                out += "*?[]\\".contains(character) ? "\\\(character)" : String(character)
                continue
            }
            var placeholder = characters.next()
            while let digit = placeholder, digit.isNumber { placeholder = characters.next() }
            switch placeholder {
            case "p": out += process.map(String.init) ?? "*"
            case "c", nil: break
            case "t": out += environment["TMPDIR"] ?? NSTemporaryDirectory()
            default: out += "*"
            }
        }
        return out
    }
}
