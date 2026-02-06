import Hummingbird
import ExampleOpenAPI

struct ExampleAPIController: APIProtocol {

    func listTodos(
        _ input: Operations.ListTodos.Input
    ) async throws -> Operations.ListTodos.Output {
        .ok(
            .init(
                body: .json(
                    [
                        .init(id: "foo", name: "bar", isCompleted: false),
                    ]
                )
            )
        )
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
