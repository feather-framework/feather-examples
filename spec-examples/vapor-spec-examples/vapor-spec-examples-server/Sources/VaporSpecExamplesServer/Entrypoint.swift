import Vapor

@main
struct Entrypoint {
    static func main() async throws {
        let app = try await buildApplication(environment: .detect())
        defer { Task { try? await app.asyncShutdown() } }
        try await app.execute()
    }
}
