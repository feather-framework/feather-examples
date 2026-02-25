import ExampleOpenAPI

extension Objects.Todo.Create {
    init(schema: Components.Schemas.TodoCreateSchema) {
        self.init(
            name: normalizeTodoName(schema.name),
            isCompleted: schema.isCompleted ?? false,
            listId: .init(rawValue: normalizeListId(schema.listId))
        )
    }
}

extension Objects.Todo.Update {
    init(schema: Components.Schemas.TodoUpdateSchema) {
        self.init(
            name: normalizeTodoName(schema.name),
            isCompleted: schema.isCompleted ?? false,
            listId: .init(rawValue: normalizeListId(schema.listId))
        )
    }
}

extension Objects.Todo.Patch {
    init(schema: Components.Schemas.TodoPatchSchema) {
        self.init(
            name: schema.name.map(normalizeTodoName),
            isCompleted: schema.isCompleted,
            listId: schema.listId.map { .init(rawValue: normalizeListId($0)) }
        )
    }
}

