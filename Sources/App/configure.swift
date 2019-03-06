import FluentPostgreSQL
import Leaf
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // MARK: Providers
    try services.register(FluentPostgreSQLProvider())
    /// Register custom PostgreSQL Config
    let psqlConfig = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "mcritz")    
//    let databaseHostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
//    let databaseUser = Environment.get("DATABASE_USER") ?? "vapor"
//    let databaseDB = Environment.get("DATABASE_DB") ?? "vapor"
//    let databasePassword = Environment.get("DATABASE_PASSWORD") ?? "password"
//    let psqlConfig = PostgreSQLDatabaseConfig(hostname: databaseHostname, port: 5432, username: databaseUser, database: databaseDB, password: databasePassword)
    let psql = PostgreSQLDatabase(config: psqlConfig)
    services.register(psql)
    
    // MARK: Migrations
    var migrations = MigrationConfig()
    // Must have the models in order from which references which
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Topic.self, database: .psql)
    migrations.add(model: Prediction.self, database: .psql)
    migrations.add(model: TopicPivot.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    migrations.add(migration: AdminUser.self, database: .psql)
    services.register(migrations)
    
    // MARK: - Leaf / View
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    // MARK: Router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // MARK: - Middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    
    // MARK: - User Sessions
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    middlewares.use(SessionsMiddleware.self)

    // MARK: User Auth
    try services.register(AuthenticationProvider())
    
    // MARK: Register all middleware
    services.register(middlewares)
}
