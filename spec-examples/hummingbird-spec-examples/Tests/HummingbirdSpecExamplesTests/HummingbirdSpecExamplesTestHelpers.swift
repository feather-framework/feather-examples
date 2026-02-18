import FeatherSpec
import FeatherHummingbirdSpec
import HTTPTypes
import Hummingbird
import HummingbirdTesting
import OpenAPIRuntime
import Foundation
import NIOCore

@testable import HummingbirdSpecExamples

enum HummingbirdSpecExamplesTestHelpers {
    static let jsonEncoder = JSONEncoder()
    static let jsonDecoder = JSONDecoder()

    static func makeAppAndRunner() async throws -> (any ApplicationProtocol, HummingbirdSpecRunner) {
        let app = try await buildApplication()
        return (app, HummingbirdSpecRunner(app: app, testingSetup: .router))
    }

    static func jsonBody<T: Encodable>(_ value: T) throws -> HTTPBody {
        let data = try jsonEncoder.encode(value)
        return HTTPBody(data)
    }

    static func decode<T: Decodable>(_ type: T.Type, body: HTTPBody, response: HTTPResponse) async throws -> T {
        if let contentLength = response.headerFields[.contentLength], let maxBytes = Int(contentLength) {
            let data = try await Data(collecting: body, upTo: maxBytes)
            return try jsonDecoder.decode(type, from: data)
        }

        var bytes: [UInt8] = []
        for try await chunk in body {
            bytes.append(contentsOf: chunk)
        }
        return try jsonDecoder.decode(type, from: Data(bytes))
    }

    static func createUser(
        app: any ApplicationProtocol,
        name: String = "Alex",
        email: String = "alex@example.com",
        isActive: Bool = true
    ) async throws -> User {
        try await app.test(.router) { client in
            let data = try jsonEncoder.encode(
                UserCreateRequest(name: name, email: email, isActive: isActive)
            )
            var body = ByteBufferAllocator().buffer(capacity: data.count)
            body.writeBytes(data)
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: body
            )
            guard response.status == .created else {
                throw Spec.Failure.status(response.status)
            }
            return try jsonDecoder.decode(User.self, from: Data(response.body.readableBytesView))
        }
    }
}
