//
//  List+RequestBodies.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 05..
//

import FeatherOpenAPI
import OpenAPIKit30

struct ListCreateRequestBody: RequestBodyRepresentable {
    var contentMap: ContentMap {
        [
            .json: Content(ListCreateSchema().reference())
        ]
    }
}

struct ListUpdateRequestBody: RequestBodyRepresentable {
    var contentMap: ContentMap {
        [
            .json: Content(ListUpdateSchema().reference())
        ]
    }
}

struct ListPatchRequestBody: RequestBodyRepresentable {
    var contentMap: ContentMap {
        [
            .json: Content(ListPatchSchema().reference())
        ]
    }
}
