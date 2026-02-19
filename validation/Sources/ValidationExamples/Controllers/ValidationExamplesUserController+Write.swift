import Hummingbird

// Mutating user endpoints (create/update/patch/delete and active state transitions).
extension ValidationExamplesUserController {
    // Creates a user after validating a full create payload.
    func createUser(request: Request, context: AppRequestContext) async throws -> Response {
        let payload = try await request.decode(as: UserCreateRequest.self, context: context)
        let failures = await payload.failures()
        guard failures.isEmpty else {
            return try validationErrorResponse(failures: failures)
        }
        // Keeps handler resilient if required rules are adjusted later.
        guard
            let name = payload.name,
            let email = payload.email,
            let age = payload.age,
            let role = payload.role,
            let inviteCode = payload.inviteCode,
            let username = payload.username,
            let trustScore = payload.trustScore,
            let loginCount = payload.loginCount
        else {
            return Response(status: .unprocessableContent)
        }

        let user = await store.createUser(
            name: name,
            email: email,
            age: age,
            role: role,
            inviteCode: inviteCode,
            username: username,
            trustScore: trustScore,
            loginCount: loginCount,
            isActive: payload.isActive ?? true
        )
        return try jsonResponse(status: .created, user: user)
    }

    // Replaces a user with a validated full update payload.
    func updateUser(request: Request, context: AppRequestContext) async throws -> Response {
        let payload = try await request.decode(as: UserUpdateRequest.self, context: context)
        let failures = await payload.failures()
        guard failures.isEmpty else {
            return try validationErrorResponse(failures: failures)
        }
        // Keeps handler resilient if required rules are adjusted later.
        guard
            let name = payload.name,
            let email = payload.email,
            let age = payload.age,
            let role = payload.role,
            let inviteCode = payload.inviteCode,
            let username = payload.username,
            let trustScore = payload.trustScore,
            let loginCount = payload.loginCount
        else {
            return Response(status: .unprocessableContent)
        }

        guard let user = await store.updateUser(
            id: userId(from: request),
            name: name,
            email: email,
            age: age,
            role: role,
            inviteCode: inviteCode,
            username: username,
            trustScore: trustScore,
            loginCount: loginCount,
            isActive: payload.isActive ?? true
        ) else {
            return Response(status: .notFound)
        }

        return try jsonResponse(status: .ok, user: user)
    }

    // Applies validated partial updates to an existing user.
    func patchUser(request: Request, context: AppRequestContext) async throws -> Response {
        let payload = try await request.decode(as: UserPatchRequest.self, context: context)
        let failures = await payload.failures()
        guard failures.isEmpty else {
            return try validationErrorResponse(failures: failures)
        }

        guard let user = await store.patchUser(
            id: userId(from: request),
            name: payload.name,
            email: payload.email,
            age: payload.age,
            role: payload.role,
            inviteCode: payload.inviteCode,
            username: payload.username,
            trustScore: payload.trustScore,
            loginCount: payload.loginCount,
            isActive: payload.isActive
        ) else {
            return Response(status: .notFound)
        }

        return try jsonResponse(status: .ok, user: user)
    }

    // Deletes a user and returns `204` when successful.
    func deleteUser(request: Request, context: AppRequestContext) async throws -> Response {
        await store.deleteUser(id: userId(from: request))
            ? Response(status: .noContent)
            : Response(status: .notFound)
    }

    // Marks a user as active.
    func activateUser(request: Request, context: AppRequestContext) async throws -> Response {
        guard let user = await store.setUserActive(id: userId(from: request), isActive: true) else {
            return Response(status: .notFound)
        }
        return try jsonResponse(status: .ok, user: user)
    }

    // Marks a user as inactive.
    func deactivateUser(request: Request, context: AppRequestContext) async throws -> Response {
        guard let user = await store.setUserActive(id: userId(from: request), isActive: false) else {
            return Response(status: .notFound)
        }
        return try jsonResponse(status: .ok, user: user)
    }
}
