import Vapor

func buildRoutes(
    app: Application,
    controller: VaporSpecExamplesAPIController
) throws {
    app.get("todos") { req async throws -> Response in
        try await controller.listTodos(req)
    }
    app.post("todos") { req async throws -> Response in
        try await controller.createTodo(req)
    }
    app.get("todos", ":todoId") { req async throws -> Response in
        try await controller.getTodo(req)
    }
    app.put("todos", ":todoId") { req async throws -> Response in
        try await controller.updateTodo(req)
    }
    app.patch("todos", ":todoId") { req async throws -> Response in
        try await controller.patchTodo(req)
    }
    app.delete("todos", ":todoId") { req async throws -> Response in
        try await controller.deleteTodo(req)
    }

    app.get("lists") { req async throws -> Response in
        try await controller.listLists(req)
    }
    app.post("lists") { req async throws -> Response in
        try await controller.createList(req)
    }
    app.get("lists", ":listId") { req async throws -> Response in
        try await controller.getList(req)
    }
    app.put("lists", ":listId") { req async throws -> Response in
        try await controller.updateList(req)
    }
    app.patch("lists", ":listId") { req async throws -> Response in
        try await controller.patchList(req)
    }
    app.delete("lists", ":listId") { req async throws -> Response in
        try await controller.deleteList(req)
    }
}
