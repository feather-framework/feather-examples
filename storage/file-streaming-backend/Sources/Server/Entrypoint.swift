import Configuration
import Hummingbird
import SystemPackage

@main
struct Entrypoint {

    static func main() async throws {
        let reader = try await ConfigReader(
            providers: [
                EnvironmentVariablesProvider(),
                EnvironmentVariablesProvider(
                    environmentFilePath: ".env.development",
                    allowMissing: true
                ),
                InMemoryProvider(values: [:]),
            ]
        )

        let serverApplication = try await buildServer(reader: reader)
        try await serverApplication.runService()
    }
}
