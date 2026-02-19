import Hummingbird

// Read-only user endpoints.
extension ValidationExamplesUserController {
    // Returns all users in deterministic id order.
    func listUsers(request: Request, context: AppRequestContext) async throws -> Response {
        try jsonResponse(status: .ok, users: await store.listUsers())
    }

    // Returns only active users.
    func listActiveUsers(request: Request, context: AppRequestContext) async throws -> Response {
        try jsonResponse(status: .ok, users: await store.listActiveUsers())
    }

    // Returns the number of users currently stored.
    func userCount(request: Request, context: AppRequestContext) async throws -> Response {
        try jsonResponse(status: .ok, value: UserCountResponse(count: await store.userCount()))
    }

    // Loads a user by id or returns 404 when missing.
    func getUser(request: Request, context: AppRequestContext) async throws -> Response {
        guard let user = await store.getUser(id: userId(from: request)) else {
            return Response(status: .notFound)
        }
        return try jsonResponse(status: .ok, user: user)
    }
}
