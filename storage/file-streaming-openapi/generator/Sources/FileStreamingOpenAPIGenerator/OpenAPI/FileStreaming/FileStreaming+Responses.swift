import FeatherOpenAPI
import OpenAPIKit30

struct StreamUploadAcceptedResponse: JSONResponseRepresentable {
    var description: String = "Chunk accepted"
    var schema: StreamUploadAcceptedSchema = .init()

    var headerMap: HeaderMap {
        [
            "Transfer-Encoding": TransferEncodingHeader(),
        ]
    }
}

struct StreamDownloadResponse: BinaryResponseRepresentable {
    var description: String = "Chunked stream response"

    var headerMap: HeaderMap {
        [
            "Transfer-Encoding": TransferEncodingHeader(),
        ]
    }
}
