import Hummingbird

/// Shared request context type for the example server.
public typealias AppRequestContext = BasicRequestContext

/// Builds a configured application instance for tests or the CLI entrypoint.
public func buildApplication() async throws -> some ApplicationProtocol {
    // In-memory store keeps the example self-contained.
    let store = InMemoryTodoStore()
    // Wire routes to the controller backed by the store.
    let router = try buildRouter(store: store)
    // Create the application from the router.
    return Application(router: router)
}
