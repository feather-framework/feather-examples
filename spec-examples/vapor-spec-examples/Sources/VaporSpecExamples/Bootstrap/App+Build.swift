import Vapor

public func buildApplication(
    environment: Environment = .testing
) async throws -> Application {
    let app = try await Application.make(environment)
    let store = InMemoryTodoStore()
    let controller = VaporSpecExamplesAPIController(store: store)
    try buildRoutes(app: app, controller: controller)
    return app
}
