import FeatherOpenAPI
import OpenAPIKit30

struct BinaryDataSchema: SchemaRepresentable {
    func openAPISchema() -> JSONSchema {
        .string(format: .binary)
    }

    var referencedSchemaMap: OrderedDictionary<SchemaID, OpenAPISchemaRepresentable> {
        [:]
    }
}

struct TransferEncodingHeaderValueSchema: StringSchemaRepresentable {
    var allowedValues: [String]? { ["chunked"] }
}

struct StreamUploadAcceptedSchema: ObjectSchemaRepresentable {
    var propertyMap: SchemaMap {
        [
            "receivedBytes": ReceivedBytesField(),
        ]
    }
}

struct ReceivedBytesField: IntSchemaRepresentable {}
