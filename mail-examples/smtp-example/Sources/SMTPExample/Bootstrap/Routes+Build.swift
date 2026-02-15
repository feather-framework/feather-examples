import Hummingbird
import FeatherMail
import Logging
import MailExampleOpenAPI
import OpenAPIHummingbird

func configureRouter(
    _ router: Router<AppRequestContext>,
    mailClient: any MailClient,
    fromEmail: String,
    defaultToEmail: String,
    logger: Logger
) throws {
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

    let controller = SMTPExampleAPIController(
        mailClient: mailClient,
        fromEmail: fromEmail,
        defaultToEmail: defaultToEmail,
        logger: logger
    )
    try controller.registerHandlers(on: router)
}

/// Builds the router and registers OpenAPI-generated handlers.
func buildRouter(
    mailClient: any MailClient,
    fromEmail: String,
    defaultToEmail: String,
    logger: Logger
) throws -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)
    try configureRouter(
        router,
        mailClient: mailClient,
        fromEmail: fromEmail,
        defaultToEmail: defaultToEmail,
        logger: logger
    )
    return router
}
