import SpecExampleOpenAPI
import Foundation

actor InMemoryTodoStore {
    private var todos: [String: Components.Schemas.TodoSchema] = [:]
    private var lists: [String: Components.Schemas.ListSchema] = [:]

    func listTodos() -> [Components.Schemas.TodoSchema] {
        Array(todos.values)
    }

    func getTodo(id: String) -> Components.Schemas.TodoSchema? {
        todos[id]
    }

    func createTodo(
        name: String,
        isCompleted: Bool,
        listId: String
    ) -> Components.Schemas.TodoSchema {
        let todo = Components.Schemas.TodoSchema(
            id: UUID().uuidString,
            name: name,
            isCompleted: isCompleted,
            listId: listId
        )
        todos[todo.id] = todo
        return todo
    }

    func updateTodo(
        id: String,
        name: String,
        isCompleted: Bool,
        listId: String
    ) -> Components.Schemas.TodoSchema? {
        guard todos[id] != nil else {
            return nil
        }
        let todo = Components.Schemas.TodoSchema(
            id: id,
            name: name,
            isCompleted: isCompleted,
            listId: listId
        )
        todos[id] = todo
        return todo
    }

    func patchTodo(
        id: String,
        name: String?,
        isCompleted: Bool?,
        listId: String?
    ) -> Components.Schemas.TodoSchema? {
        guard let current = todos[id] else {
            return nil
        }
        let todo = Components.Schemas.TodoSchema(
            id: id,
            name: name ?? current.name,
            isCompleted: isCompleted ?? current.isCompleted,
            listId: listId ?? current.listId
        )
        todos[id] = todo
        return todo
    }

    func deleteTodo(id: String) -> Bool {
        todos.removeValue(forKey: id) != nil
    }

    func listLists() -> [Components.Schemas.ListSchema] {
        Array(lists.values)
    }

    func getList(id: String) -> Components.Schemas.ListSchema? {
        lists[id]
    }

    func createList(name: String) -> Components.Schemas.ListSchema {
        let list = Components.Schemas.ListSchema(
            id: UUID().uuidString,
            name: name
        )
        lists[list.id] = list
        return list
    }

    func updateList(id: String, name: String) -> Components.Schemas.ListSchema? {
        guard lists[id] != nil else {
            return nil
        }
        let list = Components.Schemas.ListSchema(id: id, name: name)
        lists[id] = list
        return list
    }

    func patchList(id: String, name: String?) -> Components.Schemas.ListSchema? {
        guard let current = lists[id] else {
            return nil
        }
        let list = Components.Schemas.ListSchema(
            id: id,
            name: name ?? current.name
        )
        lists[id] = list
        return list
    }

    func deleteList(id: String) -> Bool {
        lists.removeValue(forKey: id) != nil
    }
}
