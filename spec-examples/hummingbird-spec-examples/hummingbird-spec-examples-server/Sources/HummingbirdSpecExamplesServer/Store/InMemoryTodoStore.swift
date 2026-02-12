import SpecExampleOpenAPI
import Foundation

/// Simple in-memory backing store for todos and lists.
///
/// This keeps the example self-contained and deterministic for tests.
actor InMemoryTodoStore {
    // Stored records keyed by id for fast lookup.
    private var todos: [String: Components.Schemas.TodoSchema] = [:]
    private var lists: [String: Components.Schemas.ListSchema] = [:]

    /// Returns all todos currently in memory.
    func listTodos() -> [Components.Schemas.TodoSchema] {
        Array(todos.values)
    }

    /// Returns a single todo by id, or `nil` if missing.
    func getTodo(id: String) -> Components.Schemas.TodoSchema? {
        todos[id]
    }

    /// Creates a todo and returns the stored value.
    func createTodo(
        name: String,
        isCompleted: Bool,
        listId: String
    ) -> Components.Schemas.TodoSchema {
        // Generate a unique id for the todo.
        let todo = Components.Schemas.TodoSchema(
            id: UUID().uuidString,
            name: name,
            isCompleted: isCompleted,
            listId: listId
        )
        todos[todo.id] = todo
        return todo
    }

    /// Replaces a todo entirely. Returns `nil` when the todo does not exist.
    func updateTodo(
        id: String,
        name: String,
        isCompleted: Bool,
        listId: String
    ) -> Components.Schemas.TodoSchema? {
        // Only update existing records.
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

    /// Applies a partial update to a todo. Returns `nil` when missing.
    func patchTodo(
        id: String,
        name: String?,
        isCompleted: Bool?,
        listId: String?
    ) -> Components.Schemas.TodoSchema? {
        guard let current = todos[id] else {
            return nil
        }
        // Merge patch values with existing record.
        let todo = Components.Schemas.TodoSchema(
            id: id,
            name: name ?? current.name,
            isCompleted: isCompleted ?? current.isCompleted,
            listId: listId ?? current.listId
        )
        todos[id] = todo
        return todo
    }

    /// Deletes a todo by id. Returns whether a record was removed.
    func deleteTodo(id: String) -> Bool {
        todos.removeValue(forKey: id) != nil
    }

    /// Returns all lists currently in memory.
    func listLists() -> [Components.Schemas.ListSchema] {
        Array(lists.values)
    }

    /// Returns a list by id, or `nil` if missing.
    func getList(id: String) -> Components.Schemas.ListSchema? {
        lists[id]
    }

    /// Creates a list and returns the stored value.
    func createList(name: String) -> Components.Schemas.ListSchema {
        // Generate a unique id for the list.
        let list = Components.Schemas.ListSchema(
            id: UUID().uuidString,
            name: name
        )
        lists[list.id] = list
        return list
    }

    /// Replaces a list name. Returns `nil` when the list does not exist.
    func updateList(id: String, name: String) -> Components.Schemas.ListSchema? {
        // Only update existing records.
        guard lists[id] != nil else {
            return nil
        }
        let list = Components.Schemas.ListSchema(id: id, name: name)
        lists[id] = list
        return list
    }

    /// Applies a partial update to a list. Returns `nil` when missing.
    func patchList(id: String, name: String?) -> Components.Schemas.ListSchema? {
        guard let current = lists[id] else {
            return nil
        }
        // Merge patch values with existing record.
        let list = Components.Schemas.ListSchema(
            id: id,
            name: name ?? current.name
        )
        lists[id] = list
        return list
    }

    /// Deletes a list by id. Returns whether a record was removed.
    func deleteList(id: String) -> Bool {
        lists.removeValue(forKey: id) != nil
    }
}
