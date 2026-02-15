import Foundation
import FeatherMail
import Logging
import MailExampleOpenAPI

/// OpenAPI-backed controller implementation for mail send requests.
struct SESExampleAPIController: APIProtocol {
    let mailClient: any MailClient
    let fromEmail: String
    let defaultToEmail: String
    let logger: Logger

    /// Accepts nullable email payloads and forwards valid values to the mail sender.
    func sendMail(
        _ input: Operations.sendMail.Input
    ) async throws -> Operations.sendMail.Output {
        let payload: Components.Schemas.SendMailRequestSchema
        switch input.body {
        case let .json(value):
            payload = value
        }

        let normalized = payload.email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let recipient = (normalized.isEmpty || !isValidEmail(normalized))
            ? defaultToEmail
            : normalized
        guard !recipient.isEmpty else {
            logger.error("Mail send rejected: recipient is empty and fallback is missing")
            throw MailError.custom("Recipient is empty and no fallback recipient is configured.")
        }
        if recipient == defaultToEmail {
            logger.info("Using fallback SES_TO recipient", metadata: ["recipient": "\(recipient)"])
        }
        let mail = Mail(
            from: Address(fromEmail, name: "SES Example"),
            to: [Address(recipient)],
            subject: "SES example mail",
            body: .plainText("This message was sent by ses-example.")
        )
        try await mailClient.send(mail)
        logger.info("SES send succeeded", metadata: ["recipient": "\(recipient)"])
        return .accepted
    }
}

private func isValidEmail(_ value: String) -> Bool {
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
