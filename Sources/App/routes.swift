import Vapor
import Leaf

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // MARK: - Basics
    router.get("healthcheck") { req in
        return "ok"
    }
    router.get("/") { req -> Future<View> in
        return try req.view().render("home", [["greeting":"hello"], ["message" : "world"]])
    }
    
    // MARK: - Models
    let predixController = PredictionController()
    try router.register(collection: predixController)
    
    let topixController = TopicController()
    try router.register(collection: topixController)
    
    // MARK: - Users
    let usersController = UsersController()
    try router.register(collection: usersController)
}
