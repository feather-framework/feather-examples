import Hummingbird
import FeatherMail
import Logging

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
    router.post("/mail/send", use: { request, context in
        try await controller.sendMail(request: request, context: context)
    })
}

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
