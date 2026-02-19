//
//  Todo+Parameters.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 05..
//

import FeatherOpenAPI

struct TodoIdParameter: PathParameterRepresentable {
    var name: String { "todoId" }
    var description: String? { "Todo identifier" }
    var schema: any OpenAPISchemaRepresentable {
        TodoIdField().reference()
    }
}
