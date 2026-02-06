import Hummingbird
import OpenAPIHummingbird
import Logging
import ExampleOpenAPI
import FeatherDatabase
import FeatherPostgresDatabase

func buildRouter(
    database: PostgresDatabaseClient
) throws -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)

    router.addMiddleware {
        LogRequestsMiddleware(.info)
    }
    
    router.get("/") { _, _ in
        "Hello, World!"
    }
    
    let controller = ExampleAPIController(
        database: database
    )
    try controller.registerHandlers(on: router)
    
    return router
}


