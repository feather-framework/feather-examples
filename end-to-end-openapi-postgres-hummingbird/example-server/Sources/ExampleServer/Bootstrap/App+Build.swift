import Configuration
import Hummingbird
import Logging
import ServiceLifecycle
//import SQLiteNIO
//import SQLiteNIOExtras
//import FeatherSQLiteDatabase

typealias AppRequestContext = BasicRequestContext

func buildApplication(
    reader: ConfigReader
) async throws -> some ApplicationProtocol {
    
    let logger = {
        var logger = Logger(label: "example-server")
        logger.logLevel = reader.string(
            forKey: "log.level",
            as: Logger.Level.self,
            default: .info
        )
        return logger
    }()
    
//    let dbPath = reader.string(forKey: "db.path", default: "db.sqlite")

    let router = try buildRouter()
    let app = Application(
        router: router,
        configuration: ApplicationConfiguration(
            reader: reader.scoped(to: "http")
        ),
        logger: logger
    )
    
//    app.addServices()
    return app
}


