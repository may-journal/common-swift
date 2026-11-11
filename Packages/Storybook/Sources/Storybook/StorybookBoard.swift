import Foundation
import SwiftUI

/// What a board holds: one page filling the device's screen, or a grid of cards growing down
/// as far as they go.
enum StorybookBoardContent {
    case page, grid
}

/// A page or grid draws in the pane on Auto, or a true-size device frame under a fixed bar
/// with the rotate button. That bar names the device, and the frame centres when it fits or
/// scrolls when not, like a Mac on an iPhone.
struct StorybookBoard<Content: View>: View {
    let kind: StorybookBoardContent
    /// Where a board too big for the pane starts scrolled to.
    let anchor: UnitPoint
    /// Builds the content for the width it lays out in.
    @ViewBuilder let content: (CGFloat) -> Content

    @AppStorage(StorybookDevice.storageKey) private var device: StorybookDevice = .auto
    @AppStorage(StorybookOrientation.storageKey)
    private var orientation: StorybookOrientation = .portrait

    var body: some View {
        if let canvas = device.canvasSize(orientation) {
            VStack(spacing: 0) {
                deviceBar
                GeometryReader { pane in
                    ScrollView([.horizontal, .vertical]) {
                        framed(canvas)
                            .padding(StorybookLayout.gap)
                            .frame(minWidth: pane.size.width, minHeight: pane.size.height)
                    }
                    .defaultScrollAnchor(anchor)
                }
                .background(Color.storybookDesk)
            }
        } else {
            GeometryReader { pane in
                switch kind {
                case .page:
                    content(pane.size.width)
                case .grid:
                    ScrollView { content(pane.size.width) }
                        .background(Color.storybookGrid)
                }
            }
        }
    }

    private var deviceBar: some View {
        Text(device.label(orientation))
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)
            .accessibilityIdentifier("storybook.board.device")
            .frame(maxWidth: .infinity, minHeight: 36)
            .overlay(alignment: .trailing) {
                StorybookRotateToggle()
                    .labelStyle(.iconOnly)
                    .padding(.horizontal, StorybookLayout.gap)
            }
            .background(.bar)
    }

    /// The content at the device's width; a page also takes its height. A page sits in a still
    /// scroll view, so a view sized to its container gets the device's width, not the pane's.
    private func framed(_ canvas: CGSize) -> some View {
        Group {
            if kind == .page {
                ScrollView([]) { content(canvas.width) }
            } else {
                content(canvas.width)
            }
        }
        .frame(width: canvas.width, height: kind == .page ? canvas.height : nil, alignment: .top)
        .frame(minHeight: canvas.height, alignment: .top)
        .background(kind == .page ? Color.storybookPage : Color.storybookGrid)
        .overlay { Rectangle().strokeBorder(.separator) }
    }
}

/// Where a board too big for the pane starts scrolled to. Leading unless the launch says
/// `--storybook-board-anchor trailing` (or `center`), so a capture can show either edge.
enum StorybookBoardAnchor {
    static func anchor(in arguments: [String]) -> UnitPoint {
        switch StorybookLaunchArgument.value(after: "--storybook-board-anchor", in: arguments) {
        case "trailing": .topTrailing
        case "center": .top
        default: .topLeading
        }
    }
}
