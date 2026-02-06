//
//  File.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 05..
//

import FeatherOpenAPI
import OpenAPIKit30

struct EmptyResponse: ResponseRepresentable {
    let description: String
    var contentMap: ContentMap { [:] }
}

struct BadInputResponse: ResponseRepresentable {
    let description: String = "Bad input"
    var contentMap: ContentMap { [:] }
}

struct UnprocessableEntityResponse: ResponseRepresentable {
    let description: String = "Unprocessable entity"
    var contentMap: ContentMap { [:] }
}

struct NotFoundResponse: ResponseRepresentable {
    let description: String = "Todo not found"
    var contentMap: ContentMap { [:] }
}
