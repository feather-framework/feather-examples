import FeatherDatabase

struct Migrator: Sendable {
    
    var database: any DatabaseClient

    func run() async throws {
        try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    CREATE TABLE IF NOT EXISTS lists (
                        id TEXT PRIMARY KEY,
                        name TEXT NOT NULL
                    );
                    """#
            ) { _ in }

            try await connection.run(
                query: #"""
                    CREATE TABLE IF NOT EXISTS todos (
                        id TEXT PRIMARY KEY,
                        name TEXT NOT NULL,
                        is_completed BOOLEAN,
                        list_id TEXT NOT NULL REFERENCES lists(id)
                    );
                    """#
            ) { _ in }            
        }
    }
}
