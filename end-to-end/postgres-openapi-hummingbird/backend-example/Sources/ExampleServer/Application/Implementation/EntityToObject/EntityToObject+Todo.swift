extension Entities.Todo {
    var asDetailObject: Objects.Todo.Detail {
        .init(
            id: id.mapObject(to: Objects.Todo.self),
            name: name,
            isCompleted: isCompleted,
            listId: listId.mapObject(to: Objects.List.self)
        )
    }
}
