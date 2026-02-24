import ExampleOpenAPI

extension Objects.List.Create {
    init(schema: Components.Schemas.ListCreateSchema) {
        self.init(name: normalizeListName(schema.name))
    }
}

extension Objects.List.Update {
    init(schema: Components.Schemas.ListUpdateSchema) {
        self.init(name: normalizeListName(schema.name))
    }
}

extension Objects.List.Patch {
    init(schema: Components.Schemas.ListPatchSchema) {
        self.init(name: schema.name.map(normalizeListName))
    }
}

