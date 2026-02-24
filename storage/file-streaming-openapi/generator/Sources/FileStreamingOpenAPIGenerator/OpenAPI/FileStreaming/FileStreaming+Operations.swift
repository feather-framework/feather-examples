import FeatherOpenAPI
import OpenAPIKit30

struct StreamUploadOperation: OperationRepresentable {
    var tags: [TagRepresentable] { [FileStreamingTag()] }
    var summary: String? { "Upload file as a chunked stream" }
    var operationId: String? { "streamUpload" }
    var requestBody: RequestBodyRepresentable? { StreamUploadRequestBody() }
    var responseMap: ResponseMap {
        [
            201: StreamUploadAcceptedResponse(),
        ]
    }
}

struct StreamDownloadOperation: OperationRepresentable {
    var tags: [TagRepresentable] { [FileStreamingTag()] }
    var summary: String? { "Download file as a chunked stream" }
    var operationId: String? { "streamDownload" }
    var responseMap: ResponseMap {
        [
            200: StreamDownloadResponse(),
        ]
    }
}
