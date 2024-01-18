//
//  File.swift
//  
//
//  Created by Tudor Ifrim on 01.01.2024.
//

import Foundation

struct Mechanic: Equatable, Identifiable, Codable {
    var id: UUID
    var userId: UUID
    var name: String
    
    static func load(for manager: UUID) async throws-> [Mechanic] {
        guard let url = AppStore.backendURL?
            .appending(component: "mechanics")
            .appending(component: "manager")
            .appending(component: manager.uuidString) else {
            throw AppError.MechanicsForManagerRetrieve
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let mechanics: [Mechanic] = try JSONDecoder().decode([Mechanic].self, from: data)
        
        return mechanics
    }
}
