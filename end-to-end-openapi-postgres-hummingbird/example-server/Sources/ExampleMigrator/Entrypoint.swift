import Configuration
import Logging
import PostgresNIO
import FeatherDatabase
import FeatherPostgresDatabase
import SystemPackage
import Foundation
import ServiceLifecycle
import UnixSignals

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
                    :
                ])
            ]
        )

        let logger = {
            var logger = Logger(label: "example-migrator")
            logger.logLevel = reader.string(
                forKey: "log.level",
                as: Logger.Level.self,
                default: .info
            )
            return logger
        }()
        
        let finalCertPath = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: "docker")
            .appending(path: "postgres")
            .appending(path: "certificates")
            .appending(path: "ca.pem")
            .path()

        var tlsConfig = TLSConfiguration.makeClientConfiguration()
        let rootCert = try NIOSSLCertificate.fromPEMFile(finalCertPath)
        tlsConfig.trustRoots = .certificates(rootCert)
        tlsConfig.certificateVerification = .fullVerification

        let client = PostgresClient(
            configuration: .init(
                host: "127.0.0.1",
                port: 5432,
                username: "postgres",
                password: "postgres",
                database: "postgres",
                tls: .require(tlsConfig)
            ),
            backgroundLogger: logger
        )
        
        let database = PostgresDatabaseClient(
            client: client,
            logger: logger
        )

        let migrator = Migrator(
            database: database
        )

        let serviceGroup = ServiceGroup(
            configuration: .init(
                services: [
                    .init(
                        service: client
                    ),
                    .init(
                        service: MigrationService(migrator: migrator),
                        successTerminationBehavior: .gracefullyShutdownGroup,
                        failureTerminationBehavior: .gracefullyShutdownGroup
                    ),
                ],
                gracefulShutdownSignals: [.sigterm, .sigint],
                logger: logger
            )
        )
        try await serviceGroup.run()
    }
}


