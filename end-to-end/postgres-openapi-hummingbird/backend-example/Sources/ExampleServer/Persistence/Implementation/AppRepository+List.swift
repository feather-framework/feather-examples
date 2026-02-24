import FeatherDatabase

extension Entities.List {
    static func decode(from row: DatabaseRow) throws -> Self {
        try .init(
            id: .init(rawValue: row.decode(column: "id", as: String.self)),
            name: row.decode(column: "name", as: String.self)
        )
    }
}

extension AppRepository {
    func createList(entity: Entities.List) async throws -> Entities.List {
        try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    INSERT INTO lists (id, name)
                    VALUES (\#(entity.id.rawValue), \#(entity.name))
                    RETURNING *;
                    """#
            ) { sequence in
                guard let row = try await sequence.collect().first else {
                    throw RepositoryError.notFound
                }
                return try Entities.List.decode(from: row)
            }
        }
    }

    func listLists() async throws -> [Entities.List] {
        try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    SELECT * FROM lists ORDER BY id;
                    """#
            ) { sequence in
                try await sequence.collect().map { row in
                    try Entities.List.decode(from: row)
                }
            }
        }
    }

    func getListBy(id: EntityID<Entities.List>) async throws -> Entities.List? {
        try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    SELECT * FROM lists WHERE id=\#(id.rawValue) LIMIT 1;
                    """#
            ) { sequence in
                guard let row = try await sequence.collect().first else {
                    return nil
                }
                return try Entities.List.decode(from: row)
            }
        }
    }

    func updateListBy(
        id: EntityID<Entities.List>,
        entity: Entities.List
    ) async throws -> Entities.List? {
        try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    UPDATE lists
                    SET name=\#(entity.name)
                    WHERE id=\#(id.rawValue)
                    RETURNING *;
                    """#
            ) { sequence in
                guard let row = try await sequence.collect().first else {
                    return nil
                }
                return try Entities.List.decode(from: row)
            }
        }
    }

    func deleteList(id: EntityID<Entities.List>) async throws -> Bool {
        try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    DELETE FROM lists WHERE id=\#(id.rawValue) RETURNING id;
                    """#
            ) { sequence in
                try await sequence.collect().first != nil
            }
        }
    }

    func listExists(id: EntityID<Entities.List>) async throws -> Bool {
        try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    SELECT 1 FROM lists WHERE id=\#(id.rawValue) LIMIT 1;
                    """#
            ) { sequence in
                try await sequence.collect().isEmpty == false
            }
        }
    }

    func listNameExists(
        _ name: String,
        excludingListId: EntityID<Entities.List>?
    ) async throws -> Bool {
        try await database.withConnection { connection in
            if let excludingListId {
                return try await connection.run(
                    query: #"""
                        SELECT 1
                        FROM lists
                        WHERE lower(name)=lower(\#(name))
                          AND id<>\#(excludingListId.rawValue)
                        LIMIT 1;
                        """#
                ) { sequence in
                    try await sequence.collect().isEmpty == false
                }
            }
            return try await connection.run(
                query: #"""
                    SELECT 1
                    FROM lists
                    WHERE lower(name)=lower(\#(name))
                    LIMIT 1;
                    """#
            ) { sequence in
                try await sequence.collect().isEmpty == false
            }
        }
    }
}
