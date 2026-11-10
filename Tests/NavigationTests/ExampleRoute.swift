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

/// Where the entry screen was asked to go: back, or to a route a link or request named.
enum Exit: Equatable {
    case back
    case open(ExampleRoute)
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
    var saveError: Error?
    @ObservationIgnored lazy var leaving = LeaveGuard<Exit>(
        hasUnsavedWork: { [unowned self] in draft != nil },
        perform: { [unowned self] exit in
            switch exit {
            case .back: router.pop()
            case .open(let route): router.show(route)
            }
        })

    init(path: [ExampleRoute] = []) {
        router = Router(path: path)
    }

    /// What `onOpenURL` calls: through the leave guard, or "Not Found" for gone content.
    func open(_ url: URL) {
        let opening = router.resolve(url, with: ExampleRoute.links) { [deleted] route in
            !deleted.contains(route)
        }
        switch opening {
        case .opened(let route): leaving.request(.open(route))
        case .notFound(let route): missing = route
        case .notOurs: break
        }
    }

    func save() throws {
        if saveFails { throw SaveFailed() }
        saved = draft
        draft = nil
    }

    /// The prompt's Save: a failure stays on the entry and says so.
    func saveThenLeave() async {
        do {
            try await leaving.saveThenLeave { try save() }
        } catch {
            saveError = error
        }
    }
}
