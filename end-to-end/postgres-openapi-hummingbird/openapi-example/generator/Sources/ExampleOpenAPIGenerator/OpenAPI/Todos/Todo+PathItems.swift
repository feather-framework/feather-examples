//
//  Todo+PathItems.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 05..
//

import FeatherOpenAPI

struct TodoPathItems: PathItemRepresentable {
    var post: OperationRepresentable? { TodoCreateOperation() }
    var get: OperationRepresentable? { TodoListOperation() }
}

struct TodoIdPathItems: PathItemRepresentable {
    var get: OperationRepresentable? { TodoGetOperation() }
    var put: OperationRepresentable? { TodoUpdateOperation() }
    var patch: OperationRepresentable? { TodoPatchOperation() }
    var delete: OperationRepresentable? { TodoDeleteOperation() }
}
