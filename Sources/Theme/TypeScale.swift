import SwiftUI

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

    /// The platform's own sizes for each text style, which are smaller on the Mac.
    #if os(macOS)
    public static let standard = TypeScale(
        caption: TypeStep(size: 10, style: .caption), body: TypeStep(size: 13, style: .body),
        headline: TypeStep(size: 13, style: .headline), title: TypeStep(size: 22, style: .title))
    #else
    public static let standard = TypeScale(
        caption: TypeStep(size: 12, style: .caption), body: TypeStep(size: 17, style: .body),
        headline: TypeStep(size: 17, style: .headline), title: TypeStep(size: 28, style: .title))
    #endif
}

extension View {
    /// Sets this view's text in `step`, grown by the text size its environment holds.
    /// A Mac draws one size whatever the setting.
    public func font(
        _ step: TypeStep, weight: Font.Weight = .regular, design: Font.Design = .default
    ) -> some View {
        modifier(StepFont(step: step, weight: weight, design: design))
    }
}

private struct StepFont: ViewModifier {
    let weight: Font.Weight
    let design: Font.Design
    @ScaledMetric private var size: CGFloat

    init(step: TypeStep, weight: Font.Weight, design: Font.Design) {
        self.weight = weight
        self.design = design
        _size = ScaledMetric(wrappedValue: step.size, relativeTo: step.style)
    }

    func body(content: Content) -> some View {
        content.font(.system(size: size, weight: weight, design: design))
    }
}
