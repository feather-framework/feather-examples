import Foundation
import Hummingbird

struct HummingbirdSpecExamplesUserController {
    let store: InMemoryUserStore

    func listUsers(request: Request, context: AppRequestContext) async throws -> Response {
        try jsonResponse(status: .ok, users: await store.listUsers())
    }

    func listActiveUsers(request: Request, context: AppRequestContext) async throws -> Response {
        try jsonResponse(status: .ok, users: await store.listActiveUsers())
    }

    func userCount(request: Request, context: AppRequestContext) async throws -> Response {
        try jsonResponse(
            status: .ok,
            value: UserCountResponse(count: await store.userCount())
        )
    }

    func createUser(request: Request, context: AppRequestContext) async throws -> Response {
        let payload = try await request.decode(as: UserCreateRequest.self, context: context)
        guard isValid(name: payload.name), isValid(email: payload.email) else {
            return Response(status: .unprocessableContent)
        }

        let user = await store.createUser(
            name: payload.name,
            email: payload.email,
            isActive: payload.isActive ?? true
        )
        return try jsonResponse(status: .created, user: user)
    }

    func getUser(request: Request, context: AppRequestContext) async throws -> Response {
        guard let user = await store.getUser(id: userId(from: request)) else {
            return Response(status: .notFound)
        }
        return try jsonResponse(status: .ok, user: user)
    }

    func updateUser(request: Request, context: AppRequestContext) async throws -> Response {
        let payload = try await request.decode(as: UserUpdateRequest.self, context: context)
        guard isValid(name: payload.name), isValid(email: payload.email) else {
            return Response(status: .unprocessableContent)
        }

        guard let user = await store.updateUser(
            id: userId(from: request),
            name: payload.name,
            email: payload.email,
            isActive: payload.isActive ?? true
        ) else {
            return Response(status: .notFound)
        }
        return try jsonResponse(status: .ok, user: user)
    }

    func patchUser(request: Request, context: AppRequestContext) async throws -> Response {
        let payload = try await request.decode(as: UserPatchRequest.self, context: context)
        guard let user = await store.patchUser(
            id: userId(from: request),
            name: payload.name,
            email: payload.email,
            isActive: payload.isActive
        ) else {
            return Response(status: .notFound)
        }

        guard isValid(name: user.name), isValid(email: user.email) else {
            return Response(status: .unprocessableContent)
        }
        return try jsonResponse(status: .ok, user: user)
    }

    func deleteUser(request: Request, context: AppRequestContext) async throws -> Response {
        return await store.deleteUser(id: userId(from: request))
            ? Response(status: .noContent)
            : Response(status: .notFound)
    }

    func activateUser(request: Request, context: AppRequestContext) async throws -> Response {
        guard let user = await store.setUserActive(
            id: userId(from: request),
            isActive: true
        ) else {
            return Response(status: .notFound)
        }
        return try jsonResponse(status: .ok, user: user)
    }

    func deactivateUser(request: Request, context: AppRequestContext) async throws -> Response {
        guard let user = await store.setUserActive(
            id: userId(from: request),
            isActive: false
        ) else {
            return Response(status: .notFound)
        }
        return try jsonResponse(status: .ok, user: user)
    }

    private func userId(from request: Request) -> String {
        let segments = request.uri.path.split(separator: "/", omittingEmptySubsequences: true)
        guard segments.count >= 2 else {
            return ""
        }
        return String(segments[1])
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

    private func jsonResponse(status: HTTPResponse.Status, user: User) throws -> Response {
        try jsonResponse(status: status, value: user)
    }

    private func jsonResponse(status: HTTPResponse.Status, users: [User]) throws -> Response {
        try jsonResponse(status: status, value: users)
    }

    private func jsonResponse<T: Encodable>(
        status: HTTPResponse.Status,
        value: T
    ) throws -> Response {
        let data = try JSONEncoder().encode(value)
        let body = ByteBuffer(bytes: data)
        var headers: HTTPFields = [.contentType: "application/json; charset=utf-8"]
        headers[.contentLength] = String(data.count)
        return Response(
            status: status,
            headers: headers,
            body: .init(byteBuffer: body)
        )
    }
}
