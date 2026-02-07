//
//  List+Responses.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 05..
//

import FeatherOpenAPI

struct ListResponse: JSONResponseRepresentable {
    var description: String = "List response"
    var schema = ListSchema().reference()
}

struct ListListResponse: JSONResponseRepresentable {
    var description: String = "List list response"
    var schema = ListListSchema()
}
