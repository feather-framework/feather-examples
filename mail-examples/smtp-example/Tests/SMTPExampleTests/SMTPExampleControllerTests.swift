@testable import SMTPExample
import Foundation
import FeatherMail
import FeatherMemoryMail
import Hummingbird
import HummingbirdTesting
import Logging
import NIOCore
import Testing

@Suite
struct SMTPExampleServerTests {

    private func makeTestApp(
        mailClient: MemoryMailClient
    ) throws -> Application<RouterResponder<AppRequestContext>> {
        let router = try buildRouter(
            mailClient: mailClient,
            fromEmail: "sender@example.com",
            defaultToEmail: "fallback@example.com",
            logger: Logger(label: "smtp-example.tests")
        )
        return Application(router: router)
    }

    private func executeSendMail(
        _ client: TestClientProtocol,
        email: String?
    ) async throws {
        let payload = if let email {
            #"{"email":"\#(email)"}"#
        } else {
            #"{"email":null}"#
        }
        var headers = HTTPFields()
        headers[.contentType] = "application/json"
        let body = ByteBufferAllocator().buffer(string: payload)
        try await client.execute(
            uri: "/mail/send",
            method: .post,
            headers: headers,
            body: body
        ) { response in
            #expect(response.status == .accepted)
        }
    }

    @Test
    func acceptsNullEmailAsFallback() async throws {
        let mailClient = MemoryMailClient()
        let app = try makeTestApp(mailClient: mailClient)

        try await app.test(.live) { client in
            try await executeSendMail(client, email: nil)
        }
        #expect(await mailClient.getMailbox().count == 1)
        #expect(await mailClient.getMailbox().first?.to.first?.email == "fallback@example.com")
    }

    @Test
    func sendsWhenEmailIsValid() async throws {
        let mailClient = MemoryMailClient()
        let app = try makeTestApp(mailClient: mailClient)

        try await app.test(.live) { client in
            try await executeSendMail(client, email: "user@example.com")
        }
        #expect(await mailClient.getMailbox().count == 1)
        #expect(await mailClient.getMailbox().first?.to.first?.email == "user@example.com")
    }

    @Test
    func fallsBackWhenEmailIsInvalid() async throws {
        let mailClient = MemoryMailClient()
        let app = try makeTestApp(mailClient: mailClient)

        try await app.test(.live) { client in
            try await executeSendMail(client, email: "invalid-email")
        }
        #expect(await mailClient.getMailbox().count == 1)
        #expect(await mailClient.getMailbox().first?.to.first?.email == "fallback@example.com")
    }
}
