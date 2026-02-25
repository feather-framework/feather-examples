import FeatherDatabase

extension Entities.Todo {
    static func decode(from row: DatabaseRow) throws -> Self {
        try .init(
            id: .init(rawValue: row.decode(column: "id", as: String.self)),
            name: row.decode(column: "name", as: String.self),
            isCompleted: row.decode(column: "is_completed", as: Bool.self),
            listId: .init(rawValue: row.decode(column: "list_id", as: String.self))
        )
    }
}

extension AppRepository {
    func createTodo(entity: Entities.Todo) async throws -> Entities.Todo {
        try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    INSERT INTO todos (id, name, is_completed, list_id)
                    VALUES (\#(entity.id.rawValue), \#(entity.name), \#(entity.isCompleted), \#(entity.listId.rawValue))
                    RETURNING *;
                    """#
            ) { sequence in
                guard let row = try await sequence.collect().first else {
                    throw RepositoryError.notFound
                }
                return try Entities.Todo.decode(from: row)
            }
        }
    }

    func listTodos() async throws -> [Entities.Todo] {
        try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    SELECT * FROM todos ORDER BY id;
                    """#
            ) { sequence in
                try await sequence.collect().map { row in
                    try Entities.Todo.decode(from: row)
                }
            }
        }
    }

    func getTodoBy(id: EntityID<Entities.Todo>) async throws -> Entities.Todo? {
        try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    SELECT * FROM todos WHERE id=\#(id.rawValue) LIMIT 1;
                    """#
            ) { sequence in
                guard let row = try await sequence.collect().first else {
                    return nil
                }
                return try Entities.Todo.decode(from: row)
            }
        }
    }

    func updateTodoBy(
        id: EntityID<Entities.Todo>,
        entity: Entities.Todo
    ) async throws -> Entities.Todo? {
        try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    UPDATE todos
                    SET
                        name=\#(entity.name),
                        is_completed=\#(entity.isCompleted),
                        list_id=\#(entity.listId.rawValue)
                    WHERE id=\#(id.rawValue)
                    RETURNING *;
                    """#
            ) { sequence in
                guard let row = try await sequence.collect().first else {
                    return nil
                }
                return try Entities.Todo.decode(from: row)
            }
        }
    }

    func deleteTodo(id: EntityID<Entities.Todo>) async throws -> Bool {
        try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    DELETE FROM todos WHERE id=\#(id.rawValue) RETURNING id;
                    """#
            ) { sequence in
                try await sequence.collect().first != nil
            }
        }
    }

    func todoNameExists(
        _ name: String,
        inListId listId: EntityID<Entities.List>,
        excludingTodoId: EntityID<Entities.Todo>?
    ) async throws -> Bool {
        try await database.withConnection { connection in
            if let excludingTodoId {
                return try await connection.run(
                    query: #"""
                        SELECT 1
                        FROM todos
                        WHERE lower(name)=lower(\#(name))
                          AND list_id=\#(listId.rawValue)
                          AND id<>\#(excludingTodoId.rawValue)
                        LIMIT 1;
                        """#
                ) { sequence in
                    try await sequence.collect().isEmpty == false
                }
            }
            return try await connection.run(
                query: #"""
                    SELECT 1
                    FROM todos
                    WHERE lower(name)=lower(\#(name))
                      AND list_id=\#(listId.rawValue)
                    LIMIT 1;
                    """#
            ) { sequence in
                try await sequence.collect().isEmpty == false
            }
        }
    }
}
