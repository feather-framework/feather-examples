extension Objects {
    enum List: Object {
        struct Create: Object {
            var name: String
        }

        struct Update: Object {
            var name: String
        }

        struct Patch: Object {
            var name: String?
        }

        struct Detail: Object {
            var id: ObjectID<Objects.List>
            var name: String
        }
    }
}

