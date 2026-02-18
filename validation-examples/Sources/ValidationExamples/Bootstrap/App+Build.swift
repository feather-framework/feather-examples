import Hummingbird

public typealias AppRequestContext = BasicRequestContext

// Creates the application with in-memory storage and registered routes.
public func buildApplication() async throws -> some ApplicationProtocol {
    let store = InMemoryUserStore()
    let router = try buildRouter(store: store)
    return Application(router: router)
}
