import Vapor

func buildRoutes(
    app: Application,
    controller: VaporSpecExamplesUserController
) throws {
    app.get("users") { req async throws -> Response in
        try await controller.listUsers(req)
    }
    app.get("users", "active") { req async throws -> Response in
        try await controller.listActiveUsers(req)
    }
    app.get("users", "count") { req async throws -> Response in
        try await controller.userCount(req)
    }
    app.post("users") { req async throws -> Response in
        try await controller.createUser(req)
    }
    app.get("users", ":id") { req async throws -> Response in
        try await controller.getUser(req)
    }
    app.put("users", ":id") { req async throws -> Response in
        try await controller.updateUser(req)
    }
    app.patch("users", ":id") { req async throws -> Response in
        try await controller.patchUser(req)
    }
    app.delete("users", ":id") { req async throws -> Response in
        try await controller.deleteUser(req)
    }
    app.post("users", ":id", "activate") { req async throws -> Response in
        try await controller.activateUser(req)
    }
    app.post("users", ":id", "deactivate") { req async throws -> Response in
        try await controller.deactivateUser(req)
    }
}
