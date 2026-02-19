import Hummingbird

// Executable entrypoint for running the example server.
@main
struct Entrypoint {
    // Boots the example application and starts the HTTP server.
    static func main() async throws {
        let app = try await buildApplication()
        try await app.runService()
    }
}
