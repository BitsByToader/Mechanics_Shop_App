import SwiftUI
import Foundation

enum OrderState: String, Codable {
    case waiting
    case confirmed
    case denied
    case inprogress
    case rfp // Ready-For-Pickup
    case pickedup
    
    var description: String {
        switch self {
        case .waiting: "Asteptare confirmare..."
        case .confirmed: "Confirmat"
        case .denied: "Respins"
        case .inprogress: "In curs..."
        case .rfp: "Gata"
        case .pickedup: "Ridicat"
        }
    }
    
    var color: Color {
        switch self {
        case .waiting: Color.yellow
        case .confirmed: Color.blue
        case .denied: Color.red
        case .inprogress: Color.pink
        case .rfp: Color.green
        case .pickedup: Color.teal
        }
    }
}
