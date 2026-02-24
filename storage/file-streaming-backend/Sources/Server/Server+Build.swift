import Configuration
import FeatherStorage
import FeatherStorageFS
import Foundation
import Hummingbird
import Logging

func buildServer(
    reader: ConfigReader
) async throws -> some ApplicationProtocol {
    let logger = {
        var logger = Logger(label: "file-streaming-backend")
        logger.logLevel = reader.string(
            forKey: "log.level",
            as: Logger.Level.self,
            default: .info
        )
        return logger
    }()

    let rootPath = reader.string(
        forKey: "storage.path",
        default: FileManager.default.currentDirectoryPath + "/storage"
    )

    let objectKey = reader.string(
        forKey: "storage.objectKey",
        default: "upload.bin"
    )

    let storage = StorageClientFS(rootPath: rootPath)
    let router = buildRouter(storage: storage, objectKey: objectKey)

    return Application(
        router: router,
        configuration: ApplicationConfiguration(
            reader: reader.scoped(to: "http")
        ),
        logger: logger
    )
}
