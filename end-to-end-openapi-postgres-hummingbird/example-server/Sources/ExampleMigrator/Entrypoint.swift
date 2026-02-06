//import Logging

@main
struct Entrypoint {
    
    static func main() async throws {
        print("hello world")
//        try await db.withConnection { connection in
//            // 1) Table creation
//            try await connection.run(query: #"""
//                CREATE TABLE IF NOT EXISTS "contact_messages" (
//                    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
//                    "name" TEXT NOT NULL,
//                    "email" TEXT NOT NULL,
//                    "phone" TEXT NOT NULL,
//                    "message" TEXT NOT NULL,
//                    "created_at" TEXT NOT NULL
//                );
//                """#)
//
//            // 2) Dummy seed data (idempotent)
//            try await connection.run(query: #"""
//                INSERT INTO contact_messages (name, email, phone, message, created_at)
//                SELECT
//                    'John Doe',
//                    'john.doe@example.com',
//                    '+36 30 123 4567',
//                    'This is a dummy contact message.',
//                    datetime('now')
//                WHERE NOT EXISTS (
//                    SELECT 1 FROM contact_messages
//                );
//                """#)
//        }
    }
}
