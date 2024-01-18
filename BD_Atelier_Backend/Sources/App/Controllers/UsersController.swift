//
//  UsersController.swift
//
//
//  Created by Tudor Ifrim on 30.12.2023.
//

import Vapor
import Fluent
import FluentMySQLDriver
import Argon2Swift

enum UserType: String, Codable {
    // Ordered from most privileged to least privileged
    case manager
    case mechanic
    case client
    case none // none user type means the user is not logged in
}

struct UserResponse: Content {
    var id: UUID
    var name: String
    var type: UserType
    var username: String
}

struct UsersController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.group("user") { user in
            user.post("login", use: login)
            user.post("register", use: register) 
        }
    }
    
    func login(req: Request) async throws -> UserResponse {
        struct UserLoginRequest: Content {
            let username: String
            let password: String
        }
        let body = try req.content.decode(UserLoginRequest.self)
        
        let db: MySQLDatabase = req.db(.mysql) as! MySQLDatabase
        let rows = try await db.query(
            """
            SELECT
                BIN_TO_UUID(id) as id, name, type, username, password
            FROM
                users
            WHERE
                username = ?;
            """,
            [MySQLData(string: body.username)]
        ).get()
        
        var response = UserResponse(id: UUID(), name: "", type: .none, username: "") // Invalid response
        
        if ( rows.count == 1 ) {
            let password = (rows[0].column("password")?.string)!
            let auth = try? Argon2Swift.verifyHashString(password: body.password, hash: password)
            
            if ( auth ?? false ) {
                response.id = UUID(rows[0].column("id")?.string ?? "")!
                response.name = (rows[0].column("name")?.string)!
                response.type = UserType(rawValue: (rows[0].column("type")?.string)!)!
                response.username = (rows[0].column("username")?.string)!
            }
        }
            
        return response
    }
    
    func register(req: Request) async throws -> String {
        struct UserRegisterRequest: Content {
            let name: String
            let username: String
            var password: String
        }
        var body = try req.content.decode(UserRegisterRequest.self)
        
        let s = Salt.newSalt()
        body.password = try Argon2Swift.hashPasswordString(password: body.password, salt: s).encodedString()
        
        print(body)
        
        let db: MySQLDatabase = req.db(.mysql) as! MySQLDatabase
        let _ = try await db.query(
            """
                INSERT INTO
                    users(id, name, type, username, password)
                VALUES
                    (UUID_TO_BIN(UUID()), ?, 'client', ?, ?)
            """,
            [MySQLData(string: body.name),
             MySQLData(string: body.username),
             MySQLData(string: body.password)
            ]
        ).get()
        
        return ""
    }
}
