import FluentSQLite
import Vapor
import Leaf

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {

    let directoryConfig = DirectoryConfig.detect()
    services.register(directoryConfig)
    
    try services.register(FluentSQLiteProvider())
    try services.register(LeafProvider())
    
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)

    // Set up Leaf for rendering the views
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    // Telling Vapor how it will store the data of the sessions
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    
    // Set up the database using a file path
    let db = try SQLiteDatabase(storage: .file(path: "\(directoryConfig.workDir)forums.db"))

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: db, as: .sqlite)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Forum.self, database: .sqlite)
    migrations.add(model: Message.self, database: .sqlite)
    migrations.add(model: User.self, database: .sqlite)
    services.register(migrations)

}
