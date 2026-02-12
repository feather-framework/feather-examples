import Foundation
import Logging
import FeatherMail
import FeatherSMTPMail
import NIO
import NIOSMTP
import ServiceLifecycle

/// Abstraction over outbound mail sending for easier testing.
protocol MailSender: Sendable {
    func send(email: String) async throws
}

/// SMTP-based sender using FeatherSMTPMail.
actor SMTPMailSender: MailSender, Service {
    let defaultToEmail: String
    let fromEmail: String
    let logger: Logger
    private let mailClient: SMTPMailClient
    private var isShutdown = false

    init(
        eventLoopGroup: any EventLoopGroup,
        host: String,
        port: Int,
        username: String,
        password: String,
        security: Security,
        fromEmail: String,
        defaultToEmail: String,
        logger: Logger
    ) {
        self.defaultToEmail = defaultToEmail
        self.fromEmail = fromEmail
        self.logger = logger

        let signInMethod: SignInMethod = if !username.isEmpty && !password.isEmpty {
            .credentials(username: username, password: password)
        } else {
            .anonymous
        }

        self.mailClient = SMTPMailClient(
            configuration: .init(
                hostname: host,
                port: port,
                signInMethod: signInMethod,
                security: security
            ),
            mailEncoder: RawMailEncoder(
                headerDateEncodingStrategy: {
                    formatRFC2822Date(Date())
                }
            ),
            eventLoopGroup: eventLoopGroup,
            logger: .init(label: "smtp-example.mail")
        )
    }

    func send(email: String) async throws {
        guard !self.isShutdown else {
            logger.error("Mail send rejected: sender is shutting down")
            throw MailError.custom("Mail sender is not available because it is shutting down.")
        }

        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let recipient = (normalized.isEmpty || !isValidEmail(normalized))
            ? defaultToEmail
            : normalized
        guard !recipient.isEmpty else {
            logger.error("Mail send rejected: recipient is empty and fallback is missing")
            throw MailError.custom("Recipient is empty and no fallback recipient is configured.")
        }
        if recipient == defaultToEmail {
            logger.info("Using fallback SMTP_TO recipient", metadata: ["recipient": "\(recipient)"])
        }
        let mail = makeDefaultMail(to: recipient)
        try await self.mailClient.send(mail)
        logger.info("SMTP send succeeded", metadata: ["recipient": "\(recipient)"])
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
        logger.info("SMTP sender shutdown completed")
    }

    private func makeDefaultMail(to recipientEmail: String) -> Mail {
        return Mail(
            from: Address(fromEmail, name: "SMTP Example"),
            to: [Address(recipientEmail)],
            subject: "SMTP example mail",
            body: .plainText("This message was sent by smtp-example.")
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
