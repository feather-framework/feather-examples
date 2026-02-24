extension Entities {
    struct Todo: Entity {
        var id: EntityID<Entities.Todo>
        var name: String
        var isCompleted: Bool
        var listId: EntityID<Entities.List>
    }
}

