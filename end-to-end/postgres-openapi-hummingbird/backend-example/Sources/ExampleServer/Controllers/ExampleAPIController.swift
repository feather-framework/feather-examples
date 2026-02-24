import Hummingbird
import ExampleOpenAPI
import FeatherValidation

struct ExampleAPIController: APIProtocol {
    
    var service: any ExampleService

    // MARK: - lists
    
    func deleteList(
        _ input: Operations.DeleteList.Input
    ) async throws -> Operations.DeleteList.Output {
        try await service.deleteList(id: .init(rawValue: input.path.listId))
        return .noContent
    }
    
    func updateList(
        _ input: Operations.UpdateList.Input
    ) async throws -> Operations.UpdateList.Output {
        let rawPayload: Components.Schemas.ListUpdateSchema
        switch input.body {
        case let .json(value):
            rawPayload = value
        }
        let payload = Objects.List.Update(schema: rawPayload)

        do {
            let list = try await service.updateListBy(
                id: .init(rawValue: input.path.listId),
                object: payload
            )
            return .ok(.init(body: .json(list.schema)))
        } catch is ValidationError {
            return .unprocessableContent(.init())
        } catch let error as AppService.Error {
            switch error {
            case .unprocessable:
                return .unprocessableContent(.init())
            case .notFound:
                return .notFound(.init())
            }
        }
    }

    func patchList(
        _ input: Operations.PatchList.Input
    ) async throws -> Operations.PatchList.Output {
        let rawPayload: Components.Schemas.ListPatchSchema
        switch input.body {
        case let .json(value):
            rawPayload = value
        }
        let patch = Objects.List.Patch(schema: rawPayload)

        do {
            let list = try await service.patchListBy(
                id: .init(rawValue: input.path.listId),
                patch: patch
            )
            return .ok(.init(body: .json(list.schema)))
        } catch is ValidationError {
            return .unprocessableContent(.init())
        } catch let error as AppService.Error {
            switch error {
            case .unprocessable:
                return .unprocessableContent(.init())
            case .notFound:
                return .notFound(.init())
            }
        }
    }
    
    func getList(
        _ input: Operations.GetList.Input
    ) async throws -> Operations.GetList.Output {
        guard let list = try await service.getListBy(
            id: .init(rawValue: input.path.listId)
        ) else {
            return .notFound(.init())
        }
        return .ok(.init(body: .json(list.schema)))
    }
    
    func createList(
        _ input: Operations.CreateList.Input
    ) async throws -> Operations.CreateList.Output {
        let rawPayload: Components.Schemas.ListCreateSchema
        switch input.body {
        case let .json(value):
            rawPayload = value
        }
        let payload = Objects.List.Create(schema: rawPayload)

        do {
            let list = try await service.createList(payload)
            return .created(.init(body: .json(list.schema)))
        } catch is ValidationError {
            return .unprocessableContent(.init())
        } catch let error as AppService.Error {
            switch error {
            case .unprocessable:
                return .unprocessableContent(.init())
            case .notFound:
                return .notFound(.init())
            }
        }
    }
    
    
    func listLists(
        _ input: Operations.ListLists.Input
    ) async throws -> Operations.ListLists.Output {
        let lists = try await service.listLists().map(\.schema)
        return .ok(.init(body: .json(lists)))
    }
    
    // MARK: - todos

    func listTodos(
        _ input: Operations.ListTodos.Input
    ) async throws -> Operations.ListTodos.Output {
        let todos = try await service.listTodos().map(\.schema)
        return .ok(.init(body: .json(todos)))
    }
    
    func createTodo(
        _ input: Operations.CreateTodo.Input
    ) async throws -> Operations.CreateTodo.Output {
        let rawPayload: Components.Schemas.TodoCreateSchema
        switch input.body {
        case let .json(value):
            rawPayload = value
        }
        let payload = Objects.Todo.Create(schema: rawPayload)

        do {
            let todo = try await service.createTodo(payload)
            return .created(.init(body: .json(todo.schema)))
        } catch is ValidationError {
            return .unprocessableContent(.init())
        } catch let error as AppService.Error {
            switch error {
            case .unprocessable:
                return .unprocessableContent(.init())
            case .notFound:
                return .notFound(.init())
            }
        }
    }
    
    func getTodo(
        _ input: Operations.GetTodo.Input
    ) async throws -> Operations.GetTodo.Output {
        guard let todo = try await service.getTodoBy(
            id: .init(rawValue: input.path.todoId)
        ) else {
            return .notFound(.init())
        }
        return .ok(.init(body: .json(todo.schema)))
    }

    func updateTodo(
        _ input: Operations.UpdateTodo.Input
    ) async throws -> Operations.UpdateTodo.Output {
        let rawPayload: Components.Schemas.TodoUpdateSchema
        switch input.body {
        case let .json(value):
            rawPayload = value
        }
        let payload = Objects.Todo.Update(schema: rawPayload)

        do {
            let todo = try await service.updateTodoBy(
                id: .init(rawValue: input.path.todoId),
                object: payload
            )
            return .ok(.init(body: .json(todo.schema)))
        } catch is ValidationError {
            return .unprocessableContent(.init())
        } catch let error as AppService.Error {
            switch error {
            case .unprocessable:
                return .unprocessableContent(.init())
            case .notFound:
                return .notFound(.init())
            }
        }
    }

    func patchTodo(
        _ input: Operations.PatchTodo.Input
    ) async throws -> Operations.PatchTodo.Output {
        let rawPayload: Components.Schemas.TodoPatchSchema
        switch input.body {
        case let .json(value):
            rawPayload = value
        }
        let patch = Objects.Todo.Patch(schema: rawPayload)

        do {
            let todo = try await service.patchTodoBy(
                id: .init(rawValue: input.path.todoId),
                patch: patch
            )
            return .ok(.init(body: .json(todo.schema)))
        } catch is ValidationError {
            return .unprocessableContent(.init())
        } catch let error as AppService.Error {
            switch error {
            case .unprocessable:
                return .unprocessableContent(.init())
            case .notFound:
                return .notFound(.init())
            }
        }
    }
    
    func deleteTodo(
        _ input: Operations.DeleteTodo.Input
    ) async throws -> Operations.DeleteTodo.Output {
        try await service.deleteTodo(id: .init(rawValue: input.path.todoId))
        return .noContent
    }
}
