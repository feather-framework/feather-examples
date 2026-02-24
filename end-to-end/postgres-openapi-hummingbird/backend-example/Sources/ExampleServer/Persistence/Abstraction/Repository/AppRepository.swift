import FeatherDatabase

enum RepositoryError: Swift.Error, Sendable {
    case notFound
}

struct AppRepository: Sendable {
    let database: any DatabaseClient

    init(database: any DatabaseClient) {
        self.database = database
    }
}
