import Foundation
import Vapor

struct VaporSpecExamplesUserController {
    let store: InMemoryUserStore

    func listUsers(_ req: Request) async throws -> Response {
        try jsonResponse(await store.listUsers(), status: .ok)
    }

    func listActiveUsers(_ req: Request) async throws -> Response {
        try jsonResponse(await store.listActiveUsers(), status: .ok)
    }

    func userCount(_ req: Request) async throws -> Response {
        try jsonResponse(UserCountResponse(count: await store.userCount()), status: .ok)
    }

    func createUser(_ req: Request) async throws -> Response {
        let payload = try req.content.decode(UserCreateRequest.self)
        guard isValid(name: payload.name), isValid(email: payload.email) else {
            return Response(status: .unprocessableEntity)
        }

        let user = await store.createUser(
            name: payload.name,
            email: payload.email,
            isActive: payload.isActive ?? true
        )
        return try jsonResponse(user, status: .created)
    }

    func getUser(_ req: Request) async throws -> Response {
        guard let userId = req.parameters.get("id") else {
            return Response(status: .badRequest)
        }
        guard let user = await store.getUser(id: userId) else {
            return Response(status: .notFound)
        }
        return try jsonResponse(user, status: .ok)
    }

    func updateUser(_ req: Request) async throws -> Response {
        guard let userId = req.parameters.get("id") else {
            return Response(status: .badRequest)
        }
        let payload = try req.content.decode(UserUpdateRequest.self)
        guard isValid(name: payload.name), isValid(email: payload.email) else {
            return Response(status: .unprocessableEntity)
        }

        guard let user = await store.updateUser(
            id: userId,
            name: payload.name,
            email: payload.email,
            isActive: payload.isActive ?? true
        ) else {
            return Response(status: .notFound)
        }

        return try jsonResponse(user, status: .ok)
    }

    func patchUser(_ req: Request) async throws -> Response {
        guard let userId = req.parameters.get("id") else {
            return Response(status: .badRequest)
        }
        let payload = try req.content.decode(UserPatchRequest.self)

        guard let user = await store.patchUser(
            id: userId,
            name: payload.name,
            email: payload.email,
            isActive: payload.isActive
        ) else {
            return Response(status: .notFound)
        }

        guard isValid(name: user.name), isValid(email: user.email) else {
            return Response(status: .unprocessableEntity)
        }

        return try jsonResponse(user, status: .ok)
    }

    func deleteUser(_ req: Request) async throws -> Response {
        guard let userId = req.parameters.get("id") else {
            return Response(status: .badRequest)
        }
        return await store.deleteUser(id: userId)
            ? Response(status: .noContent)
            : Response(status: .notFound)
    }

    func activateUser(_ req: Request) async throws -> Response {
        guard let userId = req.parameters.get("id") else {
            return Response(status: .badRequest)
        }
        guard let user = await store.setUserActive(id: userId, isActive: true) else {
            return Response(status: .notFound)
        }
        return try jsonResponse(user, status: .ok)
    }

    func deactivateUser(_ req: Request) async throws -> Response {
        guard let userId = req.parameters.get("id") else {
            return Response(status: .badRequest)
        }
        guard let user = await store.setUserActive(id: userId, isActive: false) else {
            return Response(status: .notFound)
        }
        return try jsonResponse(user, status: .ok)
    }

    private func isValid(name: String) -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func isValid(email: String) -> Bool {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else {
            return false
        }
        let parts = normalized.split(separator: "@", omittingEmptySubsequences: false)
        return parts.count == 2 && !parts[0].isEmpty && parts[1].contains(".")
    }

    private func jsonResponse<T: Encodable>(_ value: T, status: HTTPStatus) throws -> Response {
        let data = try JSONEncoder().encode(value)
        let response = Response(status: status, body: .init(data: data))
        response.headers.contentType = .json
        return response
    }
}
