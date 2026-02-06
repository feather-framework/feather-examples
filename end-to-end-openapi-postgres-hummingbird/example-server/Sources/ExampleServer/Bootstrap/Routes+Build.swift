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
        CORSMiddleware(
            allowOrigin: .originBased,
            allowHeaders: [
                .accept,
                .authorization,
                .contentType,
                .origin,
            ],
            allowMethods: [
                .get,
                .post,
                .delete,
                .patch,
                .put,
            ],
        )
    }

    router.get("/health") { _, _ in
        Response(status: .ok)
    }
    
    let controller = ExampleAPIController(
        database: database
    )
    try controller.registerHandlers(
        on: router,
    )
    
    return router
}


