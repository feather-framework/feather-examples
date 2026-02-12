import Configuration
import Foundation
import Hummingbird
import Logging
import ServiceLifecycle
import NIOSMTP

/// Shared request context type for the example server.
public typealias AppRequestContext = BasicRequestContext

enum AppConfigError: Error, LocalizedError {
    case missingKeys([String])

    var errorDescription: String? {
        switch self {
        case let .missingKeys(keys):
            return "Missing required configuration keys: \(keys.joined(separator: ", "))"
        }
    }
}

/// Builds a configured application instance for tests or the CLI entrypoint.
public func buildApplication(
    reader: ConfigReader
) async throws -> some ApplicationProtocol {
    var logger = Logger(label: "smtp-example")
    logger.logLevel = reader.string(
        forKey: "log.level",
        as: Logger.Level.self,
        default: .info
    )

    let host = reader.string(forKey: "SMTP_HOST", default: "").trimmingCharacters(in: .whitespacesAndNewlines)
    let username = reader.string(forKey: "SMTP_USER", default: "").trimmingCharacters(in: .whitespacesAndNewlines)
    let password = reader.string(forKey: "SMTP_PASS", default: "").trimmingCharacters(in: .whitespacesAndNewlines)
    let fromEmail = reader.string(forKey: "SMTP_FROM", default: "").trimmingCharacters(in: .whitespacesAndNewlines)
    let defaultToEmail = reader.string(forKey: "SMTP_TO", default: "").trimmingCharacters(in: .whitespacesAndNewlines)

    var missingKeys: [String] = []
    if host.isEmpty { missingKeys.append("SMTP_HOST") }
    if username.isEmpty { missingKeys.append("SMTP_USER") }
    if password.isEmpty { missingKeys.append("SMTP_PASS") }
    if fromEmail.isEmpty { missingKeys.append("SMTP_FROM") }
    if defaultToEmail.isEmpty { missingKeys.append("SMTP_TO") }
    guard missingKeys.isEmpty else {
        logger.error("Invalid SMTP configuration: missing required keys", metadata: ["keys": "\(missingKeys.joined(separator: ","))"])
        throw AppConfigError.missingKeys(missingKeys)
    }

    logger.info("SMTP sender configured with credential authentication")
    let eventLoopGroup = EventLoopGroupProvider.singleton.eventLoopGroup

    let sender = SMTPMailSender(
        eventLoopGroup: eventLoopGroup,
        host: host,
        port: 587,
        username: username,
        password: password,
        security: .startTLS,
        fromEmail: fromEmail,
        defaultToEmail: defaultToEmail,
        logger: logger
    )
    let router = try buildRouter(sender: sender)
    var app = Application(
        router: router,
        configuration: ApplicationConfiguration(
            reader: reader.scoped(to: "http")
        ),
        eventLoopGroupProvider: .shared(eventLoopGroup),
        logger: logger
    )
    app.addServices(sender)
    return app
}
