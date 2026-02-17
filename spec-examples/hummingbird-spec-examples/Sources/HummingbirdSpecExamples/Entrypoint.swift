import Hummingbird

/// Application entrypoint for the example server.
@main
struct Entrypoint {
    /// Boots the Hummingbird application and starts the service loop.
    static func main() async throws {
        let app = try await buildApplication()
        try await app.runService()
    }
}
