import HTTPTypes
import OpenAPIRuntime

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Convenience decoding helpers for test bodies.
extension HTTPBody {
    /// Decodes the body as JSON using the `Content-Length` header.
    func decode<T: Decodable>(
        _ type: T.Type,
        with response: HTTPResponse
    ) async throws -> T {
        // Use content length to collect the response data.
        let length = Int(response.headerFields[.contentLength] ?? "0") ?? 0
        let data = try await Data(collecting: self, upTo: Int(length))
        // Decode the JSON payload into the expected type.
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
