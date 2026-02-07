//
//  OpenAPI+Security.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 05..
//

import FeatherOpenAPI
import OpenAPIKit30

struct OAuthSecurityScheme: SecuritySchemeRepresentable {

    var type: OpenAPIKit30.OpenAPI.SecurityScheme.SecurityType = .oauth2(
        flows: .init()
    )
}

struct OAuthSecurityRequirement: SecurityRequirementRepresentable {

    var security: any SecuritySchemeRepresentable = OAuthSecurityScheme()
    var requirements: [String] = ["read"]
}

struct APIKeySecurityScheme: SecuritySchemeRepresentable {

    var type: OpenAPIKit30.OpenAPI.SecurityScheme.SecurityType = .apiKey(
        name: "test",
        location: .header
    )
}

struct APIKeySecurityRequirement: SecurityRequirementRepresentable {

    var security: any SecuritySchemeRepresentable = APIKeySecurityScheme()
}
