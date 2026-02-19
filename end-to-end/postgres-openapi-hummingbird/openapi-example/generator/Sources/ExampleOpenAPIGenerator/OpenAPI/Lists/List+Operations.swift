//
//  List+Operations.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 05..
//

import FeatherOpenAPI
import OpenAPIKit30

struct ListCreateOperation: OperationRepresentable {
    var tags: [TagRepresentable] { [ListTag()] }
    var operationId: String? { "createList" }
    var requestBody: RequestBodyRepresentable? { ListCreateRequestBody().reference() }
    var responseMap: ResponseMap {
        [
            201: ListResponse().reference(),
            400: BadInputResponse().reference(),
            422: UnprocessableEntityResponse().reference(),
            404: NotFoundResponse().reference(),
        ]
    }
}

struct ListListOperation: OperationRepresentable {
    var tags: [TagRepresentable] { [ListTag()] }
    var operationId: String? { "listLists" }
    var responseMap: ResponseMap {
        [
            200: ListListResponse().reference(),
            400: BadInputResponse().reference(),
            422: UnprocessableEntityResponse().reference(),
        ]
    }
}

struct ListGetOperation: OperationRepresentable {
    var tags: [TagRepresentable] { [ListTag()] }
    var operationId: String? { "getList" }
    var parameters: [ParameterRepresentable] {
        [ListIdParameter().reference()]
    }
    var responseMap: ResponseMap {
        [
            200: ListResponse().reference(),
            400: BadInputResponse().reference(),
            404: NotFoundResponse().reference(),
            422: UnprocessableEntityResponse().reference(),
        ]
    }
}

struct ListUpdateOperation: OperationRepresentable {
    var tags: [TagRepresentable] { [ListTag()] }
    var operationId: String? { "updateList" }
    var parameters: [ParameterRepresentable] {
        [ListIdParameter().reference()]
    }
    var requestBody: RequestBodyRepresentable? { ListUpdateRequestBody().reference() }
    var responseMap: ResponseMap {
        [
            200: ListResponse().reference(),
            400: BadInputResponse().reference(),
            404: NotFoundResponse().reference(),
            422: UnprocessableEntityResponse().reference(),
        ]
    }
}

struct ListPatchOperation: OperationRepresentable {
    var tags: [TagRepresentable] { [ListTag()] }
    var operationId: String? { "patchList" }
    var parameters: [ParameterRepresentable] {
        [ListIdParameter().reference()]
    }
    var requestBody: RequestBodyRepresentable? { ListPatchRequestBody().reference() }
    var responseMap: ResponseMap {
        [
            200: ListResponse().reference(),
            400: BadInputResponse().reference(),
            404: NotFoundResponse().reference(),
            422: UnprocessableEntityResponse().reference(),
        ]
    }
}

struct ListDeleteOperation: OperationRepresentable {
    var tags: [TagRepresentable] { [ListTag()] }
    var operationId: String? { "deleteList" }
    var parameters: [ParameterRepresentable] {
        [ListIdParameter().reference()]
    }
    var responseMap: ResponseMap {
        [
            204: EmptyResponse(description: "List deleted"),
            404: NotFoundResponse().reference(),
        ]
    }
}
