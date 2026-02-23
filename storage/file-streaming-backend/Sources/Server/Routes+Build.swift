import FeatherStorage
import Hummingbird
import Logging

typealias AppRequestContext = BasicRequestContext

func buildRouter(
    storage: any StorageClient,
    objectKey: String
) -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)

    router.addMiddleware {
        LogRequestsMiddleware(.info)
    }

    router.get("/health") { _, _ in
        Response(status: .ok)
    }

    let controller = FileStreamingController(
        storage: storage,
        objectKey: objectKey
    )

    router.put("/upload", use: controller.upload)
    router.get("/download", use: controller.download)

    return router
}
