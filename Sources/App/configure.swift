import FluentPostgreSQL
import Leaf
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())
    /// Register custom PostgreSQL Config
    let psqlConfig = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "mcritz")
    let psql = PostgreSQLDatabase(config: psqlConfig)
    services.register(psql)
    
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Prediction.self, database: .psql)
    services.register(migrations)
    
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
}
