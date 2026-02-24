import FeatherStorage
import Foundation
import Hummingbird
import HTTPTypes
import Logging
import NIOCore

struct StreamUploadAccepted: Codable, Sendable {
    let receivedBytes: Int
}

struct FileStreamingController: Sendable {
    let storage: any StorageClient
    let objectKey: String

    func upload(
        request: Request,
        context: some RequestContext
    ) async throws -> Response {
        let sequence = StorageSequence(asyncSequence: request.body)

        do {
            try await storage.upload(
                key: objectKey,
                sequence: sequence
            )

            let receivedBytes = Int(try await storage.size(key: objectKey))
            let payload = StreamUploadAccepted(receivedBytes: receivedBytes)
            let bodyBuffer = try Self.encodeJSON(payload)

            var headers = HTTPFields()
            headers[.contentType] = "application/json"

            return Response(
                status: .created,
                headers: headers,
                body: .init(byteBuffer: bodyBuffer)
            )
        }
        catch let error {
            context.logger.error("Upload failed: \(String(describing: error))")
            throw HTTPError(.internalServerError)
        }
    }

    func download(
        request: Request,
        context: some RequestContext
    ) async throws -> Response {
        do {
            let sequence = try await storage.download(
                key: objectKey,
                range: nil
            )

            var headers = HTTPFields()
            headers[.contentType] = "application/octet-stream"

            return Response(
                status: .ok,
                headers: headers,
                body: .init(asyncSequence: sequence)
            )
        }
        catch let error {
            context.logger.error("Download failed: \(String(describing: error))")
            switch error {
            case .invalidKey:
                throw HTTPError(.notFound)
            case .invalidBuffer, .invalidMultipartChunk, .invalidMultipartId, .unknown:
                throw HTTPError(.internalServerError)
            }
        }
    }

    private static func encodeJSON<T: Encodable>(_ payload: T) throws -> ByteBuffer {
        let data = try JSONEncoder().encode(payload)
        var buffer = ByteBufferAllocator().buffer(capacity: data.count)
        buffer.writeBytes(data)
        return buffer
    }
}
