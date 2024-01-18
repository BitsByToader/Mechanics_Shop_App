import Vapor
import Fluent
import FluentMySQLDriver

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.databases.use(.mysql(hostname: "192.168.100.4",
                             username: "atelier",
                             password: "atelier",
                             database: "atelier",
                             tlsConfiguration: .none),
                      as: .mysql)
    
    // register routes
    try routes(app)
}
