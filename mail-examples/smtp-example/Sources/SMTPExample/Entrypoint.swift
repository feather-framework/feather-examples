import Configuration
import Hummingbird
import Logging
import SystemPackage
import Yams

/// Application entrypoint for the SMTP example server.
@main
struct Entrypoint {
    /// Boots the Hummingbird application and starts the service loop.
    static func main() async throws {
        let reader = ConfigReader(
            providers: [
                CommandLineArgumentsProvider(),
                EnvironmentVariablesProvider(),
                try await FileProvider<YAMLSnapshot>(
                    filePath: "config.yml",
                    allowMissing: true
                ),
                InMemoryProvider(values: [
                    :
                ])
            ]
        )
        do {
            let app = try await buildApplication(reader: reader)
            try await app.runService()
        }
        catch let error as AppConfigError {
            var logger = Logger(label: "smtp-example")
            logger.logLevel = .error
            logger.error("Startup aborted due configuration error: \(String(describing: error))")
            return
        }
    }
}
