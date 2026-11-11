import SwiftUI

/// The header's buttons, in the order every detail page shows them, each stepping one value
/// per tap. A long press or right click on device, text size or data length opens a menu.
struct StorybookHeaderToggles: View {
    @Binding var appearance: ColorScheme?

    var body: some View {
        StorybookDeviceToggle()
        StorybookTextSizeToggle()
        StorybookDataLengthToggle()
        StorybookAppearanceToggle(appearance: $appearance)
    }
}

/// Steps the device frame through Auto, iPhone, iPhone Duo, iPad and Mac, showing the
/// device. Each new device starts in its usual orientation.
struct StorybookDeviceToggle: View {
    @AppStorage(StorybookDevice.storageKey) private var device: StorybookDevice = .auto
    @AppStorage(StorybookOrientation.storageKey)
    private var orientation: StorybookOrientation = .portrait

    var body: some View {
        Button {
            choose(device.next)
        } label: {
            storybookLabel(StorybookWords.device, device.symbol)
        }
        .contextMenu { storybookPicker(Binding(get: { device }, set: choose)) }
        .accessibilityValue(
            Text(device == .auto ? StorybookWords.autoDevice : device.label(orientation))
        )
        .accessibilityIdentifier("storybook.page.device.toggle")
    }

    private func choose(_ next: StorybookDevice) {
        device = next
        orientation = next.defaultOrientation
    }
}

/// Turns the device frame between portrait and landscape; the icon fills in landscape. Only a
/// device frame shows it: Auto draws on the screen as it is held, so there is nothing to turn.
struct StorybookRotateToggle: View {
    @AppStorage(StorybookOrientation.storageKey)
    private var orientation: StorybookOrientation = .portrait

    var body: some View {
        Button {
            orientation = orientation.next
        } label: {
            storybookLabel(StorybookWords.rotate, "rotate.right")
                .symbolVariant(orientation == .landscape ? .fill : .none)
        }
        .accessibilityValue(Text(orientation.name))
        .accessibilityIdentifier("storybook.page.rotate.toggle")
    }
}

/// Steps the previews' text through Default, Large and Largest. The icon fills while the
/// previews draw larger than the device's own size.
struct StorybookTextSizeToggle: View {
    @AppStorage(StorybookTextSize.storageKey) private var textSize: StorybookTextSize = .default

    var body: some View {
        Button {
            textSize = textSize.next
        } label: {
            storybookLabel(StorybookWords.textSize, "character.circle")
                .symbolVariant(textSize == .default ? .none : .fill)
        }
        .contextMenu { storybookPicker($textSize) }
        .accessibilityValue(Text(textSize.name))
        .accessibilityIdentifier("storybook.page.textSize.toggle")
    }
}

/// Steps the sample data through Empty, Short and Long.
struct StorybookDataLengthToggle: View {
    @AppStorage(PreviewDataLength.storageKey) private var length: PreviewDataLength = .short

    var body: some View {
        Button {
            length = length.next
        } label: {
            storybookLabel(StorybookWords.dataLength, symbol)
        }
        .contextMenu { storybookPicker($length) }
        .accessibilityValue(Text(length.name))
        .accessibilityIdentifier("storybook.page.dataLength.toggle")
    }

    private var symbol: String {
        switch length {
        case .empty: "text.page.slash"
        case .short: "text.alignleft"
        case .long: "text.justify.left"
        }
    }
}

/// Flips the whole catalog between light and dark.
struct StorybookAppearanceToggle: View {
    @Binding var appearance: ColorScheme?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button {
            appearance = colorScheme == .dark ? .light : .dark
        } label: {
            storybookLabel(StorybookWords.appearance, colorScheme == .dark ? "moon" : "sun.max")
        }
        .accessibilityValue(Text(colorScheme == .dark ? StorybookWords.dark : StorybookWords.light))
        .accessibilityIdentifier("storybook.page.appearance.toggle")
    }
}

/// A header button's name and symbol.
func storybookLabel(_ title: String, _ symbol: String) -> some View {
    Label {
        Text(title)
    } icon: {
        Image(systemName: symbol)
    }
}

private func storybookPicker<Value: StorybookSetting>(_ value: Binding<Value>) -> some View {
    Picker(selection: value) {
        ForEach(Value.allCases, id: \.self) { option in
            Text(option.name).tag(option)
        }
    } label: {
        EmptyView()
    }
}
