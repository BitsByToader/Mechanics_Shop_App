//
//  File.swift
//  
//
//  Created by Tudor Ifrim on 03.01.2024.
//

import Vapor
import Fluent
import FluentMySQLDriver

struct BillsController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.group("bill", ":billId") { bill in
            bill.post("addItem", use: addBillItem)
            bill.get("bill", use: billOrder)
            bill.get("pay", use: payOrder)
        }
    }
    
    func addBillItem(req: Request) async throws -> String {
        let billUuid = req.parameters.get("billId")!
        
        let body = try req.content.decode(BillItem.self)
        
        let db = req.db(.mysql) as! MySQLDatabase
        
        let _ = try await db.simpleQuery("START TRANSACTION").get()
        
        let _ = try await db.query(
            """
            UPDATE
                orders, bills
            SET
                orders.state = 'inprogress'
            WHERE
                orders.id = bills.orderid and BIN_TO_UUID(bills.id) = ?
            """,
            [MySQLData(string: billUuid)]
        ).get()
        
        let _ = try await db.query(
            """
            INSERT INTO
                billitems(id, bill, name, price, quantity, labourHours, labourPricePerHour)
            VALUES
                (?, ?, ?, ?, ?, ?, ?)
            """,
            [MySQLData(uuid: body.id),
             MySQLData(uuid: UUID(uuidString: billUuid)!),
             MySQLData(string: body.name),
             MySQLData(double: body.price),
             MySQLData(int: body.quantity),
             MySQLData(int: body.labourHours),
             MySQLData(double: body.labourPricePerHour)
            ]
        ).get()
        
        let _ = try await db.simpleQuery("COMMIT").get()
        
        return ""
    }
    
    func billOrder(req: Request) async throws -> String {
        let uuid = req.parameters.get("billId")!
        
        let db = req.db(.mysql) as! MySQLDatabase
        
        let _ = try await db.simpleQuery("START TRANSACTION").get()
        
        let _ = try await db.query(
            """
            UPDATE
                orders, bills
            SET
                orders.state = 'rfp', orders.finishDate = CURRENT_DATE()
            WHERE
                orders.id = bills.orderid and BIN_TO_UUID(bills.id) = ?
            """,
            [MySQLData(string: uuid)]
        ).get()
        
        let _ = try await db.query(
            """
            UPDATE
                bills
            SET
                billed = 1
            WHERE
                BIN_TO_UUID(id) = ?
            """,
            [MySQLData(string: uuid)]
        ).get()
        
        let _ = try await db.simpleQuery("COMMIT").get()
        
        return ""
    }
    
    func payOrder(req: Request) async throws -> String {
        let uuid = req.parameters.get("billId")!
        
        let db = req.db(.mysql) as! MySQLDatabase
        
        let _ = try await db.simpleQuery("START TRANSACTION").get()

        let _ = try await db.query(
            """
            UPDATE
                orders, bills
            SET
                orders.state = 'pickedup'
            WHERE
                orders.id = bills.orderid and BIN_TO_UUID(bills.id) = ?
            """,
            [MySQLData(string: uuid)]
        ).get()
        
        let _ = try await db.query(
            """
            UPDATE
                bills
            SET
                payed = 1
            WHERE
                BIN_TO_UUID(id) = ?
            """,
            [MySQLData(string: uuid)]
        ).get()
        
        let _ = try await db.simpleQuery("COMMIT").get()
        
        return ""
    }
}
