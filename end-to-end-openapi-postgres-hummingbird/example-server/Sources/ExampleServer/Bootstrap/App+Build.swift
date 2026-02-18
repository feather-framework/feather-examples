import Configuration
import Hummingbird
import Logging
import ServiceLifecycle
import PostgresNIO
import FeatherDatabase
import FeatherPostgresDatabase
import Foundation

typealias AppRequestContext = BasicRequestContext

func buildApplicationComponents(
    reader: ConfigReader,
    includeServices: Bool = false
) async throws -> (app: any ApplicationProtocol, client: PostgresClient) {

    let logger = {
        var logger = Logger(label: "example-server")
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
    
    let router = try buildRouter(
        database: database
    )
    var app = Application(
        router: router,
        configuration: ApplicationConfiguration(
            reader: reader.scoped(to: "http")
        ),
        logger: logger
    )

    if includeServices {
        app.addServices(client)
    }
    return (app: app, client: client)
}

func buildApplication(
    reader: ConfigReader,
    includeServices: Bool = true
) async throws -> any ApplicationProtocol {
    let components = try await buildApplicationComponents(
        reader: reader,
        includeServices: includeServices
    )
    return components.app
}
