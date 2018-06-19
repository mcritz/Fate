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
    
    // MARK: - Database
    router.get("mysql-version") { req -> Future<String> in
        return req.withPooledConnection(to: .mysql) { conn in
            return try conn.query("select @@version as v;").map(to: String.self) { rows in
                return try rows[0].firstValue(forColumn: "v")?.decode(String.self) ?? "n/a"
            }
        }
    }

    
    // MARK: - Predicions
    let predixController = PredictionController()
    router.get("predictions", use: predixController.index)
    router.post("predictions", use: predixController.create)
    
    
    
}
