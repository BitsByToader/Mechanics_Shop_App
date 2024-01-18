//
//  File.swift
//  
//
//  Created by Tudor Ifrim on 01.01.2024.
//

import Foundation

struct Bill: Codable {
    var id: UUID
    var order: UUID
    var billed: Bool
    var payed: Bool
    var items: [BillItem]
    
    func bill() async throws {
        guard let url = AppStore.backendURL?
            .appending(component: "bill")
            .appending(component: id.uuidString)
            .appending(component: "bill") else {
            throw AppError.BillTheBill
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (_, _) = try await URLSession.shared.data(for: request)
    }
    
    func pay() async throws {
        guard let url = AppStore.backendURL?
            .appending(component: "bill")
            .appending(component: id.uuidString)
            .appending(component: "pay") else {
            throw AppError.PayBill
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (_, _) = try await URLSession.shared.data(for: request)
    }
}
