//
//  Todo+Responses.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 05..
//

import FeatherOpenAPI

struct TodoResponse: JSONResponseRepresentable {
    var description: String = "Todo response"
    var schema = TodoSchema().reference()
}

struct TodoListResponse: JSONResponseRepresentable {
    var description: String = "Todo list response"
    var schema = TodoListSchema()
}
