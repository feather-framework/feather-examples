//
//  Todo+Tags.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 05..
//

import FeatherOpenAPI

struct TodoTag: TagRepresentable {
    var name: String = "Todos"
    var description: String? = "Manage todos."
}
