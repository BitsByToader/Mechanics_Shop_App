//
//  File.swift
//  
//
//  Created by Tudor Ifrim on 01.01.2024.
//

import Foundation

struct PlacedOrder: Codable {
    var customer: UUID
    var description: String
    var dropOffDate: Date
    
    func send() async throws {
        guard let url = AppStore.backendURL?
            .appending(component: "order")
            .appending(component: "place") else {
            throw AppError.BillRetreive
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(self)
        
        let (_, _) = try await URLSession.shared.data(for: request)
    }
}
