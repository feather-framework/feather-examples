import Vapor
import SpecExampleOpenAPI
import NIOCore
import NIOFoundationCompat

struct VaporSpecExamplesAPIController {
    let store: InMemoryTodoStore

    private func decodeJSON<T: Decodable>(
        _ req: Request,
        as type: T.Type
    ) async throws -> T {
        let buffer = try await req.body.collect().get() ?? ByteBuffer()
        let data = Data(buffer: buffer)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func jsonResponse<T: Encodable>(
        _ value: T,
        status: HTTPStatus
    ) throws -> Response {
        let data = try JSONEncoder().encode(value)
        let response = Response(status: status)
        response.headers.contentType = .json
        response.body = .init(data: data)
        return response
    }

    func listTodos(_ req: Request) async throws -> Response {
        let todos = await store.listTodos()
        return try jsonResponse(todos, status: .ok)
    }

    func createTodo(_ req: Request) async throws -> Response {
        let payload = try await decodeJSON(req, as: Components.Schemas.TodoCreateSchema.self)
        guard !payload.name.isEmpty, !payload.listId.isEmpty else {
            return Response(status: .unprocessableEntity)
        }
        let todo = await store.createTodo(
            name: payload.name,
            isCompleted: payload.isCompleted ?? false,
            listId: payload.listId
        )
        return try jsonResponse(todo, status: .created)
    }

    func getTodo(_ req: Request) async throws -> Response {
        guard let todoId = req.parameters.get("todoId") else {
            return Response(status: .badRequest)
        }
        guard let todo = await store.getTodo(id: todoId) else {
            return Response(status: .notFound)
        }
        return try jsonResponse(todo, status: .ok)
    }

    func updateTodo(_ req: Request) async throws -> Response {
        guard let todoId = req.parameters.get("todoId") else {
            return Response(status: .badRequest)
        }
        let payload = try await decodeJSON(req, as: Components.Schemas.TodoUpdateSchema.self)
        guard !payload.name.isEmpty, !payload.listId.isEmpty else {
            return Response(status: .unprocessableEntity)
        }
        guard let todo = await store.updateTodo(
            id: todoId,
            name: payload.name,
            isCompleted: payload.isCompleted ?? false,
            listId: payload.listId
        ) else {
            return Response(status: .notFound)
        }
        return try jsonResponse(todo, status: .ok)
    }

    func patchTodo(_ req: Request) async throws -> Response {
        guard let todoId = req.parameters.get("todoId") else {
            return Response(status: .badRequest)
        }
        let payload = try await decodeJSON(req, as: Components.Schemas.TodoPatchSchema.self)
        guard let todo = await store.patchTodo(
            id: todoId,
            name: payload.name,
            isCompleted: payload.isCompleted,
            listId: payload.listId
        ) else {
            return Response(status: .notFound)
        }
        guard !todo.name.isEmpty, !todo.listId.isEmpty else {
            return Response(status: .unprocessableEntity)
        }
        return try jsonResponse(todo, status: .ok)
    }

    func deleteTodo(_ req: Request) async throws -> Response {
        guard let todoId = req.parameters.get("todoId") else {
            return Response(status: .badRequest)
        }
        return await store.deleteTodo(id: todoId)
            ? Response(status: .noContent)
            : Response(status: .notFound)
    }

    func listLists(_ req: Request) async throws -> Response {
        let lists = await store.listLists()
        return try jsonResponse(lists, status: .ok)
    }

    func createList(_ req: Request) async throws -> Response {
        let payload = try await decodeJSON(req, as: Components.Schemas.ListCreateSchema.self)
        guard !payload.name.isEmpty else {
            return Response(status: .unprocessableEntity)
        }
        let list = await store.createList(name: payload.name)
        return try jsonResponse(list, status: .created)
    }

    func getList(_ req: Request) async throws -> Response {
        guard let listId = req.parameters.get("listId") else {
            return Response(status: .badRequest)
        }
        guard let list = await store.getList(id: listId) else {
            return Response(status: .notFound)
        }
        return try jsonResponse(list, status: .ok)
    }

    func updateList(_ req: Request) async throws -> Response {
        guard let listId = req.parameters.get("listId") else {
            return Response(status: .badRequest)
        }
        let payload = try await decodeJSON(req, as: Components.Schemas.ListUpdateSchema.self)
        guard !payload.name.isEmpty else {
            return Response(status: .unprocessableEntity)
        }
        guard let list = await store.updateList(id: listId, name: payload.name) else {
            return Response(status: .notFound)
        }
        return try jsonResponse(list, status: .ok)
    }

    func patchList(_ req: Request) async throws -> Response {
        guard let listId = req.parameters.get("listId") else {
            return Response(status: .badRequest)
        }
        let payload = try await decodeJSON(req, as: Components.Schemas.ListPatchSchema.self)
        guard let list = await store.patchList(id: listId, name: payload.name) else {
            return Response(status: .notFound)
        }
        guard !list.name.isEmpty else {
            return Response(status: .unprocessableEntity)
        }
        return try jsonResponse(list, status: .ok)
    }

    func deleteList(_ req: Request) async throws -> Response {
        guard let listId = req.parameters.get("listId") else {
            return Response(status: .badRequest)
        }
        return await store.deleteList(id: listId)
            ? Response(status: .noContent)
            : Response(status: .notFound)
    }
}
