extension Objects {
    enum Todo: Object {
        struct Create: Object {
            var name: String
            var isCompleted: Bool
            var listId: ObjectID<Objects.List>
        }

        struct Update: Object {
            var name: String
            var isCompleted: Bool
            var listId: ObjectID<Objects.List>
        }

        struct Patch: Object {
            var name: String?
            var isCompleted: Bool?
            var listId: ObjectID<Objects.List>?
        }

        struct Detail: Object {
            var id: ObjectID<Objects.Todo>
            var name: String
            var isCompleted: Bool
            var listId: ObjectID<Objects.List>
        }
    }
}

