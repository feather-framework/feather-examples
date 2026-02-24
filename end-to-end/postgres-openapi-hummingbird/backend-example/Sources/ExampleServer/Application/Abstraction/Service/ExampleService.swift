protocol ExampleService: Sendable {
    func createList(_ object: Objects.List.Create) async throws -> Objects.List.Detail
    func listLists() async throws -> [Objects.List.Detail]
    func getListBy(id: ObjectID<Objects.List>) async throws -> Objects.List.Detail?
    func updateListBy(id: ObjectID<Objects.List>, object: Objects.List.Update) async throws -> Objects.List.Detail
    func patchListBy(id: ObjectID<Objects.List>, patch: Objects.List.Patch) async throws -> Objects.List.Detail
    func deleteList(id: ObjectID<Objects.List>) async throws

    func createTodo(_ object: Objects.Todo.Create) async throws -> Objects.Todo.Detail
    func listTodos() async throws -> [Objects.Todo.Detail]
    func getTodoBy(id: ObjectID<Objects.Todo>) async throws -> Objects.Todo.Detail?
    func updateTodoBy(id: ObjectID<Objects.Todo>, object: Objects.Todo.Update) async throws -> Objects.Todo.Detail
    func patchTodoBy(id: ObjectID<Objects.Todo>, patch: Objects.Todo.Patch) async throws -> Objects.Todo.Detail
    func deleteTodo(id: ObjectID<Objects.Todo>) async throws
}

