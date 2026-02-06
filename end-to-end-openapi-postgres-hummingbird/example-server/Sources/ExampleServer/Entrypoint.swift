import Configuration
import Hummingbird
import Logging
import SystemPackage

@main
struct Entrypoint {

    static func main() async throws {
        let reader = try await ConfigReader(
            providers: [
                CommandLineArgumentsProvider(),
                EnvironmentVariablesProvider(),
                EnvironmentVariablesProvider(
                    environmentFilePath: ".env",
                    allowMissing: true
                ),
                InMemoryProvider(values: [
                    "http.serverName": "dental-wiz-app"
                ])
            ]
        )
        let app = try await buildApplication(reader: reader)
        try await app.runService()
    }
}
