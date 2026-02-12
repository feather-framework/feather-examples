import Hummingbird
import MailExampleOpenAPI
import OpenAPIHummingbird

/// Builds the router and registers OpenAPI-generated handlers.
func buildRouter(
    sender: any MailSender
) throws -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)

    router.addMiddleware {
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
                .options,
            ]
        )
    }

    let controller = SMTPExampleAPIController(sender: sender)
    try controller.registerHandlers(on: router)

    return router
}
