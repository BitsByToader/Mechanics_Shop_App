//
//  File.swift
//  
//
//  Created by Tudor Ifrim on 01.01.2024.
//

import Foundation

struct BillItem: Codable {
    var id: UUID
    var name: String
    var price: Double
    var quantity: Int
    var labourHours: Int
    var labourPricePerHour: Double
    
    func send(for bill: UUID) async throws {
        guard let url = AppStore.backendURL?
            .appending(component: "bill")
            .appending(component: bill.uuidString)
            .appending(component: "addItem") else {
            throw AppError.AddBillItem
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try JSONEncoder().encode(self)
        
        let (_, _) = try await URLSession.shared.data(for: request)
    }
}
