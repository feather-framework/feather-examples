//
//  List+PathItems.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 05..
//

import FeatherOpenAPI

struct ListPathItems: PathItemRepresentable {
    var post: OperationRepresentable? { ListCreateOperation() }
    var get: OperationRepresentable? { ListListOperation() }
}

struct ListIdPathItems: PathItemRepresentable {
    var get: OperationRepresentable? { ListGetOperation() }
    var put: OperationRepresentable? { ListUpdateOperation() }
    var delete: OperationRepresentable? { ListDeleteOperation() }
}
