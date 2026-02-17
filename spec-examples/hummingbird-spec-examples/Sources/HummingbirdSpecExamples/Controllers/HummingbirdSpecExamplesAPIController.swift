import SpecExampleOpenAPI

/// OpenAPI-backed controller implementation for todos and lists.
struct HummingbirdSpecExamplesAPIController: APIProtocol {
    /// Storage backing the controller.
    let store: InMemoryTodoStore

    // MARK: - Todos

    /// Lists all todos.
    func listTodos(
        _ input: Operations.ListTodos.Input
    ) async throws -> Operations.ListTodos.Output {
        // Ignore request input for simple list behavior.
        let todos = await store.listTodos()
        return .ok(.init(body: .json(todos)))
    }

    /// Creates a todo from the JSON payload.
    func createTodo(
        _ input: Operations.CreateTodo.Input
    ) async throws -> Operations.CreateTodo.Output {
        let payload: Components.Schemas.TodoCreateSchema
        switch input.body {
        case let .json(value):
            payload = value
        }

        // Validate required fields from the schema.
        guard !payload.name.isEmpty, !payload.listId.isEmpty else {
            return .unprocessableContent(.init())
        }

        // Default missing flags to false.
        let todo = await store.createTodo(
            name: payload.name,
            isCompleted: payload.isCompleted ?? false,
            listId: payload.listId
        )
        return .created(.init(body: .json(todo)))
    }

    /// Fetches a todo by id.
    func getTodo(
        _ input: Operations.GetTodo.Input
    ) async throws -> Operations.GetTodo.Output {
        let todoId = input.path.todoId
        guard let todo = await store.getTodo(id: todoId) else {
            return .notFound(.init())
        }
        return .ok(.init(body: .json(todo)))
    }

    /// Applies a partial update to a todo.
    func patchTodo(
        _ input: Operations.PatchTodo.Input
    ) async throws -> Operations.PatchTodo.Output {
        let todoId = input.path.todoId
        let payload: Components.Schemas.TodoPatchSchema
        switch input.body {
        case let .json(value):
            payload = value
        }

        // Apply patch; return 404 if the item does not exist.
        let updated = await store.patchTodo(
            id: todoId,
            name: payload.name,
            isCompleted: payload.isCompleted,
            listId: payload.listId
        )

        guard let todo = updated else {
            return .notFound(.init())
        }

        // Reject empty values after patch application.
        guard !todo.name.isEmpty, !todo.listId.isEmpty else {
            return .unprocessableContent(.init())
        }

        return .ok(.init(body: .json(todo)))
    }

    /// Replaces a todo with the provided payload.
    func updateTodo(
        _ input: Operations.UpdateTodo.Input
    ) async throws -> Operations.UpdateTodo.Output {
        let todoId = input.path.todoId
        let payload: Components.Schemas.TodoUpdateSchema
        switch input.body {
        case let .json(value):
            payload = value
        }

        // Validate required fields.
        guard !payload.name.isEmpty, !payload.listId.isEmpty else {
            return .unprocessableContent(.init())
        }

        // Replace the existing todo.
        let updated = await store.updateTodo(
            id: todoId,
            name: payload.name,
            isCompleted: payload.isCompleted ?? false,
            listId: payload.listId
        )

        guard let todo = updated else {
            return .notFound(.init())
        }

        return .ok(.init(body: .json(todo)))
    }

    /// Deletes a todo by id.
    func deleteTodo(
        _ input: Operations.DeleteTodo.Input
    ) async throws -> Operations.DeleteTodo.Output {
        let todoId = input.path.todoId
        // Return 204 for delete success, 404 otherwise.
        return await store.deleteTodo(id: todoId) ? .noContent : .notFound(.init())
    }

    // MARK: - Lists

    /// Lists all lists.
    func listLists(
        _ input: Operations.ListLists.Input
    ) async throws -> Operations.ListLists.Output {
        let lists = await store.listLists()
        return .ok(.init(body: .json(lists)))
    }

    /// Creates a list from the JSON payload.
    func createList(
        _ input: Operations.CreateList.Input
    ) async throws -> Operations.CreateList.Output {
        let payload: Components.Schemas.ListCreateSchema
        switch input.body {
        case let .json(value):
            payload = value
        }

        // Validate required fields.
        guard !payload.name.isEmpty else {
            return .unprocessableContent(.init())
        }

        let list = await store.createList(name: payload.name)
        return .created(.init(body: .json(list)))
    }

    /// Fetches a list by id.
    func getList(
        _ input: Operations.GetList.Input
    ) async throws -> Operations.GetList.Output {
        let listId = input.path.listId
        guard let list = await store.getList(id: listId) else {
            return .notFound(.init())
        }
        return .ok(.init(body: .json(list)))
    }

    /// Applies a partial update to a list.
    func patchList(
        _ input: Operations.PatchList.Input
    ) async throws -> Operations.PatchList.Output {
        let listId = input.path.listId
        let payload: Components.Schemas.ListPatchSchema
        switch input.body {
        case let .json(value):
            payload = value
        }

        // Apply patch; return 404 if missing.
        let updated = await store.patchList(id: listId, name: payload.name)

        guard let list = updated else {
            return .notFound(.init())
        }

        // Validate required fields.
        guard !list.name.isEmpty else {
            return .unprocessableContent(.init())
        }

        return .ok(.init(body: .json(list)))
    }

    /// Replaces a list with the provided payload.
    func updateList(
        _ input: Operations.UpdateList.Input
    ) async throws -> Operations.UpdateList.Output {
        let listId = input.path.listId
        let payload: Components.Schemas.ListUpdateSchema
        switch input.body {
        case let .json(value):
            payload = value
        }

        // Validate required fields.
        guard !payload.name.isEmpty else {
            return .unprocessableContent(.init())
        }

        // Replace the existing list.
        let updated = await store.updateList(id: listId, name: payload.name)

        guard let list = updated else {
            return .notFound(.init())
        }

        return .ok(.init(body: .json(list)))
    }

    /// Deletes a list by id.
    func deleteList(
        _ input: Operations.DeleteList.Input
    ) async throws -> Operations.DeleteList.Output {
        let listId = input.path.listId
        // Return 204 for delete success, 404 otherwise.
        return await store.deleteList(id: listId) ? .noContent : .notFound(.init())
    }
}
