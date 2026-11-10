import CoreGraphics

/// The spacing scale, smallest first, plus the margins and column width of a screen.
public struct Spacing: Sendable, Equatable {
    /// Between a title and the line under it.
    public var xSmall: CGFloat
    /// The space between items in a row.
    public var small: CGFloat
    /// The space inside a card or tile.
    public var medium: CGFloat
    /// Between the groups of a screen.
    public var large: CGFloat
    /// Around a centered status or hero.
    public var xLarge: CGFloat
    /// From the screen's side to its content on a narrow screen.
    public var margin: CGFloat
    /// From the screen's side to its content on a wide screen.
    public var wideMargin: CGFloat
    /// The widest a column of text grows before a line gets too long to read.
    public var readableWidth: CGFloat

    public init(
        xSmall: CGFloat = 4, small: CGFloat = 8, medium: CGFloat = 12, large: CGFloat = 24,
        xLarge: CGFloat = 40, margin: CGFloat = 16, wideMargin: CGFloat = 24,
        readableWidth: CGFloat = 720
    ) {
        self.xSmall = xSmall
        self.small = small
        self.medium = medium
        self.large = large
        self.xLarge = xLarge
        self.margin = margin
        self.wideMargin = wideMargin
        self.readableWidth = readableWidth
    }

    public static let standard = Spacing()
}

/// The corner radii, smallest first. Shapes draw them as continuous corners.
public struct Radii: Sendable, Equatable {
    /// The radius of tags, chips and small tiles.
    public var small: CGFloat
    /// The radius of buttons, fields and rows.
    public var medium: CGFloat
    /// The radius of cards and sheets.
    public var large: CGFloat

    public init(small: CGFloat = 8, medium: CGFloat = 12, large: CGFloat = 20) {
        self.small = small
        self.medium = medium
        self.large = large
    }

    public static let standard = Radii()
}
