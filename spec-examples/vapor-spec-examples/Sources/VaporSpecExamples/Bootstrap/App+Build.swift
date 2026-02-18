import Vapor

public func buildApplication(
    environment: Environment = .testing
) async throws -> Application {
    let app = try await Application.make(environment)
    let store = InMemoryUserStore()
    let controller = VaporSpecExamplesUserController(store: store)
    try buildRoutes(app: app, controller: controller)
    return app
}
