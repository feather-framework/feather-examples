@testable import SMTPExample
import Foundation
import FeatherMail
import FeatherMemoryMail
import MailExampleOpenAPI
import Testing

actor MemoryBackedMailSender: MailSender {
    private let fallbackEmail: String
    private let client = MemoryMailClient()

    init(fallbackEmail: String = "fallback@example.com") {
        self.fallbackEmail = fallbackEmail
    }

    func send(email: String) async throws {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let recipient = (normalized.isEmpty || !isValidEmail(normalized))
            ? fallbackEmail
            : normalized

        let mail = Mail(
            from: .init("sender@example.com"),
            to: [.init(recipient)],
            subject: "test",
            body: .plainText("test")
        )
        try await client.send(mail)
    }

    func sentCount() async -> Int {
        await client.getMailbox().count
    }

    func firstRecipient() async -> String? {
        await client.getMailbox().first?.to.first?.email
    }
}

@Suite
struct SMTPExampleControllerTests {

    @Test
    func acceptsNullEmailAsNoop() async throws {
        let sender = MemoryBackedMailSender()
        let controller = SMTPExampleAPIController(sender: sender)

        let output = try await controller.sendMail(
            .init(body: .json(.init(email: nil)))
        )

        _ = try output.accepted
        #expect(await sender.sentCount() == 1)
        #expect(await sender.firstRecipient() == "fallback@example.com")
    }

    @Test
    func sendsWhenEmailIsValid() async throws {
        let sender = MemoryBackedMailSender()
        let controller = SMTPExampleAPIController(sender: sender)

        let output = try await controller.sendMail(
            .init(body: .json(.init(email: "user@example.com")))
        )

        _ = try output.accepted
        #expect(await sender.sentCount() == 1)
        #expect(await sender.firstRecipient() == "user@example.com")
    }

    @Test
    func fallsBackWhenEmailIsInvalid() async throws {
        let sender = MemoryBackedMailSender()
        let controller = SMTPExampleAPIController(sender: sender)

        let output = try await controller.sendMail(
            .init(body: .json(.init(email: "invalid-email")))
        )

        _ = try output.accepted
        #expect(await sender.sentCount() == 1)
        #expect(await sender.firstRecipient() == "fallback@example.com")
    }
}
