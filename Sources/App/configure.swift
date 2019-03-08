import FluentPostgreSQL
import Leaf
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // MARK: Providers
    try services.register(FluentPostgreSQLProvider())
    
    // MARK: Database parameters
    let databaseHostname = Environment.get("DATABASE_HOSTNAME")
    let databaseUser = Environment.get("DATABASE_USER")
    let databaseDB = Environment.get("DATABASE_DB")
    let databasePassword = Environment.get("DATABASE_PASSWORD")
    let dbPort = 5432
    guard let hostname = databaseHostname,
        let user = databaseUser,
        let db = databaseDB,
        let password = databasePassword
        else {
            fatalError("Could not read env config variables")
    }
    
    // MARK: Database config
    var psqlConfig: PostgreSQLDatabaseConfig
    switch env.name {
    case "development":
        psqlConfig = PostgreSQLDatabaseConfig(hostname: hostname, port: dbPort, username: user, database: db)
    case "testing":
        psqlConfig = PostgreSQLDatabaseConfig(hostname: hostname, port: dbPort, username: "mcritz", database: "vapor-test")
    default:
         psqlConfig = PostgreSQLDatabaseConfig(hostname: hostname, port: dbPort, username: user, database: db, password: password)
    }
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
    
    // MARK: User Sessions
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    middlewares.use(SessionsMiddleware.self)

    // MARK: User Auth
    try services.register(AuthenticationProvider())
    
    // MARK: Register all middleware
    services.register(middlewares)
}
