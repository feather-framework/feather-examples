import Foundation
import Hummingbird
import HummingbirdTesting
import NIOCore
import Testing

@testable import ValidationExamples

// Test utilities for app bootstrapping, payload encoding, and response assertions.
enum ValidationExamplesTestHelpers {
    static let jsonEncoder = JSONEncoder()
    static let jsonDecoder = JSONDecoder()

    // Builds a fresh in-memory app instance for each test.
    static func makeApp() async throws -> any ApplicationProtocol {
        try await buildApplication()
    }

    // Encodes a value into a request body buffer.
    static func jsonBuffer<T: Encodable>(_ value: T) throws -> ByteBuffer {
        let data = try jsonEncoder.encode(value)
        var buffer = ByteBufferAllocator().buffer(capacity: data.count)
        buffer.writeBytes(data)
        return buffer
    }

    // Decodes a response body buffer into a concrete payload type.
    static func decode<T: Decodable>(_ type: T.Type, from body: ByteBuffer) throws -> T {
        try jsonDecoder.decode(type, from: Data(body.readableBytesView))
    }

    // Asserts the standard validation response shape and expected error keys.
    static func expectValidationErrorKeys(
        _ response: TestResponse,
        keys: [String]
    ) throws {
        // Shared assertion for 422 validation payload shape.
        #expect(response.status == .unprocessableContent)
        let error = try decode(ValidationErrorResponse.self, from: response.body)
        for key in keys {
            #expect(error.errors.contains(where: { $0.key == key }))
        }
    }

    // Creates a user through the HTTP API and returns the decoded model.
    static func createUser(
        app: any ApplicationProtocol,
        name: String = "Alex",
        email: String = "alex@example.com",
        age: Int = 32,
        role: String = "member",
        inviteCode: String = "AB12CD34",
        username: String = "user-alx-id",
        trustScore: Int = 50,
        loginCount: Int = 0,
        isActive: Bool = true
    ) async throws -> User {
        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try jsonBuffer(
                    UserCreateRequest(
                        name: name,
                        email: email,
                        age: age,
                        role: role,
                        inviteCode: inviteCode,
                        username: username,
                        trustScore: trustScore,
                        loginCount: loginCount,
                        isActive: isActive
                    )
                )
            )

            guard response.status == .created else {
                throw ValidationCreateError.unexpectedStatus(response.status)
            }
            return try decode(User.self, from: response.body)
        }
    }
}

enum ValidationCreateError: Error {
    // Raised when helper create requests do not return a `201` response.
    case unexpectedStatus(HTTPResponse.Status)
}
