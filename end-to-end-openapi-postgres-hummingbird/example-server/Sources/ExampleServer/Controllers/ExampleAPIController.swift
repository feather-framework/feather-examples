import Hummingbird
import ExampleOpenAPI
import FeatherDatabase
import FeatherPostgresDatabase

struct ExampleAPIController: APIProtocol {
    
    var database: PostgresDatabaseClient

    func listTodos(
        _ input: Operations.ListTodos.Input
    ) async throws -> Operations.ListTodos.Output {
        try await database.withConnection { connection in
            try await connection.run(
                query: #"""
                    SELECT
                        version() AS "version"
                    WHERE
                        1=\#(1);
                    """#
            ) { sequence in
                let result = try await sequence.collect()
                let version = try result[0].decode(
                    column: "version",
                    as: String.self
                )

                return .ok(
                    .init(
                        body: .json(
                            [
                                .init(
                                    id: "foo",
                                    name: "\(version)",
                                    isCompleted: false
                                ),
                            ]
                        )
                    )
                )
            }
        }
    }
    
    func createTodo(
        _ input: Operations.CreateTodo.Input
    ) async throws -> Operations.CreateTodo.Output {
        fatalError()
    }
    
    func getTodo(
        _ input: Operations.GetTodo.Input
    ) async throws -> Operations.GetTodo.Output {
        fatalError()
    }

    func updateTodo(
        _ input: Operations.UpdateTodo.Input
    ) async throws -> Operations.UpdateTodo.Output {
        fatalError()
    }
    
    func deleteTodo(
        _ input: Operations.DeleteTodo.Input
    ) async throws -> Operations.DeleteTodo.Output {
        fatalError()
    }
}
