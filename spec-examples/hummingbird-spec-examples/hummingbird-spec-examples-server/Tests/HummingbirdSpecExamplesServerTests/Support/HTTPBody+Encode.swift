import NIOCore
import OpenAPIRuntime

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Convenience encoding helpers for test bodies.
extension HTTPBody {
    /// Encodes a value to JSON and returns an HTTP body.
    static func json<T: Encodable>(_ value: T) -> HTTPBody {
        // Encode to JSON bytes.
        let encoder = JSONEncoder()
        let data = (try? encoder.encode(value)) ?? Data()
        // Wrap in a ByteBuffer for OpenAPIRuntime.
        var buffer = ByteBufferAllocator().buffer(capacity: data.count)
        buffer.writeBytes(data)
        return HTTPBody(.init(buffer: buffer))
    }
}
