//
//  File.swift
//  
//
//  Created by Tudor Ifrim on 01.01.2024.
//

import Vapor
import Fluent
import FluentMySQLDriver

struct MechanicsController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.group("mechanics") { mechanics in
            mechanics.get("manager", ":managerId", use: getMechanicsForManager)
        }
    }
    
    func getMechanicsForManager(req: Request) async throws -> [Mechanic] {
        let uuid: String = req.parameters.get("managerId")!
        
        let db: MySQLDatabase = req.db(.mysql) as! MySQLDatabase
        let rows = try await db.query(
            """
            SELECT
                BIN_TO_UUID(m.id) as id, BIN_TO_UUID(m.user) as user, u.name as name
            FROM
                mechanics m, users u
            WHERE
                BIN_TO_UUID(m.manager) = ? and u.id = m.user
            """,
            
            [MySQLData(string: uuid)]
        ).get()
        
        var mechanics: [Mechanic] = []
        
        for row in rows {
            mechanics.append(Mechanic(id: UUID(uuidString: (row.column("id")?.string)!)!,
                                      userId: UUID(uuidString: (row.column("user")?.string)!)!,
                                      name: (row.column("name")?.string)!
                                     )
            )
        }
        
        return mechanics
    }
}
