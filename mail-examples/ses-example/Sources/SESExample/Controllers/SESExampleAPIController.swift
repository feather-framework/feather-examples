import Foundation
import MailExampleOpenAPI

/// OpenAPI-backed controller implementation for mail send requests.
struct SESExampleAPIController: APIProtocol {
    let sender: any MailSender

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
        let emailToSend = isValidEmail(normalized) ? normalized : ""

        try await sender.send(email: emailToSend)
        return .accepted
    }
}
