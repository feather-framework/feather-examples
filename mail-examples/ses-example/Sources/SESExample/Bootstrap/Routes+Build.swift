import Hummingbird
import FeatherMail
import Logging
import MailExampleOpenAPI
import OpenAPIHummingbird

/// Builds the router and registers OpenAPI-generated handlers.
func buildRouter(
    mailClient: any MailClient,
    fromEmail: String,
    defaultToEmail: String,
    logger: Logger
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

    let controller = SESExampleAPIController(
        mailClient: mailClient,
        fromEmail: fromEmail,
        defaultToEmail: defaultToEmail,
        logger: logger
    )
    try controller.registerHandlers(on: router)

    return router
}
