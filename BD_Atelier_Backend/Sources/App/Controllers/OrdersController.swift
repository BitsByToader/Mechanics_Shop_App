//
//  File.swift
//  
//
//  Created by Tudor Ifrim on 31.12.2023.
//

import Vapor
import Fluent
import FluentMySQLDriver

struct OrdersController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.group("order") { order in
            order.group(":orderId") { orderId in
                orderId.get(use: getOrder)
                orderId.get("bill", use: getBill)
                orderId.get("deny", use: denyOrder)
                orderId.post("confirm", use: confirmOrder)
                orderId.get("delete", use: deleteOrder)
                orderId.get("updateNotes", ":notes", use: updateMechanicNotes)
            }
            
            order.post("place", use: placeOrder)
        }
        
        routes.group("orders") { orders in
            orders.get("brief", ":userId", use: getBriefOrders)
            orders.get("unmanaged", use: getUnmanagedOrders)
        }
    }
    
    func getBriefOrders(req: Request) async throws -> [BriefOrder] {
        let uuid: String = req.parameters.get("userId")!
        
        let db: MySQLDatabase = req.db(.mysql) as! MySQLDatabase
        let rows = try await db.query(
            """
            SELECT
                BIN_TO_UUID(id) as id, state
            FROM
                orders
            WHERE
                BIN_TO_UUID(customer) = ? or
                BIN_TO_UUID(manager) = ? or
                BIN_TO_UUID(id) in (
                    SELECT
                        BIN_TO_UUID(orders_mechanics.orderid)
                    FROM
                        orders_mechanics, mechanics
                    WHERE
                        orders_mechanics.mechanic = mechanics.id and BIN_TO_UUID(mechanics.user) = ?
                );
            """,
            [MySQLData(string: uuid), MySQLData(string: uuid), MySQLData(string: uuid)]
        ).get()
        
        var orders: [BriefOrder] = []
        
        for row in rows {
            orders.append(BriefOrder(id: UUID(uuidString: (row.column("id")?.string)!)!,
                                     state: OrderState(rawValue: (row.column("state")?.string)!)!))
        }
        
        return orders
    }
    
    func getOrder(req: Request) async throws -> Order {
        let uuid: String = req.parameters.get("orderId")!
        
        let db: MySQLDatabase = req.db(.mysql) as! MySQLDatabase
        async let orders = try db.query(
            """
            SELECT
                BIN_TO_UUID(o.id) as id, BIN_TO_UUID(customer) as customer, BIN_TO_UUID(manager) as manager,
                state, dropOffDate, startDate, finishDate, clientDescription, mechanicNotes,
                u1.name as customerName, u2.name as managerName
            FROM
                orders o, users u1, users u2
            WHERE
                BIN_TO_UUID(o.id) = ? and u1.id = o.customer and u2.id = o.manager;
            """,
            [MySQLData(string: uuid)]
        ).get()
        
        async let mechanics = try db.query(
            """
            SELECT
                BIN_TO_UUID(om.mechanic) as id, u.name as name
            FROM
                orders_mechanics om, mechanics m, users u
            WHERE
                BIN_TO_UUID(om.orderid) = ? and om.mechanic = m.id and m.user = u.id
            """,
            [MySQLData(string: uuid)]
        ).get()
        
        let (orderRows, mechanicRows) = try await (orders, mechanics)
        
        var response: Order = Order()
        
        if ( orderRows.count == 1 ) {
            let order = orderRows[0]
            
            response.id = UUID(uuidString: (order.column("id")?.string)!)!
            response.customerId = UUID(uuidString: (order.column("customer")?.string)!)!
            response.managerId = UUID(uuidString: (order.column("manager")?.string)!)!
            response.customerName = (order.column("customerName")?.string)!
            response.managerName = (order.column("managerName")?.string)!
            response.state = OrderState(rawValue: (order.column("state")?.string)!)!
            response.dropOffDate = (order.column("dropOffDate")?.date)!
            response.startDate = (order.column("startDate")?.date)
            response.finishDate = (order.column("finishDate")?.date)
            response.description = (order.column("clientDescription")?.string)
            response.mechanicNotes = (order.column("mechanicNotes")?.string)
            
            for mechanic in mechanicRows {
                response.mechanics.append(
                    Order.BriefMechanic(id: UUID(uuidString: (mechanic.column("id")?.string)!)!,
                                        name: (mechanic.column("name")?.string)!)
                )
            }
        }
        
        return response
    }
    
    func getBill(req: Request) async throws -> Bill {
        let uuid: String = req.parameters.get("orderId")!
        
        let db: MySQLDatabase = req.db(.mysql) as! MySQLDatabase
        async let bills = try db.query(
            """
            SELECT
                BIN_TO_UUID(id) as id, BIN_TO_UUID(orderid) as orderid, billed, payed
            FROM
                bills
            WHERE
                BIN_TO_UUID(orderid) = ?
            """,
            [MySQLData(string: uuid)]
        ).get()
        async let items = try db.query(
            """
            SELECT
                BIN_TO_UUID(bi.id) as id, bi.name as name, bi.price as price, bi.quantity as quantity,
                bi.labourHours as labourHours, bi.labourPricePerHour as labourPricePerHour
            FROM
                billitems bi, bills b
            WHERE
                bi.bill = b.id and BIN_TO_UUID(b.orderid) = ?
            """,
            [MySQLData(string: uuid)]
        ).get()
        
        let (billRows, itemRows) = try await (bills, items)
        
        var response: Bill = Bill()
        
        if ( billRows.count == 1 ) {
            let bill = billRows[0]
            
            response.id = UUID(uuidString: (bill.column("id")?.string)!)!
            response.order = UUID(uuidString: (bill.column("orderid")?.string)!)!
            response.billed = (bill.column("billed")?.bool)!
            response.payed = (bill.column("payed")?.bool)!
            
            for item in itemRows {
                response.items.append(
                    BillItem(id: UUID(uuidString: (item.column("id")?.string)!)!,
                             name: (item.column("name")?.string)!,
                             price: (item.column("price")?.double)!,
                             quantity: (item.column("quantity")?.int)!,
                             labourHours: (item.column("labourHours")?.int)!,
                             labourPricePerHour: (item.column("labourPricePerHour")?.double)!)
                )
            }
        }
        
        return response
    }
    
    func placeOrder(req: Request) async throws -> String {
        struct PlacedOrder: Content {
            var customer: UUID
            var description: String
            var dropOffDate: Date
        }
        let body = try req.content.decode(PlacedOrder.self)
        
        let db: MySQLDatabase = req.db(.mysql) as! MySQLDatabase
        let _ = try await db.query(
            """
            INSERT INTO
                orders(id, customer, state, dropOffDate, clientDescription)
            VALUES
                (UUID_TO_BIN(UUID()), ?, 'waiting', ?, ?)
            """,
            [MySQLData(uuid: body.customer),
             MySQLData(date: body.dropOffDate),
             MySQLData(string: body.description)
            ]
        ).get()
        
        return ""
    }
    
    func getUnmanagedOrders(req: Request) async throws -> [BriefOrder] {
        let db: MySQLDatabase = req.db(.mysql) as! MySQLDatabase
        let rows = try await db.query(
            """
            SELECT
                BIN_TO_UUID(id) as id, state
            FROM
                orders
            WHERE
                manager is NULL and state != 'denied'
            """
        ).get()
        
        var orders: [BriefOrder] = []
        
        for row in rows {
            orders.append(BriefOrder(id: UUID(uuidString: (row.column("id")?.string)!)!,
                                     state: OrderState(rawValue: (row.column("state")?.string)!)!))
        }
        
        return orders
    }
    
    func denyOrder(req: Request) async throws -> String {
        let uuid: String = req.parameters.get("orderId")!
        
        let db = req.db(.mysql) as! MySQLDatabase
        let _ = db.query(
            """
            UPDATE
                orders
            SET
                state = 'denied'
            WHERE
                BIN_TO_UUID(id) = ?
            """,
            [MySQLData(string: uuid)]
        )
        
        return ""
    }
    
    func confirmOrder(req: Request) async throws -> String {
        let uuid: String = req.parameters.get("orderId")!
        
        let db = req.db(.mysql) as! MySQLDatabase
        
        struct ConfirmOrderRequest: Content {
            var manager: UUID
            var mechanics: [UUID]
        }
        let body = try req.content.decode(ConfirmOrderRequest.self)
        
        let _ = try await db.simpleQuery("START TRANSACTION").get()
        
        let _ = try await db.query(
            """
            INSERT INTO
                bills(id, orderid, billed, payed)
            VALUES
                (UUID_TO_BIN(UUID()), ?, 0, 0)
            """,
            [MySQLData(uuid: UUID(uuidString: uuid)!)]
        ).get()
        
        let _ = try await db.query(
            """
            UPDATE
                orders
            SET
                state = 'confirmed', manager = ?, startDate = ?
            WHERE
                BIN_TO_UUID(id) = ?
            """,
            [MySQLData(uuid: body.manager),
             MySQLData(date: .now),
             MySQLData(string: uuid)
            ]
        ).get()
        
        for mechanic in body.mechanics {
            let _ = try await db.query(
                """
                INSERT INTO
                    orders_mechanics(orderid, mechanic)
                VALUES
                    (?, ?)
                """,
                [MySQLData(uuid: UUID(uuidString: uuid)!),
                 MySQLData(uuid: mechanic)
                ]
            ).get()
        }
        
        let _ = try await db.simpleQuery("COMMIT").get()
        
        return ""
    }
    
    func deleteOrder(req: Request) async throws -> String {
        let uuid: String = req.parameters.get("orderId")!
        
        let db = req.db(.mysql) as! MySQLDatabase
        
        let _ = try await db.query(
            """
            DELETE FROM
                orders
            WHERE
                BIN_TO_UUID(id) = ?
            """,
            [MySQLData(string: uuid)]
        ).get()
        
        return ""
    }
    
    func updateMechanicNotes(req: Request) async throws -> String {
        let uuid: String = req.parameters.get("orderId")!
        let notes: String = req.parameters.get("notes")!
        
        let db = req.db(.mysql) as! MySQLDatabase
        let _ = try await db.query(
            """
            UPDATE
                orders
            SET
                mechanicNotes = ?
            WHERE
                BIN_TO_UUID(id) = ?
            """,
            [MySQLData(string: notes),
             MySQLData(string: uuid),
            ]
        ).get()
        
        return ""
    }
}
