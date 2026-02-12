import Configuration
import Foundation
import Hummingbird
import Logging
import ServiceLifecycle

/// Shared request context type for the example server.
public typealias AppRequestContext = BasicRequestContext

enum AppConfigError: Error, LocalizedError {
    case missingKeys([String])
    case partialStaticCredentials

    var errorDescription: String? {
        switch self {
        case let .missingKeys(keys):
            return "Missing required configuration keys: \(keys.joined(separator: ", "))"
        case .partialStaticCredentials:
            return "Both SES_ID and SES_SECRET must be set together, or both left empty."
        }
    }
}

/// Builds a configured application instance for tests or the CLI entrypoint.
public func buildApplication(
    reader: ConfigReader
) async throws -> some ApplicationProtocol {
    var logger = Logger(label: "ses-example")
    logger.logLevel = reader.string(
        forKey: "log.level",
        as: Logger.Level.self,
        default: .info
    )

    let accessKeyId = reader.string(forKey: "SES_ID", default: "")
    let secretAccessKey = reader.string(forKey: "SES_SECRET", default: "")
    let region = reader.string(forKey: "SES_REGION", default: "").trimmingCharacters(in: .whitespacesAndNewlines)
    let fromEmail = reader.string(forKey: "SES_FROM", default: "").trimmingCharacters(in: .whitespacesAndNewlines)
    let defaultToEmail = reader.string(forKey: "SES_TO", default: "").trimmingCharacters(in: .whitespacesAndNewlines)

    var missingKeys: [String] = []
    if region.isEmpty { missingKeys.append("SES_REGION") }
    if fromEmail.isEmpty { missingKeys.append("SES_FROM") }
    if defaultToEmail.isEmpty { missingKeys.append("SES_TO") }
    guard missingKeys.isEmpty else {
        logger.error("Invalid SES configuration: missing required keys", metadata: ["keys": "\(missingKeys.joined(separator: ","))"])
        throw AppConfigError.missingKeys(missingKeys)
    }

    let hasId = !accessKeyId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    let hasSecret = !secretAccessKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    guard hasId == hasSecret else {
        logger.error("Invalid SES configuration: partial static credentials provided")
        throw AppConfigError.partialStaticCredentials
    }

    if hasId {
        logger.info("SES sender configured with static credentials")
    } else {
        logger.info("SES sender configured with default AWS credential provider chain")
    }

    let sender = SESMailSender(
        accessKeyId: accessKeyId,
        secretAccessKey: secretAccessKey,
        region: region,
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
        logger: logger
    )
    app.addServices(sender)
    return app
}
