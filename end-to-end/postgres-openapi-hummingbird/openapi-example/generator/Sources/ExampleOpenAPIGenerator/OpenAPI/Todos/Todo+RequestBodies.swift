//
//  Todo+RequestBodies.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 05..
//

import FeatherOpenAPI
import OpenAPIKit30

struct TodoCreateRequestBody: RequestBodyRepresentable {
    var contentMap: ContentMap {
        [
            .json: Content(TodoCreateSchema().reference())
        ]
    }
}

struct TodoUpdateRequestBody: RequestBodyRepresentable {
    var contentMap: ContentMap {
        [
            .json: Content(TodoUpdateSchema().reference())
        ]
    }
}

struct TodoPatchRequestBody: RequestBodyRepresentable {
    var contentMap: ContentMap {
        [
            .json: Content(TodoPatchSchema().reference())
        ]
    }
}
