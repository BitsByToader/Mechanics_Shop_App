//
//  File.swift
//  
//
//  Created by Tudor Ifrim on 01.01.2024.
//

import Vapor

enum OrderState: String, Content {
    case waiting
    case confirmed
    case denied
    case inprogress
    case rfp // Ready-For-Pickup
    case pickedup
}

struct BriefOrder: Content {
    var id: UUID
    var state: OrderState
}

struct Order: Content {
    var id: UUID = UUID()
    var customerId: UUID = UUID()
    var customerName: String = ""
    var managerId: UUID = UUID()
    var managerName: String = ""
    
    struct BriefMechanic: Content {
        var id: UUID
        var name: String
    }
    var mechanics: [BriefMechanic] = []
    
    var state: OrderState  = .denied
    
    var dropOffDate: Date = .now
    var startDate: Date?
    var finishDate: Date?
    
    var description: String?
    var mechanicNotes: String?
}

struct Bill: Content {
    var id: UUID = UUID()
    var order: UUID = UUID()
    var billed: Bool = false
    var payed: Bool = false
    var items: [BillItem] = []
}

struct BillItem: Content {
    var id: UUID = UUID()
    var name: String = ""
    var price: Double = 0.0
    var quantity: Int = 0
    var labourHours: Int = 0
    var labourPricePerHour: Double = 0.0
}

struct Mechanic: Content {
    var id: UUID
    var userId: UUID
    var name: String
}
