import Foundation
import Navigation

/// The routes a small diary app would define, as a consumer of the package does.
enum ExampleRoute: Hashable, Linkable {
    case day(String)
    case entry(UUID)
    case settings

    var deepLink: DeepLink {
        switch self {
        case .day(let key): DeepLink(host: "day", path: [key])
        case .entry(let id): DeepLink(host: "entry", path: [id.uuidString])
        case .settings: DeepLink(host: "settings")
        }
    }

    static let links = DeepLinkTable<ExampleRoute>(
        scheme: "example",
        parsers: [
            "day": { link in link.path.first.map(ExampleRoute.day) },
            "entry": { link in
                link.path.first.flatMap(UUID.init(uuidString:)).map(ExampleRoute.entry)
            },
            "settings": { _ in .settings },
        ]
    )
}

/// The example app's state: its router, its held requests, and the entry being written.
@Observable
@MainActor
final class Diary {
    struct SaveFailed: Error {}

    let router: Router<ExampleRoute>
    let requests = PendingOpen<ExampleRoute>()
    /// The route a link named whose content is gone, shown as "Not Found".
    var missing: ExampleRoute?
    var deleted: Set<ExampleRoute> = []
    var draft: String?
    var saved: String?
    var saveFails = false
    @ObservationIgnored lazy var leaving = LeaveGuard<Bool>(
        hasUnsavedWork: { [unowned self] in draft != nil },
        perform: { [unowned self] _ in router.pop() })

    init(path: [ExampleRoute] = []) {
        router = Router(path: path)
    }

    /// What `onOpenURL` calls: the link opens, or says its content is gone.
    func open(_ url: URL) {
        let opening = router.open(url, with: ExampleRoute.links) { [deleted] route in
            !deleted.contains(route)
        }
        if case .notFound(let route) = opening {
            missing = route
        }
    }

    func save() throws {
        if saveFails { throw SaveFailed() }
        saved = draft
        draft = nil
    }
}
