import FeatherOpenAPI

struct TransferEncodingHeader: HeaderRepresentable {
    var description: String? { "Uses chunked transfer for streaming response data." }
    var schema: any OpenAPISchemaRepresentable { TransferEncodingHeaderValueSchema().reference() }
}
