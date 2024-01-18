import Foundation
import SwiftUI

struct User: Hashable, Codable {
    var id: UUID = UUID()
    
    var name: String = ""
    var type: UserType = .none
    
    var username: String = ""
    var password: String?
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    init() {}
    
    func logIn() async throws -> User {
        guard let url = AppStore.backendURL?
            .appending(component: "user")
            .appending(component: "login") else {
            throw AppError.UserLogin
        }
        
        struct UserLoginContent: Codable {
            let username: String
            let password: String
        }
        let content = UserLoginContent(username: self.username , password: self.password ?? "")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try JSONEncoder().encode(content)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let authedUser: User = try JSONDecoder().decode(User.self, from: data)
        
        return authedUser
    }
    
    func loggedIn() -> Bool {
        return (self.type != .none)
    }
    
    static func register(name: String, username: String, password: String) async throws {
        guard let url = AppStore.backendURL?
            .appending(component: "user")
            .appending(component: "register") else {
            throw AppError.UserRegister
        }
        
        struct UserRegisterContent: Codable {
            let name: String
            let username: String
            let password: String
        }
        let content = UserRegisterContent(name: name,
                                          username: username,
                                          password: password
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try JSONEncoder().encode(content)
        
        let (_, _) = try await URLSession.shared.data(for: request)
    }
}
