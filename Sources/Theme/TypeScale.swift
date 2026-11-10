import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// One step of a type scale: a point size and the text style it grows with.
public struct TypeStep: Sendable, Equatable {
    /// The size at the standard text size, in points.
    public var size: CGFloat
    /// The text style whose Dynamic Type setting scales this step.
    public var style: Font.TextStyle

    public init(size: CGFloat, style: Font.TextStyle) {
        self.size = size
        self.style = style
    }

    /// This step as a system font, grown by the person's text size on iOS.
    public func font(weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        #if canImport(UIKit)
        let metrics = UIFontMetrics(forTextStyle: style.uiTextStyle)
        return .system(size: metrics.scaledValue(for: size), weight: weight, design: design)
        #else
        return .system(size: size, weight: weight, design: design)
        #endif
    }
}

/// The type scale shared views pick from, never a literal point size.
public struct TypeScale: Sendable, Equatable {
    /// The step for timestamps, chips and the smallest metadata.
    public var caption: TypeStep
    /// The step for running text.
    public var body: TypeStep
    /// The step for the title of a card or a status.
    public var headline: TypeStep
    /// The step for the title of a screen.
    public var title: TypeStep

    public init(caption: TypeStep, body: TypeStep, headline: TypeStep, title: TypeStep) {
        self.caption = caption
        self.body = body
        self.headline = headline
        self.title = title
    }

    /// The system's sizes for each text style.
    public static let standard = TypeScale(
        caption: TypeStep(size: 12, style: .caption), body: TypeStep(size: 17, style: .body),
        headline: TypeStep(size: 17, style: .headline), title: TypeStep(size: 28, style: .title))
}

#if canImport(UIKit)
extension Font.TextStyle {
    fileprivate var uiTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle: .largeTitle
        case .title: .title1
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .subheadline: .subheadline
        case .callout: .callout
        case .footnote: .footnote
        case .caption: .caption1
        case .caption2: .caption2
        default: .body
        }
    }
}
#endif
