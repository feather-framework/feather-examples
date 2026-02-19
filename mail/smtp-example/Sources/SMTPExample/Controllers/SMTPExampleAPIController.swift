import Foundation
import FeatherMail
import Hummingbird
import Logging

struct SMTPExampleAPIController {
    let mailClient: any MailClient
    let fromEmail: String
    let defaultToEmail: String
    let logger: Logger

    func sendMail(
        request: Request,
        context: AppRequestContext
    ) async throws -> HTTPResponse.Status {
        let payload = try await request.decode(
            as: SendMailRequest.self,
            context: context
        )
        let normalized = payload.email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
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
        let mail = Mail(
            from: Address(fromEmail, name: "SMTP Example"),
            to: [Address(recipient)],
            subject: "SMTP example mail",
            body: .plainText("This message was sent by smtp-example.")
        )
        try await mailClient.send(mail)
        logger.info("SMTP send succeeded", metadata: ["recipient": "\(recipient)"])
        return .accepted
    }
}

private struct SendMailRequest: Codable {
    let email: String?
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
