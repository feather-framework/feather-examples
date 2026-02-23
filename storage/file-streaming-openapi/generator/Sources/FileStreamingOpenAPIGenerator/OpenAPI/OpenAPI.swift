import FeatherOpenAPI
import OpenAPIKit30

enum APIDocumentKind {
    case main
}

struct MyInfo: InfoRepresentable {
    var title: String { "Dummy File Streaming API" }
    var version: String { "1.0.0" }
    var description: String? { "Minimal example API for streaming upload/download." }
}

struct Location: LocationRepresentable {
    public var location: String

    init(_ location: String) {
        self.location = location
    }
}

struct ProductionServer: ServerRepresentable {
    var url: any LocationRepresentable { Location("https://api.example.com") }
}

struct ChunkSampleExample: ExampleRepresentable {
    var openAPIIdentifier: String { "chunkSample" }
    var summary: String? { "Single chunk payload example" }
    var value: AnyCodable { AnyCodable("hello world") }
}

struct FileStreamingPathCollection: PathCollectionRepresentable {
    var pathMap: PathMap {
        [
            "upload": UploadPathItem(),
            "download": DownloadPathItem(),
        ]
    }
}

struct FileStreamingComponents: ComponentsRepresentable {
    let base: FeatherOpenAPI.Components

    var schemas: OrderedDictionary<SchemaID, OpenAPISchemaRepresentable> { base.schemas }
    var parameters: OrderedDictionary<ParameterID, OpenAPIParameterRepresentable> { base.parameters }
    var responses: OrderedDictionary<ResponseID, OpenAPIResponseRepresentable> { base.responses }
    var requestBodies: OrderedDictionary<RequestBodyID, OpenAPIRequestBodyRepresentable> { base.requestBodies }
    var headers: OrderedDictionary<HeaderID, OpenAPIHeaderRepresentable> { base.headers }
    var securityRequirements: [SecurityRequirementRepresentable] { base.securityRequirements }

    var examples: OrderedDictionary<ExampleID, OpenAPIExampleRepresentable> {
        [
            ExampleID("chunkSample"): ChunkSampleExample(),
        ]
    }

    var links: OrderedDictionary<LinkID, OpenAPILinkRepresentable> { [:] }
}

struct MyDocument: DocumentRepresentable {
    var info: OpenAPIInfoRepresentable
    var paths: PathMap
    var components: OpenAPIComponentsRepresentable

    var servers: [any OpenAPIServerRepresentable] {
        [
            ProductionServer(),
        ]
    }
}

func buildDocument(
    kind: APIDocumentKind
) -> OpenAPI.Document {
    let collection = FileStreamingPathCollection()
    return MyDocument(
        info: MyInfo(),
        paths: collection.pathMap,
        components: FileStreamingComponents(base: collection.components)
    ).openAPIDocument()
}
