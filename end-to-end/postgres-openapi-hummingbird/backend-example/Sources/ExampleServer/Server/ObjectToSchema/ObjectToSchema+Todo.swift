import ExampleOpenAPI

extension Objects.Todo.Detail {
    var schema: Components.Schemas.TodoSchema {
        .init(
            id: id.rawValue,
            name: name,
            isCompleted: isCompleted,
            listId: listId.rawValue
        )
    }
}

