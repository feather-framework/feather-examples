extension AppService {
    func createList(
        _ object: Objects.List.Create
    ) async throws -> Objects.List.Detail {
        try await object.validate()
        if try await repository.listNameExists(object.name, excludingListId: nil) {
            throw Error.unprocessable
        }
        let entity = try await repository.createList(
            entity: .init(
                id: generateEntityID(),
                name: object.name
            )
        )
        return entity.asDetailObject
    }

    func listLists() async throws -> [Objects.List.Detail] {
        try await repository.listLists().map(\.asDetailObject)
    }

    func getListBy(
        id: ObjectID<Objects.List>
    ) async throws -> Objects.List.Detail? {
        try await repository.getListBy(id: id.mapEntity(to: Entities.List.self))?.asDetailObject
    }

    func updateListBy(
        id: ObjectID<Objects.List>,
        object: Objects.List.Update
    ) async throws -> Objects.List.Detail {
        try await object.validate()
        if try await repository.listNameExists(object.name, excludingListId: id.mapEntity(to: Entities.List.self)) {
            throw Error.unprocessable
        }
        let updated = try await repository.updateListBy(
            id: id.mapEntity(to: Entities.List.self),
            entity: .init(
                id: id.mapEntity(to: Entities.List.self),
                name: object.name
            )
        )
        guard let updated else {
            throw Error.notFound
        }
        return updated.asDetailObject
    }

    func patchListBy(
        id: ObjectID<Objects.List>,
        patch: Objects.List.Patch
    ) async throws -> Objects.List.Detail {
        try await patch.validate()

        guard let existing = try await repository.getListBy(id: id.mapEntity(to: Entities.List.self)) else {
            throw Error.notFound
        }

        let name = patch.name ?? existing.name
        if try await repository.listNameExists(name, excludingListId: id.mapEntity(to: Entities.List.self)) {
            throw Error.unprocessable
        }

        let updated = try await repository.updateListBy(
            id: id.mapEntity(to: Entities.List.self),
            entity: .init(
                id: id.mapEntity(to: Entities.List.self),
                name: name
            )
        )
        guard let updated else {
            throw Error.notFound
        }
        return updated.asDetailObject
    }

    func deleteList(
        id: ObjectID<Objects.List>
    ) async throws {
        _ = try await repository.deleteList(id: id.mapEntity(to: Entities.List.self))
    }
}
