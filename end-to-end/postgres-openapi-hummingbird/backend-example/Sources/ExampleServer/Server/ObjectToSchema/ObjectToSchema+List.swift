import ExampleOpenAPI

extension Objects.List.Detail {
    var schema: Components.Schemas.ListSchema {
        .init(
            id: id.rawValue,
            name: name
        )
    }
}

