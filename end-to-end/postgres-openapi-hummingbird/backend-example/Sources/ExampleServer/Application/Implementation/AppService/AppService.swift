import NanoID

struct AppService: ExampleService {
    enum Error: Swift.Error, Sendable {
        case notFound
        case unprocessable
    }

    let repository: AppRepository

    init(repository: AppRepository) {
        self.repository = repository
    }

    func generateObjectID<T>() -> ObjectID<T> {
        .init(rawValue: NanoID().rawValue)
    }

    func generateEntityID<T>() -> EntityID<T> {
        .init(rawValue: NanoID().rawValue)
    }
}
