import Hummingbird
import OpenAPIHummingbird
import Logging
import ExampleOpenAPI

func buildRouter(
//    db: SQLiteDatabaseClient
) throws -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)

    router.addMiddleware {
        LogRequestsMiddleware(.info)
    }
    
    router.get("/") { _, _ in
        "Hello, World!"
    }
    
    let controller = ExampleAPIController()
    try controller.registerHandlers(on: router)
    
    return router
}


