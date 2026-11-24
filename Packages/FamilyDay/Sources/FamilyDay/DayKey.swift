import Foundation

/// One Gregorian day, which every app keys its part of the day by, written "2026-12-12" as
/// Captions keys its day line. Every app and device agree on it.
public struct DayKey: Hashable, Comparable, Sendable, CustomStringConvertible {
    public let year: Int
    public let month: Int
    public let day: Int

    /// The day a date falls on in `timeZone`, as Captions' day line keys it.
    public init(_ date: Date, timeZone: TimeZone = .current) {
        // The Gregorian calendar always sets all three parts.
        let parts = Self.calendar(timeZone).dateComponents([.year, .month, .day], from: date)
        year = parts.year ?? 1
        month = parts.month ?? 1
        day = parts.day ?? 1
    }

    /// Reads a key written "2026-12-12"; nil when the text names no real day.
    public init?(_ text: String) {
        let parts = text.split(separator: "-", omittingEmptySubsequences: false)
        guard parts.count == 3, parts.map(\.count) == [4, 2, 2],
            parts.allSatisfy({ $0.allSatisfy { $0.isASCII && $0.isNumber } }),
            let year = Int(parts[0]), let month = Int(parts[1]), let day = Int(parts[2])
        else { return nil }
        let components = DateComponents(year: year, month: month, day: day)
        guard components.isValidDate(in: Self.calendar(.gmt)) else { return nil }
        self.year = year
        self.month = month
        self.day = day
    }

    /// The key as Captions' day line writes it, such as "2026-12-12".
    public var description: String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }

    /// The start of the day in `timeZone`, which a person's own calendar then formats.
    public func date(in timeZone: TimeZone = .current) -> Date {
        Self.calendar(timeZone).date(from: DateComponents(year: year, month: month, day: day))
            ?? .distantPast
    }

    /// The Gregorian calendar in `timeZone`, which every key is written in.
    private static func calendar(_ timeZone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    public static func < (lhs: DayKey, rhs: DayKey) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}

extension DayKey: Codable {
    /// Decodes the key from its written form, so a stored row reads like the day line.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let text = try container.decode(String.self)
        guard let key = DayKey(text) else {
            throw DecodingError.dataCorruptedError(
                in: container, debugDescription: "\(text) names no day")
        }
        self = key
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
