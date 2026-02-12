import Foundation
import Logging
import FeatherMail
import FeatherSESMail
import ServiceLifecycle
import SotoCore
import SotoSESv2

/// Abstraction over outbound mail sending for easier testing.
protocol MailSender: Sendable {
    func send(email: String) async throws
}

enum MailSenderError: Error, LocalizedError {
    case emptyRecipient
    case unavailable
    case sendFailed(String)
    case shutdownFailed(String)

    var errorDescription: String? {
        switch self {
        case .emptyRecipient:
            return "Recipient is empty and no fallback recipient is configured."
        case .unavailable:
            return "Mail sender is not available because it is shutting down."
        case let .sendFailed(message):
            return "Failed to send email via SES: \(message)"
        case let .shutdownFailed(message):
            return "SES client shutdown failed: \(message)"
        }
    }
}

/// SES-based sender using FeatherSESMail.
actor SESMailSender: MailSender, Service {
    let defaultToEmail: String
    let fromEmail: String
    let logger: Logger
    private let awsClient: AWSClient
    private let mailClient: SESMailClient
    private var isShutdown = false

    init(
        accessKeyId: String,
        secretAccessKey: String,
        region: String,
        fromEmail: String,
        defaultToEmail: String,
        logger: Logger
    ) {
        self.defaultToEmail = defaultToEmail
        self.fromEmail = fromEmail
        self.logger = logger

        let credentialProvider: CredentialProviderFactory = if
            !accessKeyId.isEmpty && !secretAccessKey.isEmpty {
            .static(
                accessKeyId: accessKeyId,
                secretAccessKey: secretAccessKey
            )
        } else {
            .default
        }

        let awsClient = AWSClient(credentialProvider: credentialProvider)
        let ses = SESv2(client: awsClient, region: Region(rawValue: region))
        self.awsClient = awsClient
        self.mailClient = SESMailClient(
            ses: ses,
            encoder: RawMailEncoder(
                headerDateEncodingStrategy: {
                    formatRFC2822Date(Date())
                }
            ),
            logger: .init(label: "ses-example.mail")
        )
    }

    func send(email: String) async throws {
        guard !self.isShutdown else {
            logger.error("Mail send rejected: sender is shutting down")
            throw MailSenderError.unavailable
        }

        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let recipient = (normalized.isEmpty || !isValidEmail(normalized))
            ? defaultToEmail
            : normalized
        guard !recipient.isEmpty else {
            logger.error("Mail send rejected: recipient is empty and fallback is missing")
            throw MailSenderError.emptyRecipient
        }
        if recipient == defaultToEmail {
            logger.info("Using fallback SES_TO recipient", metadata: ["recipient": "\(recipient)"])
        }
        let mail = makeDefaultMail(to: recipient)

        do {
            try await self.mailClient.send(mail)
            logger.info("SES send succeeded", metadata: ["recipient": "\(recipient)"])
        }
        catch {
            logger.error("SES send failed", metadata: ["error": "\(error)"])
            throw MailSenderError.sendFailed(String(describing: error))
        }
    }

    func run() async throws {
        do {
            try await gracefulShutdown()
        }
        catch is CancellationError {
            // Task cancellation should still trigger shutdown.
        }

        do {
            try await shutdown()
        }
        catch {
            logger.error("Sender shutdown failed", metadata: ["error": "\(error)"])
            throw error
        }
    }

    private func shutdown() async throws {
        guard !self.isShutdown else {
            return
        }
        self.isShutdown = true

        do {
            try await self.awsClient.shutdown()
            logger.info("AWS client shutdown completed")
        }
        catch {
            logger.error("AWS client shutdown failed", metadata: ["error": "\(error)"])
            throw MailSenderError.shutdownFailed(String(describing: error))
        }
    }

    private func makeDefaultMail(to recipientEmail: String) -> Mail {
        return Mail(
            from: Address(fromEmail, name: "SES Example"),
            to: [Address(recipientEmail)],
            subject: "SES example mail",
            body: .plainText("This message was sent by ses-example.")
        )
    }
}

private func formatRFC2822Date(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
    return formatter.string(from: date)
}

/// Lightweight email validation used by the API controller.
func isValidEmail(_ value: String) -> Bool {
    let parts = value.split(separator: "@", omittingEmptySubsequences: false)
    guard parts.count == 2 else {
        return false
    }

    let local = parts[0]
    let domain = parts[1]
    guard !local.isEmpty, !domain.isEmpty else {
        return false
    }

    return domain.contains(".")
}
