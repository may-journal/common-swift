import StorybookKit
import SwiftUI

#if os(iOS)
    import UIKit
#endif

/// The one cover of the Storybook catalog. A shake, ⌥⌘⇧D on the Mac, `--storybook` at launch
/// and the Settings row open it once the gate has answered.
struct StorybookEntry: ViewModifier {
    @Bindable var availability: StorybookAvailability

    func body(content: Content) -> some View {
        content
            .task {
                await availability.resolve()
                availability.presentsLaunchRequest()
            }
            .onReceive(NotificationCenter.default.publisher(for: .storybookShake)) { _ in
                availability.presentsCatalog()
            }
            .storybookCover(isPresented: $availability.isCatalogPresented) {
                StorybookNavigator(availability: availability) {
                    availability.closesCatalog()
                }
                .defaultAppStorage(availability.defaults)
                .onAppear { availability.isCatalogOnScreen = true }
                .onDisappear { availability.catalogClosed() }
            }
            #if os(macOS)
                .background {
                    // The Mac has no shake: the same shortcut may-journals uses opens it.
                    Button(StorybookWords.name) { availability.presentsCatalog() }
                        .keyboardShortcut("d", modifiers: [.command, .option, .shift])
                        .hidden()
                }
            #endif
    }
}

extension View {
    /// Adds the Storybook catalog at the app's root, for every way in.
    public func storybookEntry(_ availability: StorybookAvailability) -> some View {
        modifier(StorybookEntry(availability: availability))
    }
}

// A file-scope private extension: its members are visible to StorybookEntry above.
private extension View {
    /// A full-screen cover on iOS. The Mac has none, so the catalog fills the window above the
    /// app instead.
    @ViewBuilder func storybookCover<Cover: View>(
        isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Cover
    ) -> some View {
        #if os(iOS)
            fullScreenCover(isPresented: isPresented, content: content)
        #else
            overlay {
                if isPresented.wrappedValue {
                    content().background(.background)
                }
            }
        #endif
    }
}

extension Notification.Name {
    /// Posted when the device is shaken, so a build the gate allows can open the catalog.
    public static let storybookShake = Notification.Name("StorybookShake")
}

#if os(iOS)
    // The Plan keeps the shake hook a UIWindow extension, as may-photos has it. An app or SDK
    // that overrides motionEnded on UIWindow too should post storybookShake itself.
    extension UIWindow {
        /// Turns a shake into `storybookShake`; the windows still pass every other motion on.
        override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake {
                NotificationCenter.default.post(name: .storybookShake, object: nil)
            }
            super.motionEnded(motion, with: event)
        }
    }
#endif
