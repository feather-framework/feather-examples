import FeatherSpec
import HTTPTypes
import NIOCore
import OpenAPIRuntime
import XCTest
import NIOFoundationCompat

/// Wrapper to mark JSONDecoder as sendable for expectation closures.
private struct UnsafeDecoder: @unchecked Sendable {
    let decoder: JSONDecoder
}

/// Wrapper to mark closures as sendable for expectation closures.
private struct UnsafeBlock<Input>: @unchecked Sendable {
    let block: (Input) async throws -> Void
}

/// Helpers to collect response bodies in tests.
extension HTTPBody {

    /// Collects the entire body into a buffer.
    func collect() async throws -> ByteBuffer {
        var buffer = ByteBuffer()
        switch length {
        case .known(let value):
            // Read exactly the declared number of bytes.
            try await collect(upTo: Int(value), into: &buffer)
        case .unknown:
            // Stream chunks until completion.
            for try await chunk in self {
                buffer.writeBytes(chunk)
            }
        }
        return buffer
    }
}

/// Convenience accessors for buffers in tests.
extension ByteBuffer {

    /// Returns the full buffer as a UTF-8 string, if possible.
    var stringValue: String? {
        getString(at: 0, length: readableBytes)
    }
}

// MARK: - request method helpers

public struct BearerToken: SpecBuilderParameter {
    let token: String

    public init(
        _ token: String
    ) {
        self.token = token
    }

    /// Sets the authorization header using the bearer token.
    public func build(_ spec: inout Spec) {
        spec.setHeader(.authorization, "Bearer \(token)")
    }
}

/// Builder parameter for GET requests.
public struct GET: SpecBuilderParameter {
    let path: String?

    public init(
        _ path: String? = nil
    ) {
        self.path = path
    }

    public func build(_ spec: inout Spec) {
        spec.setMethod(.get)
        spec.setPath(path)
    }
}

/// Builder parameter for POST requests.
public struct POST: SpecBuilderParameter {
    let path: String?

    public init(
        _ path: String? = nil
    ) {
        self.path = path
    }

    public func build(_ spec: inout Spec) {
        spec.setMethod(.post)
        spec.setPath(path)
    }
}

/// Builder parameter for PUT requests.
public struct PUT: SpecBuilderParameter {
    let path: String?

    public init(
        _ path: String? = nil
    ) {
        self.path = path
    }

    public func build(_ spec: inout Spec) {
        spec.setMethod(.put)
        spec.setPath(path)
    }
}

/// Builder parameter for PATCH requests.
public struct PATCH: SpecBuilderParameter {
    let path: String?

    public init(
        _ path: String? = nil
    ) {
        self.path = path
    }

    public func build(_ spec: inout Spec) {
        spec.setMethod(.patch)
        spec.setPath(path)
    }
}

/// Builder parameter for HEAD requests.
public struct HEAD: SpecBuilderParameter {
    let path: String?

    public init(
        _ path: String? = nil
    ) {
        self.path = path
    }

    public func build(_ spec: inout Spec) {
        spec.setMethod(.head)
        spec.setPath(path)
    }
}

/// Builder parameter for DELETE requests.
public struct DELETE: SpecBuilderParameter {
    let path: String?

    public init(
        _ path: String? = nil
    ) {
        self.path = path
    }

    public func build(_ spec: inout Spec) {
        spec.setMethod(.delete)
        spec.setPath(path)
    }
}

// MARK: - JSON helpers

public struct JSONBody<T: Encodable>: SpecBuilderParameter {
    let body: HTTPBody

    public init(
        _ value: T,
        encoder: JSONEncoder? = nil
    ) {
        // Use ISO8601 dates unless an encoder is supplied.
        let encoder =
            encoder
            ?? {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                return encoder
            }()
        let data = try! encoder.encode(value)
        self.body = .init(.init(buffer: .init(data: data)))
    }

    /// Sets JSON content type and body on the spec.
    public func build(_ spec: inout Spec) {
        spec.setHeader(.contentType, "application/json")
        spec.setBody(body)
    }
}

/// Builder parameter for URL-encoded form bodies.
public struct FormBody: SpecBuilderParameter {
    let body: HTTPBody

    public init(_ value: String) {
        self.body = .init(value.data(using: .utf8)!)
    }

    /// Sets form content type and body on the spec.
    public func build(_ spec: inout Spec) {
        spec.setHeader(.contentType, "application/x-www-form-urlencoded")
        spec.setBody(body)
    }
}

/// Builder parameter for arbitrary binary bodies.
public struct BinaryBody: SpecBuilderParameter {
    let body: HTTPBody

    public init(_ value: ByteBuffer) {
        self.body = .init(value.readableBytesView)
    }

    /// Sets a wildcard content type and content length when known.
    public func build(_ spec: inout Spec) {
        spec.setHeader(.contentType, "*/*")

        if case .known(let length) = body.length {
            spec.setHeader(.contentLength, "\(length)")
        }

        spec.setBody(body)
    }
}

/// Builder parameter that validates a JSON response and decodes its body.
public struct JSONResponse<T: Decodable & Sendable>: SpecBuilderParameter {
    let status: HTTPResponse.Status
    let expectation: Expectation

    public init(
        file: StaticString = #file,
        line: UInt = #line,
        status: HTTPResponse.Status = .ok,
        type: T.Type,
        decoder: JSONDecoder? = nil,
        block: @escaping @Sendable ((T) async throws -> Void)
    ) {

        // Use ISO8601 dates unless a decoder is supplied.
        let decoder = decoder ?? {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return decoder
        }()
        let unsafeDecoder = UnsafeDecoder(decoder: decoder)
        let unsafeBlock = UnsafeBlock(block: block)
        self.status = status
        self.expectation = .init(block: { response, body in
            let buffer = try await body.collect()
            let object = try unsafeDecoder.decoder.decode(T.self, from: buffer)
            try await unsafeBlock.block(object)
        })
    }

    /// Adds status, content-type, and body decoding expectations.
    public func build(_ spec: inout Spec) {
        spec.addExpectation(status)
        spec.addExpectation(.contentType) { value in
            XCTAssertTrue(value.contains("application/json"))
        }
        spec.addExpectation(expectation.block)
    }
}

/// Builder parameter that validates a binary response.
public struct BinaryResponse: SpecBuilderParameter {
    let status: HTTPResponse.Status
    let expectation: Expectation

    public init(
        file: StaticString = #file,
        line: UInt = #line,
        status: HTTPResponse.Status = .ok,
        block: @escaping @Sendable ((ByteBuffer) async throws -> Void)
    ) {

        // Store the block in a sendable wrapper for expectation execution.
        let unsafeBlock = UnsafeBlock(block: block)
        self.status = status
        self.expectation = .init(block: { response, body in
            let buffer = try await body.collect()
            try await unsafeBlock.block(buffer)
        })
    }

    /// Adds status and body expectations.
    public func build(_ spec: inout Spec) {
        spec.addExpectation(status)
        spec.addExpectation(expectation.block)
    }
}
