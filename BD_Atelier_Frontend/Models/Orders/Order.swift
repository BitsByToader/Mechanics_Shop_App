import SwiftUI

struct Order: Hashable, Codable {
    var id: UUID
    var customerId: UUID
    var customerName: String
    var managerId: UUID
    var managerName: String
    
    struct BriefMechanic: Hashable, Codable {
        var id: UUID
        var name: String
    }
    var mechanics: [BriefMechanic] = []
    
    var state: OrderState
    
    var dropOffDate: Date?
    var startDate: Date?
    var finishDate: Date?
    
    var description: String?
    var mechanicNotes: String?
    
    func loadBill() async throws -> Bill {
        guard let url = AppStore.backendURL?
            .appending(component: "order")
            .appending(component: self.id.uuidString)
            .appending(component: "bill") else {
            throw AppError.BillRetreive
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let bill: Bill = try JSONDecoder().decode(Bill.self, from: data)
        
        if ( self.id != bill.order ) {
            throw AppError.BillRetreive // Got blank/invalid order, throw error
        }
        
        return bill
    }
    
    func updateMechanicNotes(_ notes: String) async throws {
        guard let url = AppStore.backendURL?
            .appending(component: "order")
            .appending(component: self.id.uuidString)
            .appending(component: "updateNotes")
            .appending(component: notes) else {
            throw AppError.OrderUpdateNotes
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (_, _) = try await URLSession.shared.data(for: request)
    }
}
