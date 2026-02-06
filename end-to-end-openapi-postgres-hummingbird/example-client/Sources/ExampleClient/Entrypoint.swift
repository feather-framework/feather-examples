import OpenAPIRuntime
import OpenAPIAsyncHTTPClient
import ExampleOpenAPI
import Foundation

@main
struct Entrypoint {

    static func main() async throws {
        let client = Client(
            serverURL: URL(
                string: "http://localhost:8080/"
            )!,
            transport: AsyncHTTPClientTransport()
        )
        let response = try await client.listTodos()
        print(try response.ok.body.json)
    }
}
