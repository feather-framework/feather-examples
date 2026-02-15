import Configuration
import Foundation
import Hummingbird
import Logging
import ServiceLifecycle
import FeatherMail
import FeatherSMTPMail
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
    let signInMethod: SignInMethod = .credentials(
        username: username,
        password: password
    )
    let mailClient = SMTPMailClient(
        configuration: .init(
            hostname: host,
            port: 587,
            signInMethod: signInMethod,
            security: .startTLS
        ),
        mailEncoder: RawMailEncoder(
            headerDateEncodingStrategy: {
                formatRFC2822Date(Date())
            }
        ),
        eventLoopGroup: eventLoopGroup,
        logger: .init(label: "smtp-example.mail")
    )
    let router = try buildRouter(
        mailClient: mailClient,
        fromEmail: fromEmail,
        defaultToEmail: defaultToEmail,
        logger: logger
    )
    var appConfiguration = ApplicationConfiguration(
        reader: reader.scoped(to: "http")
    )
    appConfiguration.address = .hostname("127.0.0.1", port: 8081)
    let app = Application(
        router: router,
        configuration: appConfiguration,
        eventLoopGroupProvider: .shared(eventLoopGroup),
        logger: logger
    )
    return app
}

private func formatRFC2822Date(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
    return formatter.string(from: date)
}
