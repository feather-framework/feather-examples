extension Entities.List {
    var asDetailObject: Objects.List.Detail {
        .init(
            id: id.mapObject(to: Objects.List.self),
            name: name
        )
    }
}
