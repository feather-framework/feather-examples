import FeatherDatabase

struct Migrator: Sendable {
    
    var database: any DatabaseClient

    func run() async throws {
        try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    CREATE TABLE IF NOT EXISTS todos (
                        id TEXT PRIMARY KEY,
                        name TEXT NOT NULL,
                        is_completed BOOLEAN
                    );
                    """#
            ) { _ in }
            
//            try await connection.run(
//                query: #"""
//                    INSERT INTO todos 
//                    (
//                        id, 
//                        name, 
//                        is_completed
//                    )
//                    VALUES
//                    ( 
//                        '5D2wACKWJHdSfrKYbre9A',
//                        'Get Milk',
//                        false
//                    );
//                    """#
//            )
        }
    }
}
