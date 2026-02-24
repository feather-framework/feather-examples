import FeatherOpenAPI
import OpenAPIKit30

struct StreamUploadRequestBody: RequestBodyRepresentable {
    var contentMap: ContentMap {
        [
            .other("application/octet-stream"): BinaryContentWithExample(),
        ]
    }
}
