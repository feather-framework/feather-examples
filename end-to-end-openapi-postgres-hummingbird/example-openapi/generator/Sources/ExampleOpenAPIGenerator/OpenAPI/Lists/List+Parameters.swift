//
//  List+Parameters.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 05..
//

import FeatherOpenAPI

struct ListIdParameter: PathParameterRepresentable {
    var name: String { "listId" }
    var description: String? { "List identifier" }
    var schema: any OpenAPISchemaRepresentable {
        ListIdField().reference()
    }
}
