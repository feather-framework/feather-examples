//
//  Todo+Operations.swift
//  example-openapi-generator
//
//  Created by Tibor Bödecs on 2026. 02. 05..
//

import FeatherOpenAPI
import OpenAPIKit30

struct TodoCreateOperation: OperationRepresentable {
    var tags: [TagRepresentable] { [TodoTag()] }
    var operationId: String? { "createTodo" }
    var requestBody: RequestBodyRepresentable? { TodoCreateRequestBody().reference() }
    var responseMap: ResponseMap {
        [
            201: TodoResponse().reference(),
            400: BadInputResponse().reference(),
            422: UnprocessableEntityResponse().reference(),
            404: NotFoundResponse().reference(),
        ]
    }
}

struct TodoListOperation: OperationRepresentable {
    var tags: [TagRepresentable] { [TodoTag()] }
    var operationId: String? { "listTodos" }
    var responseMap: ResponseMap {
        [
            200: TodoListResponse().reference(),
            400: BadInputResponse().reference(),
            422: UnprocessableEntityResponse().reference(),
        ]
    }
}

struct TodoGetOperation: OperationRepresentable {
    var tags: [TagRepresentable] { [TodoTag()] }
    var operationId: String? { "getTodo" }
    var parameters: [ParameterRepresentable] {
        [TodoIdParameter().reference()]
    }
    var responseMap: ResponseMap {
        [
            200: TodoResponse().reference(),
            400: BadInputResponse().reference(),
            404: NotFoundResponse().reference(),
            422: UnprocessableEntityResponse().reference(),
        ]
    }
}

struct TodoUpdateOperation: OperationRepresentable {
    var tags: [TagRepresentable] { [TodoTag()] }
    var operationId: String? { "updateTodo" }
    var parameters: [ParameterRepresentable] {
        [TodoIdParameter().reference()]
    }
    var requestBody: RequestBodyRepresentable? { TodoUpdateRequestBody().reference() }
    var responseMap: ResponseMap {
        [
            200: TodoResponse().reference(),
            400: BadInputResponse().reference(),
            404: NotFoundResponse().reference(),
            422: UnprocessableEntityResponse().reference(),
        ]
    }
}

struct TodoPatchOperation: OperationRepresentable {
    var tags: [TagRepresentable] { [TodoTag()] }
    var operationId: String? { "patchTodo" }
    var parameters: [ParameterRepresentable] {
        [TodoIdParameter().reference()]
    }
    var requestBody: RequestBodyRepresentable? { TodoPatchRequestBody().reference() }
    var responseMap: ResponseMap {
        [
            200: TodoResponse().reference(),
            400: BadInputResponse().reference(),
            404: NotFoundResponse().reference(),
            422: UnprocessableEntityResponse().reference(),
        ]
    }
}

struct TodoDeleteOperation: OperationRepresentable {
    var tags: [TagRepresentable] { [TodoTag()] }
    var operationId: String? { "deleteTodo" }
    var parameters: [ParameterRepresentable] {
        [TodoIdParameter().reference()]
    }
    var responseMap: ResponseMap {
        [
            204: EmptyResponse(description: "Todo deleted"),
            404: NotFoundResponse().reference(),
        ]
    }
}
