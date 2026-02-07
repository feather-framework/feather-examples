//
//  Todo+RequestBodies.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 05..
//

import FeatherOpenAPI
import OpenAPIKit30

struct TodoRequestBody: RequestBodyRepresentable {
    var contentMap: ContentMap {
        [
            .json: Content(TodoCreateSchema().reference())
        ]
    }
}
