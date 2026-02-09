//
//  List+Schemas.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 05..
//

import FeatherOpenAPI
import OpenAPIKit30

struct ListIdField: StringSchemaRepresentable {
    var example: String? = "4kM7nR2zQ9pL"
}

struct ListNameField: StringSchemaRepresentable {
    var example: String? = "Work"
}

struct ListCreateSchema: ObjectSchemaRepresentable {
    var propertyMap: SchemaMap {
        [
            "name": ListNameField().reference(),
        ]
    }
}

struct ListUpdateSchema: ObjectSchemaRepresentable {
    var propertyMap: SchemaMap {
        [
            "name": ListNameField().reference(),
        ]
    }
}

struct ListPatchSchema: ObjectSchemaRepresentable {
    var propertyMap: SchemaMap {
        [
            "name": ListNameField().reference(required: false),
        ]
    }
}

struct ListSchema: ObjectSchemaRepresentable {
    var propertyMap: SchemaMap {
        [
            "id": ListIdField().reference(),
            "name": ListNameField().reference(),
        ]
    }
}

struct ListListSchema: ArraySchemaRepresentable {
    var items: SchemaRepresentable? { ListSchema().reference() }
}
