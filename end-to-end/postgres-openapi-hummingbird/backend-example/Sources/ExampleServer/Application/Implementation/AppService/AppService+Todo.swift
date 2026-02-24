extension AppService {
    func createTodo(
        _ object: Objects.Todo.Create
    ) async throws -> Objects.Todo.Detail {
        try await object.validate()

        guard try await repository.listExists(id: object.listId.mapEntity(to: Entities.List.self)) else {
            throw Error.unprocessable
        }
        if try await repository.todoNameExists(
            object.name,
            inListId: object.listId.mapEntity(to: Entities.List.self),
            excludingTodoId: nil
        ) {
            throw Error.unprocessable
        }

        let entity = try await repository.createTodo(
            entity: .init(
                id: generateEntityID(),
                name: object.name,
                isCompleted: object.isCompleted,
                listId: object.listId.mapEntity(to: Entities.List.self)
            )
        )
        return entity.asDetailObject
    }

    func listTodos() async throws -> [Objects.Todo.Detail] {
        try await repository.listTodos().map(\.asDetailObject)
    }

    func getTodoBy(
        id: ObjectID<Objects.Todo>
    ) async throws -> Objects.Todo.Detail? {
        try await repository.getTodoBy(id: id.mapEntity(to: Entities.Todo.self))?.asDetailObject
    }

    func updateTodoBy(
        id: ObjectID<Objects.Todo>,
        object: Objects.Todo.Update
    ) async throws -> Objects.Todo.Detail {
        try await object.validate()

        guard try await repository.listExists(id: object.listId.mapEntity(to: Entities.List.self)) else {
            throw Error.unprocessable
        }
        if try await repository.todoNameExists(
            object.name,
            inListId: object.listId.mapEntity(to: Entities.List.self),
            excludingTodoId: id.mapEntity(to: Entities.Todo.self)
        ) {
            throw Error.unprocessable
        }

        let entityId = id.mapEntity(to: Entities.Todo.self)
        let updated = try await repository.updateTodoBy(
            id: entityId,
            entity: .init(
                id: entityId,
                name: object.name,
                isCompleted: object.isCompleted,
                listId: object.listId.mapEntity(to: Entities.List.self)
            )
        )
        guard let updated else {
            throw Error.notFound
        }
        return updated.asDetailObject
    }

    func patchTodoBy(
        id: ObjectID<Objects.Todo>,
        patch: Objects.Todo.Patch
    ) async throws -> Objects.Todo.Detail {
        try await patch.validate()

        let entityId = id.mapEntity(to: Entities.Todo.self)
        guard let existing = try await repository.getTodoBy(id: entityId) else {
            throw Error.notFound
        }

        let name = patch.name ?? existing.name
        let isCompleted = patch.isCompleted ?? existing.isCompleted
        let listId = patch.listId?.mapEntity(to: Entities.List.self) ?? existing.listId

        guard try await repository.listExists(id: listId) else {
            throw Error.unprocessable
        }
        if try await repository.todoNameExists(
            name,
            inListId: listId,
            excludingTodoId: entityId
        ) {
            throw Error.unprocessable
        }

        let updated = try await repository.updateTodoBy(
            id: entityId,
            entity: .init(
                id: entityId,
                name: name,
                isCompleted: isCompleted,
                listId: listId
            )
        )
        guard let updated else {
            throw Error.notFound
        }
        return updated.asDetailObject
    }

    func deleteTodo(
        id: ObjectID<Objects.Todo>
    ) async throws {
        _ = try await repository.deleteTodo(id: id.mapEntity(to: Entities.Todo.self))
    }
}
