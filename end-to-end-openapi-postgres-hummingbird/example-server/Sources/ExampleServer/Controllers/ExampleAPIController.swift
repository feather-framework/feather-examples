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
            isCompleted: row.decode(column: "is_completed", as: Bool.self)
        )
    }
}

struct ExampleAPIController: APIProtocol {
    
    var database: any DatabaseClient

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
                        todos (id, name, is_completed)
                    VALUES 
                        (\#(todoId), \#(payload.name), \#(String(payload.isCompleted))
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
        let payload: Components.Schemas.TodoCreateSchema
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
                        is_completed=\#(String(payload.isCompleted))
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
