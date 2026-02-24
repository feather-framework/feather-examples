import FeatherOpenAPI
import OpenAPIKit30

struct BinaryContentWithExample: ContentRepresentable {
    var schema: SchemaRepresentable { BinaryDataSchema() }

    func openAPIContent() -> OpenAPI.Content {
        .init(
            schema: schema.openAPISchema(),
            example: AnyCodable("hello world")
        )
    }

    var referencedSchemaMap: OrderedDictionary<SchemaID, OpenAPISchemaRepresentable> {
        schema.allReferencedSchemaMap()
    }
}
