import FeatherOpenAPI

struct UploadPathItem: PathItemRepresentable {
    var put: OperationRepresentable? { StreamUploadOperation() }
}

struct DownloadPathItem: PathItemRepresentable {
    var get: OperationRepresentable? { StreamDownloadOperation() }
}
