//
//  Todo+Schemas.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 05..
//

import FeatherOpenAPI
import OpenAPIKit30

struct TodoIdField: StringSchemaRepresentable {
    var example: String? = "8tQ2mP1xV6nC"
}

struct TodoNameField: StringSchemaRepresentable {
    var example: String? = "Buy groceries"
}

struct TodoIsCompletedField: BoolSchemaRepresentable {
    var example: Bool? = false
}

struct TodoCreateSchema: ObjectSchemaRepresentable {
    var propertyMap: SchemaMap {
        [
            "name": TodoNameField().reference(),
            "isCompleted": TodoIsCompletedField().reference(required: false),
            "listId": ListIdField().reference(),
        ]
    }
}

struct TodoUpdateSchema: ObjectSchemaRepresentable {
    var propertyMap: SchemaMap {
        [
            "name": TodoNameField().reference(),
            "isCompleted": TodoIsCompletedField().reference(required: false),
            "listId": ListIdField().reference(),
        ]
    }
}

struct TodoPatchSchema: ObjectSchemaRepresentable {
    var propertyMap: SchemaMap {
        [
            "name": TodoNameField().reference(required: false),
            "isCompleted": TodoIsCompletedField().reference(required: false),
            "listId": ListIdField().reference(required: false),
        ]
    }
}

struct TodoSchema: ObjectSchemaRepresentable {
    var propertyMap: SchemaMap {
        [
            "id": TodoIdField().reference(),
            "name": TodoNameField().reference(),
            "isCompleted": TodoIsCompletedField().reference(),
            "listId": ListIdField().reference(),
        ]
    }
}

struct TodoListSchema: ArraySchemaRepresentable {
    var items: SchemaRepresentable? { TodoSchema().reference() }
}
