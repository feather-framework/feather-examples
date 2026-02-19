import Hummingbird

// Registers all user CRUD and state transition routes.
// Builds a router wired to the user controller handlers.
func buildRouter(
    store: InMemoryUserStore
) throws -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)

    let controller = ValidationExamplesUserController(store: store)
    let users = router.group("users")
    users.get(use: controller.listUsers)
    users.get("active", use: controller.listActiveUsers)
    users.get("count", use: controller.userCount)
    users.post(use: controller.createUser)
    users.post(":id/activate", use: controller.activateUser)
    users.post(":id/deactivate", use: controller.deactivateUser)
    users.get(":id", use: controller.getUser)
    users.put(":id", use: controller.updateUser)
    users.patch(":id", use: controller.patchUser)
    users.delete(":id", use: controller.deleteUser)

    return router
}
