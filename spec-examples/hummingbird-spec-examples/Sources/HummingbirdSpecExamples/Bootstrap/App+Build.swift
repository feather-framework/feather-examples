import Hummingbird

public typealias AppRequestContext = BasicRequestContext

public func buildApplication() async throws -> some ApplicationProtocol {
    let store = InMemoryUserStore()
    let router = try buildRouter(store: store)
    return Application(router: router)
}
