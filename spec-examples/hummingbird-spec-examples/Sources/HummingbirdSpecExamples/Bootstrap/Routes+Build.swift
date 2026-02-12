import SpecExampleOpenAPI
import Hummingbird
import OpenAPIHummingbird

/// Builds the router and registers OpenAPI-generated handlers.
func buildRouter(
    store: InMemoryTodoStore
) throws -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)

    // Wire the controller implementation to generated routes.
    let controller = HummingbirdSpecExamplesAPIController(store: store)
    try controller.registerHandlers(on: router)

    return router
}
