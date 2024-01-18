import SwiftUI
import Foundation

class AppStore: ObservableObject {
    static let shared = AppStore()
    static let backendURL: URL? = URL(string: "http://127.0.0.1:8080")
    
    @Published var navPath = NavigationPath()
    @Published var loggedInUser: User? = nil
    
    private init() {}
}
