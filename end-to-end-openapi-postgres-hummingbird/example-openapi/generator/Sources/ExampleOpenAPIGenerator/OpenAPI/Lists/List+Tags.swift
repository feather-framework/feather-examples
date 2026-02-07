//
//  List+Tags.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 05..
//

import FeatherOpenAPI

struct ListTag: TagRepresentable {
    var name: String = "Lists"
    var description: String? = "Manage lists."
}
