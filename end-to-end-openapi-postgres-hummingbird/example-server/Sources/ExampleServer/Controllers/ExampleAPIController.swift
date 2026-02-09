import Hummingbird
import ExampleOpenAPI
import FeatherDatabase
import Foundation
import NanoID

private extension Components.Schemas.TodoSchema {

    static func decode(
        from row: DatabaseRow
    ) throws -> Self {
        try .init(
            id: row.decode(column: "id", as: String.self),
            name: row.decode(column: "name", as: String.self),
            isCompleted: row.decode(column: "is_completed", as: Bool.self),
            listId: row.decode(column: "list_id", as: String.self)
        )
    }
}

private extension Components.Schemas.ListSchema {

    static func decode(
        from row: DatabaseRow
    ) throws -> Self {
        try .init(
            id: row.decode(column: "id", as: String.self),
            name: row.decode(column: "name", as: String.self)
        )
    }
}

struct ExampleAPIController: APIProtocol {
    
    var database: any DatabaseClient

    // MARK: - lists
    
    func deleteList(
        _ input: Operations.DeleteList.Input
    ) async throws -> Operations.DeleteList.Output {
        let listId = input.path.listId

        return try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    DELETE FROM lists WHERE id=\#(listId);
                    """#
            ) { _ in
                return .noContent
            }
        }
    }
    
    func updateList(
        _ input: Operations.UpdateList.Input
    ) async throws -> Operations.UpdateList.Output {
        let listId = input.path.listId
        let payload: Components.Schemas.ListUpdateSchema
        switch input.body {
        case let .json(value):
            payload = value
        }
        
        guard !payload.name.isEmpty else {
            return .unprocessableContent(.init())
        }

        return try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    UPDATE 
                        lists 
                    SET
                        name=\#(payload.name)
                    WHERE
                        id=\#(listId)
                    RETURNING
                        *;
                    """#
            ) { sequence in
                guard let row = try await sequence.collect().first else {
                    return .notFound(.init())
                }
                let list = try Components.Schemas.ListSchema.decode(from: row)

                return .ok(
                    .init(
                        body: .json(list)
                    )
                )
            }
        }
    }

    func patchList(
        _ input: Operations.PatchList.Input
    ) async throws -> Operations.PatchList.Output {
        let listId = input.path.listId
        let payload: Components.Schemas.ListPatchSchema
        switch input.body {
        case let .json(value):
            payload = value
        }

        return try await database.withConnection { connection in
            let existing = try await connection.run(
                query: #"""
                    SELECT * FROM lists WHERE id=\#(listId) LIMIT 1;
                    """#
            ) { sequence in
                try await sequence.collect().first
            }

            guard let existing else {
                return .notFound(.init())
            }

            let current = try Components.Schemas.ListSchema.decode(from: existing)
            let name = payload.name ?? current.name

            guard !name.isEmpty else {
                return .unprocessableContent(.init())
            }

            return try await connection.run(
                query: #"""
                    UPDATE 
                        lists 
                    SET
                        name=\#(name)
                    WHERE
                        id=\#(listId)
                    RETURNING
                        *;
                    """#
            ) { sequence in
                guard let row = try await sequence.collect().first else {
                    return .notFound(.init())
                }
                let list = try Components.Schemas.ListSchema.decode(from: row)

                return .ok(
                    .init(
                        body: .json(list)
                    )
                )
            }
        }
    }
    
    func getList(
        _ input: Operations.GetList.Input
    ) async throws -> Operations.GetList.Output {
        let listId = input.path.listId

        return try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    SELECT * FROM lists WHERE id=\#(listId) LIMIT 1;
                    """#
            ) { sequence in
                guard let row = try await sequence.collect().first else {
                    return .notFound(.init())
                }
                let list = try Components.Schemas.ListSchema.decode(from: row)

                return .ok(
                    .init(
                        body: .json(list)
                    )
                )
            }
        }
    }
    
    func createList(
        _ input: Operations.CreateList.Input
    ) async throws -> Operations.CreateList.Output {
        let payload: Components.Schemas.ListCreateSchema
        switch input.body {
        case let .json(value):
            payload = value
        }

        let listId = NanoID().rawValue

        guard !payload.name.isEmpty else {
            return .unprocessableContent(.init())
        }

        return try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    INSERT INTO 
                        lists (id, name)
                    VALUES 
                        (\#(listId), \#(payload.name))
                    RETURNING
                        *;
                    """#
            ) { sequence in
                guard let row = try await sequence.collect().first else {
                    return .notFound(.init())
                }
                let list = try Components.Schemas.ListSchema.decode(from: row)

                return .created(
                    .init(
                        body: .json(list)
                    )
                )
            }
        }
    }
    
    
    func listLists(
        _ input: Operations.ListLists.Input
    ) async throws -> Operations.ListLists.Output {
        try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    SELECT * FROM lists ORDER BY id;
                    """#
            ) { sequence in
                let rows = try await sequence.collect()
                let lists = try rows.map { row in
                    try Components.Schemas.ListSchema.decode(from: row)
                }
                return .ok(
                    .init(
                        body: .json(
                            lists
                        )
                    )
                )
            }
        }
    }
    
    // MARK: - todos

    func listTodos(
        _ input: Operations.ListTodos.Input
    ) async throws -> Operations.ListTodos.Output {
        try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    SELECT * FROM todos ORDER BY id;
                    """#
            ) { sequence in
                let rows = try await sequence.collect()
                let todos = try rows.map { row in
                    try Components.Schemas.TodoSchema.decode(from: row)
                }
                return .ok(
                    .init(
                        body: .json(
                            todos
                        )
                    )
                )
            }
        }
    }
    
    func createTodo(
        _ input: Operations.CreateTodo.Input
    ) async throws -> Operations.CreateTodo.Output {
        let payload: Components.Schemas.TodoCreateSchema
        switch input.body {
        case let .json(value):
            payload = value
        }

        let todoId = NanoID().rawValue
        
        guard !payload.name.isEmpty else {
            return .unprocessableContent(.init())
        }

        return try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    INSERT INTO 
                        todos (id, name, is_completed, list_id)
                    VALUES 
                        (\#(todoId), \#(payload.name), \#(payload.isCompleted ?? false), \#(payload.listId))
                    RETURNING
                        *;
                    """#
            ) { sequence in
                guard let row = try await sequence.collect().first else {
                    return .notFound(.init())
                }
                let todo = try Components.Schemas.TodoSchema.decode(from: row)

                return .created(
                    .init(
                        body: .json(todo)
                    )
                )
            }
        }
    }
    
    func getTodo(
        _ input: Operations.GetTodo.Input
    ) async throws -> Operations.GetTodo.Output {
        let todoId = input.path.todoId

        return try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    SELECT * FROM todos WHERE id=\#(todoId) LIMIT 1;
                    """#
            ) { sequence in
                guard let row = try await sequence.collect().first else {
                    return .notFound(.init())
                }
                let todo = try Components.Schemas.TodoSchema.decode(from: row)

                return .ok(
                    .init(
                        body: .json(todo)
                    )
                )
            }
        }
    }

    func updateTodo(
        _ input: Operations.UpdateTodo.Input
    ) async throws -> Operations.UpdateTodo.Output {
        let todoId = input.path.todoId
        let payload: Components.Schemas.TodoUpdateSchema
        switch input.body {
        case let .json(value):
            payload = value
        }
        
        guard !payload.name.isEmpty else {
            return .unprocessableContent(.init())
        }

        return try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    UPDATE 
                        todos 
                    SET
                        name=\#(payload.name),
                        is_completed=\#(payload.isCompleted ?? false),
                        list_id=\#(payload.listId)
                    WHERE
                        id=\#(todoId)
                    RETURNING
                        *;
                    """#
            ) { sequence in
                guard let row = try await sequence.collect().first else {
                    return .notFound(.init())
                }
                let todo = try Components.Schemas.TodoSchema.decode(from: row)

                return .ok(
                    .init(
                        body: .json(todo)
                    )
                )
            }
        }
    }

    func patchTodo(
        _ input: Operations.PatchTodo.Input
    ) async throws -> Operations.PatchTodo.Output {
        let todoId = input.path.todoId
        let payload: Components.Schemas.TodoPatchSchema
        switch input.body {
        case let .json(value):
            payload = value
        }

        return try await database.withConnection { connection in
            let existing = try await connection.run(
                query: #"""
                    SELECT * FROM todos WHERE id=\#(todoId) LIMIT 1;
                    """#
            ) { sequence in
                try await sequence.collect().first
            }

            guard let existing else {
                return .notFound(.init())
            }

            let current = try Components.Schemas.TodoSchema.decode(from: existing)
            let name = payload.name ?? current.name
            let isCompleted = payload.isCompleted ?? current.isCompleted
            let listId = payload.listId ?? current.listId

            guard !name.isEmpty else {
                return .unprocessableContent(.init())
            }

            return try await connection.run(
                query: #"""
                    UPDATE 
                        todos 
                    SET
                        name=\#(name),
                        is_completed=\#(isCompleted),
                        list_id=\#(listId)
                    WHERE
                        id=\#(todoId)
                    RETURNING
                        *;
                    """#
            ) { sequence in
                guard let row = try await sequence.collect().first else {
                    return .notFound(.init())
                }
                let todo = try Components.Schemas.TodoSchema.decode(from: row)

                return .ok(
                    .init(
                        body: .json(todo)
                    )
                )
            }
        }
    }
    
    func deleteTodo(
        _ input: Operations.DeleteTodo.Input
    ) async throws -> Operations.DeleteTodo.Output {
        let todoId = input.path.todoId

        return try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    DELETE FROM todos WHERE id=\#(todoId);
                    """#
            ) { _ in
                return .noContent
            }
        }
    }
}
