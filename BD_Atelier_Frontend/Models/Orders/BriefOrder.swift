import Foundation

struct BriefOrder: Hashable, Identifiable, Codable {
    var id: UUID
    var state: OrderState
    
    static func loadBriefOrders(for user: UUID) async throws -> [BriefOrder] {
        guard let url = AppStore.backendURL?
            .appending(component: "orders")
            .appending(component: "brief")
            .appending(component: user.uuidString) else {
            throw AppError.BriefOrderRetrieve
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let orders: [BriefOrder] = try JSONDecoder().decode([BriefOrder].self, from: data)
        
        return orders
    }
    
    func loadOrder() async throws -> Order {
        guard let url = AppStore.backendURL?
            .appending(component: "order")
            .appending(component: self.id.uuidString) else {
            throw AppError.OrderRetrieve
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let order: Order = try decoder.decode(Order.self, from: data)
        
        if ( self.id != order.id ) {
            throw AppError.OrderRetrieve // Got blank/invalid order, throw error
        }
        
        return order
    }
    
    static func loadUnmanagedOrders() async throws -> [BriefOrder] {
        guard let url = AppStore.backendURL?
            .appending(component: "orders")
            .appending(component: "unmanaged") else {
            throw AppError.UnmanagedOrderRetrieve
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let orders: [BriefOrder] = try JSONDecoder().decode([BriefOrder].self, from: data)
        
        return orders
    }
    
    func deny() async throws {
        guard let url = AppStore.backendURL?
            .appending(component: "order")
            .appending(component: self.id.uuidString)
            .appending(component: "deny") else {
            throw AppError.OrderRetrieve
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (_, _) = try await URLSession.shared.data(for: request)
    }
    
    func confirm(to manager: UUID, for mechanics: [Mechanic]) async throws {
        guard let url = AppStore.backendURL?
            .appending(component: "order")
            .appending(component: self.id.uuidString)
            .appending(component: "confirm") else {
            throw AppError.ConfirmOrder
        }
        
        struct ConfirmOrderContent: Codable {
            var manager: UUID
            var mechanics: [UUID]
        }
        
        var mechanicUuids: [UUID] = []
        for mechanic in mechanics {
            mechanicUuids.append(mechanic.id)
        }
        
        let body = ConfirmOrderContent(manager: manager, mechanics: mechanicUuids)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, _) = try await URLSession.shared.data(for: request)
    }
    
    func delete() async throws {
        guard let url = AppStore.backendURL?
            .appending(component: "order")
            .appending(component: self.id.uuidString)
            .appending(component: "delete") else {
            throw AppError.ConfirmOrder
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (_, _) = try await URLSession.shared.data(for: request)
    }
}
